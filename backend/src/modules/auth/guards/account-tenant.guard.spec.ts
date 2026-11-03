import {
  ExecutionContext,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { AccountTenantGuard } from './account-tenant.guard';
import { PrismaService } from '../../../core/database/prisma.service';
import { RedisService } from '../../../core/redis/redis.service';

describe('AccountTenantGuard', () => {
  let guard: AccountTenantGuard;

  const mockPrisma = {
    accountMember: {
      findUnique: jest.fn(),
    },
  };

  const mockRedis = {
    get: jest.fn(),
    set: jest.fn(),
  };

  const createMockContext = (
    user: any,
    headers: Record<string, string> = {},
  ): ExecutionContext => {
    const request: any = {
      user,
      headers,
    };

    return {
      switchToHttp: () => ({
        getRequest: () => request,
      }),
    } as unknown as ExecutionContext;
  };

  beforeEach(() => {
    guard = new AccountTenantGuard(
      mockPrisma as unknown as PrismaService,
      mockRedis as unknown as RedisService,
    );
    jest.clearAllMocks();
  });

  it('should pass through when no x-account-id header is provided', async () => {
    const ctx = createMockContext({ id: 'user-1' }, {});
    const result = await guard.canActivate(ctx);
    expect(result).toBe(true);
  });

  it('should throw BadRequestException on invalid UUID in x-account-id', async () => {
    const ctx = createMockContext(
      { id: 'user-1' },
      { 'x-account-id': 'not-a-uuid' },
    );
    await expect(guard.canActivate(ctx)).rejects.toThrow(BadRequestException);
  });

  it('should throw ForbiddenException if user is not an active member of account', async () => {
    const accountId = 'a0000000-0000-0000-0000-000000000001';
    const ctx = createMockContext(
      { id: 'user-1' },
      { 'x-account-id': accountId },
    );

    mockRedis.get.mockResolvedValue(null);
    mockPrisma.accountMember.findUnique.mockResolvedValue(null);

    await expect(guard.canActivate(ctx)).rejects.toThrow(ForbiddenException);
  });

  it('should attach AccountContext and cache in Redis when user is authorized member', async () => {
    const accountId = 'a0000000-0000-0000-0000-000000000001';
    const ctx = createMockContext(
      { id: 'user-1' },
      { 'x-account-id': accountId },
    );
    const req = ctx.switchToHttp().getRequest() as any;

    mockRedis.get.mockResolvedValue(null);
    mockPrisma.accountMember.findUnique.mockResolvedValue({
      accountId,
      userId: 'user-1',
      role: 'owner',
      account: {
        id: accountId,
        accountType: 'company',
        isActive: true,
        deletedAt: null,
      },
    });

    const result = await guard.canActivate(ctx);
    expect(result).toBe(true);
    expect(req.accountContext).toBeDefined();
    expect(req.accountContext.accountId).toBe(accountId);
    expect(req.accountContext.memberRole).toBe('owner');
    expect(req.accountContext.permissions.has('*')).toBe(true);

    expect(mockRedis.set).toHaveBeenCalledWith(
      `account:membership:user-1:${accountId}`,
      expect.objectContaining({ accountId, memberRole: 'owner' }),
      300,
    );
  });
});
