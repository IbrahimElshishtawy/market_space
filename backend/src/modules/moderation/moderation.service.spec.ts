import { Test, TestingModule } from '@nestjs/testing';
import { ReportStatus, ReportReason } from '@prisma/client';
import { ModerationService } from './moderation.service';
import { PrismaService } from '../../core/database/prisma.service';

describe('ModerationService (Milestone 8)', () => {
  let service: ModerationService;
  let prisma: PrismaService;

  const mockPrisma: any = {
    report: {
      create: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
      count: jest.fn(),
      update: jest.fn(),
    },
    auditLog: {
      create: jest.fn(),
      findMany: jest.fn(),
      count: jest.fn(),
    },
    $transaction: jest.fn((callback: (tx: any) => any) => callback(mockPrisma)),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ModerationService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<ModerationService>(ModerationService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  describe('fileReport', () => {
    it('should create an abuse report with PENDING status', async () => {
      mockPrisma.report.create.mockResolvedValue({
        id: 'report-1',
        reason: ReportReason.SPAM,
        status: ReportStatus.PENDING,
      });

      const result = await service.fileReport('reporter-1', {
        listingId: 'listing-1',
        reason: ReportReason.SPAM,
        notes: 'إعلان سبام متكرر',
      });

      expect(result.id).toBe('report-1');
      expect(mockPrisma.report.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            reporterId: 'reporter-1',
            listingId: 'listing-1',
            status: ReportStatus.PENDING,
          }),
        }),
      );
    });
  });

  describe('adjudicateReport', () => {
    it('should update report status and record an immutable audit log entry', async () => {
      mockPrisma.report.findUnique.mockResolvedValue({
        id: 'report-1',
        status: ReportStatus.PENDING,
      });
      mockPrisma.report.update.mockResolvedValue({
        id: 'report-1',
        status: ReportStatus.ACTION_TAKEN,
      });
      mockPrisma.auditLog.create.mockResolvedValue({ id: 'log-1' });

      const result = await service.adjudicateReport(
        'report-1',
        'moderator-1',
        {
          status: ReportStatus.ACTION_TAKEN,
          actionTaken: 'تم حذف الإعلان',
        },
        '127.0.0.1',
      );

      expect(result.status).toBe(ReportStatus.ACTION_TAKEN);
      expect(mockPrisma.auditLog.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            actorId: 'moderator-1',
            actorRole: 'MODERATOR',
            action: 'ADJUDICATE_REPORT_ACTION_TAKEN',
            targetId: 'report-1',
          }),
        }),
      );
    });
  });
});
