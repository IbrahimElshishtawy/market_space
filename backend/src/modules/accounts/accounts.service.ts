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

  /**
   * Retrieves public seller account profile.
   */
  async getAccountById(id: string) {
    const account = await this.prisma.account.findUnique({
      where: { id },
      include: {
        branches: {
          take: 5,
          include: { area: { include: { city: { include: { governorate: true } } } } },
        },
        _count: {
          select: {
            listings: { where: { publicationStatus: 'published', deletedAt: null } },
            branches: true,
          },
        },
      },
    });

    if (!account || !account.isActive || account.deletedAt) {
      return null;
    }

    return {
      id: account.id,
      displayName: account.displayName,
      slug: account.slug,
      accountType: account.accountType,
      bio: account.bio,
      logoUrl: account.logoUrl,
      bannerUrl: account.bannerUrl,
      verificationStatus: account.verificationStatus,
      branchesCount: account._count.branches,
      activeListingsCount: account._count.listings,
      branches: account.branches,
      createdAt: account.createdAt,
    };
  }

  /**
   * Retrieves all branches for a given account.
   */
  async getAccountBranches(accountId: string) {
    return this.prisma.branch.findMany({
      where: { accountId },
      include: {
        area: {
          include: {
            city: {
              include: { governorate: true },
            },
          },
        },
      },
      orderBy: [{ isMain: 'desc' }, { createdAt: 'asc' }],
    });
  }
}
