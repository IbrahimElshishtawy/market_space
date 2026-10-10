import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { validateEnv } from './core/config/env.config';
import { PrismaService } from './core/database/prisma.service';
import { HealthController } from './core/health/health.controller';

import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { MediaModule } from './modules/media/media.module';
import { ListingsModule } from './modules/listings/listings.module';
import { SearchModule } from './modules/search/search.module';
import { ChatModule } from './modules/chat/chat.module';
import { VideoModule } from './modules/video/video.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { ModerationModule } from './modules/moderation/moderation.module';
import { NotificationsModule } from './modules/notifications/notifications.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validate: validateEnv,
    }),
    AuthModule,
    UsersModule,
    CategoriesModule,
    MediaModule,
    ListingsModule,
    SearchModule,
    ChatModule,
    VideoModule,
    PaymentsModule,
    ModerationModule,
    NotificationsModule,
  ],
  controllers: [HealthController],
  providers: [PrismaService],
  exports: [PrismaService],
})
export class AppModule {}
