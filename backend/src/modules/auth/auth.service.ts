import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import * as argon2 from 'argon2';
import { PrismaService } from '../../core/database/prisma.service';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { LoginPasswordDto } from './dto/login-password.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly otpSalt: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {
    this.otpSalt = this.configService.get<string>('JWT_ACCESS_SECRET', 'marketspace_salt');
  }

  /**
   * Dispatches a 6-digit SMS OTP with sliding-window rate limiting.
   */
  async sendOtp(dto: SendOtpDto): Promise<{ message: string; cooldownSeconds: number }> {
    const { phone } = dto;
    const fifteenMinutesAgo = new Date(Date.now() - 15 * 60 * 1000);

    // Sliding window check: max 3 requests per 15 minutes
    const recentOtpCount = await this.prisma.otp.count({
      where: {
        phone,
        createdAt: { gte: fifteenMinutesAgo },
      },
    });

    if (recentOtpCount >= 3) {
      throw new HttpException(
        'Too many OTP requests for this phone number. Please wait 15 minutes before requesting a new code.',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    // Invalidate previous unconsumed OTPs for this phone
    await this.prisma.otp.updateMany({
      where: { phone, isConsumed: false },
      data: { isConsumed: true },
    });

    // Generate cryptographically secure 6-digit numeric OTP
    const code = crypto.randomInt(100000, 999999).toString();
    const otpCodeHash = this.hashOtp(code);
    const expiresAt = new Date(Date.now() + 180 * 1000); // 180 seconds validity

    await this.prisma.otp.create({
      data: {
        phone,
        otpCodeHash,
        expiresAt,
      },
    });

    // Development / Staging simulation logger
    this.logger.log(`📱 [SMS Gateway Simulation] OTP code for ${phone} is: [ ${code} ] (expires in 180s)`);

    return {
      message: 'OTP verification code dispatched successfully via SMS',
      cooldownSeconds: 60,
    };
  }

  /**
   * Verifies submitted OTP code, activates user account, and returns JWT session pair.
   */
  async verifyOtp(
    dto: VerifyOtpDto,
    userAgent?: string,
    ipAddress?: string,
  ) {
    const { phone, code } = dto;

    const activeOtp = await this.prisma.otp.findFirst({
      where: {
        phone,
        isConsumed: false,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!activeOtp) {
      throw new BadRequestException('Invalid or expired OTP code. Please request a new one.');
    }

    // Brute-force protection: max 5 attempts per active OTP
    if (activeOtp.attempts >= 5) {
      await this.prisma.otp.update({
        where: { id: activeOtp.id },
        data: { isConsumed: true },
      });
      throw new BadRequestException('Maximum verification attempts exceeded. Please request a new OTP code.');
    }

    const expectedHash = this.hashOtp(code);
    if (activeOtp.otpCodeHash !== expectedHash) {
      await this.prisma.otp.update({
        where: { id: activeOtp.id },
        data: { attempts: { increment: 1 } },
      });
      throw new BadRequestException('Incorrect OTP code.');
    }

    // Mark OTP as consumed
    await this.prisma.otp.update({
      where: { id: activeOtp.id },
      data: { isConsumed: true },
    });

    // Upsert user account
    let user = await this.prisma.user.findUnique({ where: { phone } });

    if (!user) {
      user = await this.prisma.user.create({
        data: {
          phone,
          fullName: `User ${phone.slice(-4)}`,
          status: 'ACTIVE',
          phoneVerifiedAt: new Date(),
          lastLoginAt: new Date(),
        },
      });
    } else {
      if (user.status === 'SUSPENDED') {
        throw new UnauthorizedException('Your account has been suspended by administration.');
      }
      user = await this.prisma.user.update({
        where: { id: user.id },
        data: {
          phoneVerifiedAt: user.phoneVerifiedAt ?? new Date(),
          lastLoginAt: new Date(),
          status: user.status === 'PENDING_VERIFICATION' ? 'ACTIVE' : user.status,
        },
      });
    }

    // Generate tokens & save session
    const tokens = await this.createSession(user.id, user.phone, user.role, userAgent, ipAddress);

    return {
      user: {
        id: user.id,
        phone: user.phone,
        fullName: user.fullName,
        role: user.role,
        avatarUrl: user.avatarUrl,
      },
      tokens,
    };
  }

  /**
   * Authenticates user via Egyptian phone number and password.
   */
  async loginWithPassword(
    dto: LoginPasswordDto,
    userAgent?: string,
    ipAddress?: string,
  ) {
    const { phone, password } = dto;

    const user = await this.prisma.user.findUnique({ where: { phone } });
    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Invalid phone number or password.');
    }

    if (user.status === 'SUSPENDED') {
      throw new UnauthorizedException('Account suspended.');
    }

    const isMatch = await argon2.verify(user.passwordHash, password);
    if (!isMatch) {
      throw new UnauthorizedException('Invalid phone number or password.');
    }

    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    const tokens = await this.createSession(user.id, user.phone, user.role, userAgent, ipAddress);

    return {
      user: {
        id: user.id,
        phone: user.phone,
        fullName: user.fullName,
        role: user.role,
        avatarUrl: user.avatarUrl,
      },
      tokens,
    };
  }

  /**
   * Rotates refresh token, invalidating old token and issuing new JWT pair.
   */
  async refreshToken(dto: RefreshTokenDto, userAgent?: string, ipAddress?: string) {
    const incomingHash = this.hashRefreshToken(dto.refreshToken);

    const session = await this.prisma.userSession.findFirst({
      where: {
        refreshTokenHash: incomingHash,
        isRevoked: false,
        expiresAt: { gt: new Date() },
      },
      include: { user: true },
    });

    if (!session || !session.user) {
      throw new UnauthorizedException('Invalid or expired refresh token.');
    }

    if (session.user.status === 'SUSPENDED') {
      throw new UnauthorizedException('Account suspended.');
    }

    // Invalidate old session (Token Rotation)
    await this.prisma.userSession.update({
      where: { id: session.id },
      data: { isRevoked: true },
    });

    // Create new session pair
    const tokens = await this.createSession(
      session.user.id,
      session.user.phone,
      session.user.role,
      userAgent,
      ipAddress,
    );

    return tokens;
  }

  /**
   * Revokes the active session upon logout.
   */
  async logout(dto: RefreshTokenDto): Promise<{ success: boolean; message: string }> {
    const hash = this.hashRefreshToken(dto.refreshToken);

    await this.prisma.userSession.updateMany({
      where: { refreshTokenHash: hash },
      data: { isRevoked: true },
    });

    return {
      success: true,
      message: 'Logged out successfully; session revoked.',
    };
  }

  // -------------------------------------------------------------
  // HELPER METHODS
  // -------------------------------------------------------------

  private hashOtp(code: string): string {
    return crypto
      .createHash('sha256')
      .update(code + this.otpSalt)
      .digest('hex');
  }

  private hashRefreshToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }

  private async createSession(
    userId: string,
    phone: string,
    role: string,
    userAgent?: string,
    ipAddress?: string,
  ) {
    const accessToken = this.jwtService.sign(
      { sub: userId, phone, role },
      {
        secret: this.configService.get<string>('JWT_ACCESS_SECRET'),
        expiresIn: '15m',
      },
    );

    const rawRefreshToken = crypto.randomBytes(40).toString('hex');
    const refreshTokenHash = this.hashRefreshToken(rawRefreshToken);
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days

    await this.prisma.userSession.create({
      data: {
        userId,
        refreshTokenHash,
        userAgent: userAgent?.substring(0, 500),
        ipAddress: ipAddress?.substring(0, 50),
        expiresAt,
      },
    });

    return {
      accessToken,
      refreshToken: rawRefreshToken,
      expiresIn: 900, // 15 minutes in seconds
    };
  }
}
