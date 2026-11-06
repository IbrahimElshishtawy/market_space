import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../core/database/prisma.service';

@Injectable()
export class QuotasService {
  constructor(private readonly prisma: PrismaService) {}

  async getMyQuotaUsage(userId: string) {
    const cairoDateStr = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Africa/Cairo',
    }).format(new Date());
    const usageDate = new Date(`${cairoDateStr}T00:00:00.000Z`);

    const callerAccount = await this.prisma.account.findFirst({
      where: {
        OR: [{ ownerUserId: userId }, { members: { some: { userId } } }],
      },
      orderBy: { createdAt: 'asc' },
    });

    if (!callerAccount) {
      throw new NotFoundException('Active account not found for user');
    }

    const DAILY_LIMIT = 5;

    const existingQuota = await this.prisma.dailyQuota.findUnique({
      where: {
        uq_account_quota_date: {
          accountId: callerAccount.id,
          quotaType: 'contact_reveal',
          usageDate,
        },
      },
    });

    const used = existingQuota ? existingQuota.usedCount : 0;
    const remaining = Math.max(0, DAILY_LIMIT - used);

    return {
      timezone: 'Africa/Cairo',
      date: cairoDateStr,
      contactReveals: {
        used,
        limit: DAILY_LIMIT,
        remaining,
        isLimitReached: used >= DAILY_LIMIT,
      },
    };
  }
}

