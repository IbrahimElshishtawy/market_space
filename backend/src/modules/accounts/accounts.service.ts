import {
  Injectable,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../core/database/prisma.service';
import { CreateAccountDto } from './dto/create-account.dto';
import { CreateBranchDto } from './dto/create-branch.dto';

@Injectable()
export class AccountsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Creates a new merchant or seller account and assigns the user as owner.
   */
  async createAccount(userId: string, dto: CreateAccountDto) {
    let slug = dto.slug;
    if (!slug) {
      const sanitized = dto.displayName
        .toLowerCase()
        .trim()
        .replace(/[^\w\s-]/g, '')
        .replace(/[\s_-]+/g, '-')
        .replace(/^-+|-+$/g, '')
        .substring(0, 50);
      const randomSuffix = Math.random().toString(36).substring(2, 7);
      slug = sanitized ? `${sanitized}-${randomSuffix}` : `acc-${randomSuffix}`;
    }

    const existing = await this.prisma.account.findUnique({
      where: { slug },
    });
    if (existing) {
      slug = `${slug}-${Math.random().toString(36).substring(2, 6)}`;
    }

    return this.prisma.$transaction(async (tx) => {
      const account = await tx.account.create({
        data: {
          ownerUserId: userId,
          displayName: dto.displayName,
          accountType: dto.accountType,
          slug,
          bio: dto.bio,
          logoUrl: dto.logoUrl,
          bannerUrl: dto.bannerUrl,
          verificationStatus: 'pending',
          isActive: true,
        },
      });

      await tx.accountMember.create({
        data: {
          accountId: account.id,
          userId,
          role: 'owner',
        },
      });

      return account;
    });
  }

  /**
   * Creates a commercial store branch for an account.
   */
  async createBranch(accountId: string, userId: string, dto: CreateBranchDto) {
    const membership = await this.prisma.accountMember.findFirst({
      where: {
        accountId,
        userId,
        role: { in: ['owner', 'admin'] },
      },
    });

    if (!membership) {
      throw new ForbiddenException(
        'You do not have permission to add branches to this account',
      );
    }

    return this.prisma.branch.create({
      data: {
        accountId,
        name: dto.name,
        areaId: dto.areaId,
        address: dto.address,
        phone: dto.phone,
        isMain: dto.isMain ?? false,
      },
      include: {
        area: {
          include: {
            city: {
              include: { governorate: true },
            },
          },
        },
      },
    });
  }

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
          include: {
            area: { include: { city: { include: { governorate: true } } } },
          },
        },
        _count: {
          select: {
            listings: {
              where: { publicationStatus: 'published', deletedAt: null },
            },
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
