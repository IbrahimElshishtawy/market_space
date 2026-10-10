import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { ListingStatus } from '@prisma/client';
import { ChatService } from './chat.service';
import { PrismaService } from '../../core/database/prisma.service';

describe('ChatService (Milestone 5)', () => {
  let service: ChatService;
  let prisma: PrismaService;

  const mockPrisma: any = {
    listing: { findUnique: jest.fn() },
    conversation: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    message: {
      count: jest.fn(),
      findMany: jest.fn(),
      updateMany: jest.fn(),
      create: jest.fn(),
    },
    $transaction: jest.fn((callback: (tx: any) => any) => callback(mockPrisma)),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChatService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<ChatService>(ChatService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  describe('getOrCreateConversation', () => {
    it('should prevent buyer from initiating conversation on their own listing', async () => {
      mockPrisma.listing.findUnique.mockResolvedValue({
        id: 'listing-1',
        userId: 'user-self',
        status: ListingStatus.PUBLISHED,
      });

      await expect(
        service.getOrCreateConversation('listing-1', 'user-self'),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('getMessages - IDOR Check', () => {
    it('should throw ForbiddenException if user is not a participant in the conversation', async () => {
      mockPrisma.conversation.findUnique.mockResolvedValue({
        id: 'conv-1',
        buyerId: 'user-buyer',
        sellerId: 'user-seller',
      });

      await expect(
        service.getMessages('conv-1', 'intruder-user'),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
