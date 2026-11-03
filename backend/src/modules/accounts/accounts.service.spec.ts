import { Test, TestingModule } from '@nestjs/testing';
import { AccountsService } from './accounts.service';
import { PrismaService } from '../../core/database/prisma.service';

describe('AccountsService', () => {
  let service: AccountsService;

  const mockPrisma = {
    accountMember: {
      findMany: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AccountsService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<AccountsService>(AccountsService);
    jest.clearAllMocks();
  });

  it('should list user accounts with member role', async () => {
    mockPrisma.accountMember.findMany.mockResolvedValue([
      {
        role: 'owner',
        createdAt: new Date('2026-11-03T18:00:00Z'),
        account: {
          id: 'acc-1',
          accountType: 'individual',
          displayName: 'Personal Account',
          slug: 'personal-account',
          verificationStatus: 'approved',
          isActive: true,
        },
      },
      {
        role: 'manager',
        createdAt: new Date('2026-11-03T18:05:00Z'),
        account: {
          id: 'acc-2',
          accountType: 'company',
          displayName: 'El-Sewedy Motors',
          slug: 'el-sewedy-motors',
          verificationStatus: 'approved',
          isActive: true,
        },
      },
    ]);

    const result = await service.getMyAccounts('user-1');

    expect(result).toHaveLength(2);
    expect(result[0].id).toBe('acc-1');
    expect(result[0].role).toBe('owner');
    expect(result[1].id).toBe('acc-2');
    expect(result[1].role).toBe('manager');
  });
});
