import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../core/database/prisma.service';

@Injectable()
export class AccountsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Retrieves all active accounts where the specified user is an owner or member.
   * Powers the mobile Account Switcher drawer (Decision 01 / Pattern A).
   */
  async getMyAccounts(userId: string) {
    const memberships = await this.prisma.accountMember.findMany({
      where: {
        userId,
        account: {
          isActive: true,
          deletedAt: null,
        },
      },
      include: {
        account: {
          select: {
            id: true,
            accountType: true,
            displayName: true,
            slug: true,
            bio: true,
            logoUrl: true,
            verificationStatus: true,
            isActive: true,
            createdAt: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    return memberships.map((m) => ({
      ...m.account,
      role: m.role,
      joinedAt: m.createdAt,
    }));
  }
}
