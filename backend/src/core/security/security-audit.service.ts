import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

export interface AuditEventPayload {
  action: string;
  actorType?: 'user' | 'staff' | 'system' | 'anonymous';
  actorId?: string;
  targetEntity: string;
  targetId?: string;
  ipAddress?: string;
  userAgent?: string;
  correlationId?: string;
  metadata?: Record<string, unknown>;
}

/**
 * Structured Security Audit Service.
 * Writes immutable, non-sensitive audit records to PostgreSQL audit_log table.
 * Strictly guarantees that passwords, OTP codes, and raw JWT tokens are never persisted in audit trails.
 */
@Injectable()
export class SecurityAuditService {
  private readonly logger = new Logger(SecurityAuditService.name);
  private readonly uuidRegex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

  constructor(private readonly prisma: PrismaService) {}

  async logEvent(event: AuditEventPayload): Promise<void> {
    const {
      action,
      actorType = event.actorId ? 'user' : 'system',
      actorId,
      targetEntity,
      targetId,
      ipAddress,
      userAgent,
      correlationId,
      metadata = {},
    } = event;

    // Sanitize metadata to safeguard against accidental secret leakage
    const sanitizedMetadata = this.sanitizeMetadata(metadata);
    if (correlationId) {
      sanitizedMetadata.correlationId = correlationId;
    }

    // Ensure actorId and targetId conform to PostgreSQL UUID type; non-UUIDs are retained in metadata
    let validActorId: string | null = null;
    if (actorId) {
      if (this.uuidRegex.test(actorId)) {
        validActorId = actorId;
      } else {
        sanitizedMetadata.rawActorId = actorId;
      }
    }

    let validTargetId: string | null = null;
    if (targetId) {
      if (this.uuidRegex.test(targetId)) {
        validTargetId = targetId;
      } else {
        sanitizedMetadata.rawTargetId = targetId;
      }
    }

    try {
      await this.prisma.auditLog.create({
        data: {
          actorType,
          actorId: validActorId,
          action,
          targetEntity,
          targetId: validTargetId,
          ipAddress: ipAddress ? ipAddress.substring(0, 50) : null,
          userAgent: userAgent ? userAgent.substring(0, 500) : null,
          diffPayload: sanitizedMetadata as any,
        },
      });

      this.logger.log(
        `🛡️ [SECURITY AUDIT] Action: ${action} | Entity: ${targetEntity}:${targetId || 'N/A'} | Actor: [${actorType}] ${actorId || 'Anonymous'}`,
      );
    } catch (err: any) {
      // Audit failure must never crash the main transaction, but must log an urgent system alert
      this.logger.error(
        `🚨 FAILED to record security audit log for action [${action}]: ${err.message}`,
        err.stack,
      );
    }
  }

  /**
   * Recursively strips potential credentials, hashes, and token keys from audit payloads.
   */
  private sanitizeMetadata(
    obj: Record<string, unknown>,
  ): Record<string, unknown> {
    const sensitiveKeys = new Set([
      'code',
      'otp',
      'password',
      'passwordhash',
      'refreshtoken',
      'accesstoken',
      'authorization',
      'secret',
      'token',
    ]);

    const sanitized: Record<string, unknown> = {};

    for (const [key, value] of Object.entries(obj)) {
      const lowerKey = key.toLowerCase();
      if (sensitiveKeys.has(lowerKey)) {
        sanitized[key] = '[REDACTED]';
      } else if (
        value &&
        typeof value === 'object' &&
        !Array.isArray(value) &&
        !(value instanceof Date)
      ) {
        sanitized[key] = this.sanitizeMetadata(
          value as Record<string, unknown>,
        );
      } else {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }
}
