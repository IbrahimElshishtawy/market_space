import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../core/database/prisma.service';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        phone: true,
        fullName: true,
        email: true,
        role: true,
        status: true,
        avatarUrl: true,
        preferredLanguage: true,
        governorateId: true,
        cityId: true,
        phoneVerifiedAt: true,
        createdAt: true,
        governorate: { select: { id: true, nameAr: true, nameEn: true } },
        city: { select: { id: true, nameAr: true, nameEn: true } },
      },
    });

    if (!user) {
      throw new NotFoundException('User profile not found');
    }

    return user;
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    return this.prisma.user.update({
      where: { id: userId },
      data: {
        fullName: dto.fullName,
        avatarUrl: dto.avatarUrl,
        preferredLanguage: dto.preferredLanguage,
        governorateId: dto.governorateId,
        cityId: dto.cityId,
      },
      select: {
        id: true,
        phone: true,
        fullName: true,
        avatarUrl: true,
        preferredLanguage: true,
        governorateId: true,
        cityId: true,
        updatedAt: true,
      },
    });
  }

  async softDeleteAccount(userId: string) {
    return this.prisma.user.update({
      where: { id: userId },
      data: {
        status: 'DELETED',
        deletedAt: new Date(),
        fullName: 'Deleted Account',
        avatarUrl: null,
      },
      select: {
        id: true,
        status: true,
        deletedAt: true,
      },
    });
  }
}
