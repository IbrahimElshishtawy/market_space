import { Test, TestingModule } from '@nestjs/testing';
import { HealthController } from './health.controller';
import { PrismaService } from '../database/prisma.service';

describe('HealthController', () => {
  let controller: HealthController;
  let prismaService: PrismaService;

  beforeEach(async () => {
    const mockPrisma = {
      $queryRaw: jest.fn().mockResolvedValue([{ 1: 1 }]),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        {
          provide: PrismaService,
          useValue: mockPrisma,
        },
      ],
    }).compile();

    controller = module.get<HealthController>(HealthController);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  describe('getLiveness', () => {
    it('should return status ok with uptime and memory', () => {
      const result = controller.getLiveness();
      expect(result.status).toBe('ok');
      expect(result.uptimeSeconds).toBeGreaterThanOrEqual(0);
      expect(result.memoryRssMb).toBeGreaterThan(0);
      expect(result.timestamp).toBeDefined();
    });
  });

  describe('getReadiness', () => {
    it('should return healthy status when database is reachable', async () => {
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        send: jest.fn().mockImplementation((payload) => payload),
      };

      await controller.getReadiness(mockRes as any);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.send).toHaveBeenCalledWith(
        expect.objectContaining({
          success: true,
          data: expect.objectContaining({
            status: 'healthy',
            checks: { database: 'up' },
          }),
        }),
      );
    });

    it('should return service unavailable status when database query fails', async () => {
      jest
        .spyOn(prismaService, '$queryRaw')
        .mockRejectedValueOnce(new Error('DB Connection Refused'));

      const mockRes = {
        status: jest.fn().mockReturnThis(),
        send: jest.fn().mockImplementation((payload) => payload),
      };

      await controller.getReadiness(mockRes as any);

      expect(mockRes.status).toHaveBeenCalledWith(503);
      expect(mockRes.send).toHaveBeenCalledWith(
        expect.objectContaining({
          success: false,
          data: expect.objectContaining({
            status: 'unhealthy',
            checks: { database: 'down' },
          }),
        }),
      );
    });
  });
});
