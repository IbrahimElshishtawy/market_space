import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { HttpException, BadRequestException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { PrismaService } from '../../core/database/prisma.service';

describe('AuthService (Milestone 1)', () => {
  let service: AuthService;
  let prisma: PrismaService;

  const mockPrisma = {
    otp: {
      count: jest.fn(),
      updateMany: jest.fn(),
      create: jest.fn(),
      findFirst: jest.fn(),
      update: jest.fn(),
    },
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    userSession: {
      create: jest.fn(),
      findFirst: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
    },
  };

  const mockJwtService = {
    sign: jest.fn().mockReturnValue('mocked.jwt.access.token'),
  };

  const mockConfigService = {
    get: jest.fn((key: string, defaultValue?: string) => {
      if (key === 'JWT_ACCESS_SECRET') return 'test_jwt_secret_1234567890';
      return defaultValue;
    }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: JwtService, useValue: mockJwtService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  describe('sendOtp', () => {
    it('should generate and store OTP when rate limit is not exceeded', async () => {
      mockPrisma.otp.count.mockResolvedValue(1); // 1 request recently (< 3)
      mockPrisma.otp.updateMany.mockResolvedValue({ count: 1 });
      mockPrisma.otp.create.mockResolvedValue({ id: 'otp-id' });

      const result = await service.sendOtp({ phone: '+201012345678' });

      expect(result.message).toContain('dispatched successfully');
      expect(mockPrisma.otp.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            phone: '+201012345678',
            otpCodeHash: expect.any(String),
          }),
        }),
      );
    });

    it('should throw HTTP 429 when phone has requested 3 OTPs in last 15 minutes', async () => {
      mockPrisma.otp.count.mockResolvedValue(3); // Rate limit reached

      await expect(service.sendOtp({ phone: '+201012345678' })).rejects.toThrow(
        HttpException,
      );
    });
  });

  describe('verifyOtp', () => {
    it('should verify correct OTP, create user if not exists, and return tokens', async () => {
      // Compute valid hash for code 123456
      const code = '123456';
      const validHash = (service as any).hashOtp(code);

      mockPrisma.otp.findFirst.mockResolvedValue({
        id: 'otp-1',
        phone: '+201012345678',
        otpCodeHash: validHash,
        attempts: 0,
      });
      mockPrisma.otp.update.mockResolvedValue({});
      mockPrisma.user.findUnique.mockResolvedValue(null); // User doesn't exist yet
      mockPrisma.user.create.mockResolvedValue({
        id: 'user-uuid-1',
        phone: '+201012345678',
        fullName: 'User 5678',
        role: 'USER',
        status: 'ACTIVE',
      });
      mockPrisma.userSession.create.mockResolvedValue({});

      const response = await service.verifyOtp({
        phone: '+201012345678',
        code: '123456',
      });

      expect(response.user.id).toBe('user-uuid-1');
      expect(response.tokens.accessToken).toBe('mocked.jwt.access.token');
      expect(response.tokens.refreshToken).toBeDefined();
    });

    it('should reject verification when code is incorrect', async () => {
      mockPrisma.otp.findFirst.mockResolvedValue({
        id: 'otp-1',
        phone: '+201012345678',
        otpCodeHash: 'different_hash',
        attempts: 0,
      });
      mockPrisma.otp.update.mockResolvedValue({});

      await expect(
        service.verifyOtp({ phone: '+201012345678', code: '999999' }),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
