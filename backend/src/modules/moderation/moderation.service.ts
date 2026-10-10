import { Injectable, NotFoundException } from '@nestjs/common';
import { ReportStatus } from '@prisma/client';
import { PrismaService } from '../../core/database/prisma.service';
import { CreateReportDto } from './dto/create-report.dto';
import { AdjudicateReportDto } from './dto/adjudicate-report.dto';

@Injectable()
export class ModerationService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Files a user abuse report against a listing or user.
   */
  async fileReport(reporterId: string, dto: CreateReportDto) {
    return this.prisma.report.create({
      data: {
        reporterId,
        listingId: dto.listingId,
        reportedUserId: dto.reportedUserId,
        reason: dto.reason,
        notes: dto.notes,
        status: ReportStatus.PENDING,
      },
    });
  }

  /**
   * Retrieves pending abuse reports for moderators.
   */
  async getModerationQueue(page = 1, limit = 20) {
    const skip = (page - 1) * limit;

    const [total, reports] = await Promise.all([
      this.prisma.report.count({ where: { status: ReportStatus.PENDING } }),
      this.prisma.report.findMany({
        where: { status: ReportStatus.PENDING },
        skip,
        take: limit,
        orderBy: { createdAt: 'asc' },
        include: {
          reporter: { select: { id: true, fullName: true, phone: true } },
          listing: { select: { id: true, title: true, price: true, status: true } },
          reportedUser: { select: { id: true, fullName: true, phone: true, status: true } },
        },
      }),
    ]);

    return {
      reports,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Adjudicates a report and records an immutable entry in the audit trail.
   */
  async adjudicateReport(
    reportId: string,
    moderatorId: string,
    dto: AdjudicateReportDto,
    ipAddress?: string,
    userAgent?: string,
  ) {
    const report = await this.prisma.report.findUnique({
      where: { id: reportId },
    });

    if (!report) {
      throw new NotFoundException('Report not found');
    }

    return this.prisma.$transaction(async (tx) => {
      const updatedReport = await tx.report.update({
        where: { id: reportId },
        data: {
          status: dto.status,
          actionTaken: dto.actionTaken,
          moderatorId,
          resolvedAt: new Date(),
        },
      });

      // Immutable audit log
      await tx.auditLog.create({
        data: {
          actorId: moderatorId,
          actorRole: 'MODERATOR',
          action: `ADJUDICATE_REPORT_${dto.status}`,
          targetEntity: 'REPORT',
          targetId: reportId,
          ipAddress: ipAddress?.slice(0, 50),
          userAgent: userAgent?.slice(0, 500),
          diffPayload: {
            previousStatus: report.status,
            newStatus: dto.status,
            actionTaken: dto.actionTaken,
          },
        },
      });

      return updatedReport;
    });
  }

  /**
   * Retrieves immutable audit logs for Super Admins.
   */
  async getAuditLogs(page = 1, limit = 50) {
    const skip = (page - 1) * limit;

    const [total, logs] = await Promise.all([
      this.prisma.auditLog.count(),
      this.prisma.auditLog.findMany({
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    return {
      logs,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
