import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { ListingStatus } from '@prisma/client';
import { PrismaService } from '../../core/database/prisma.service';

@Injectable()
export class ChatService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Starts or returns an existing conversation bound to (listing, buyer, seller).
   */
  async getOrCreateConversation(listingId: string, buyerId: string) {
    const listing = await this.prisma.listing.findUnique({
      where: { id: listingId },
    });

    if (!listing || listing.status !== ListingStatus.PUBLISHED) {
      throw new NotFoundException('Listing not found or is no longer published');
    }

    if (listing.userId === buyerId) {
      throw new BadRequestException('You cannot start a conversation on your own listing');
    }

    const existing = await this.prisma.conversation.findUnique({
      where: {
        listingId_buyerId: {
          listingId,
          buyerId,
        },
      },
      include: {
        listing: { select: { id: true, title: true, price: true } },
        seller: { select: { id: true, fullName: true, avatarUrl: true } },
      },
    });

    if (existing) {
      return existing;
    }

    return this.prisma.conversation.create({
      data: {
        listingId,
        buyerId,
        sellerId: listing.userId,
      },
      include: {
        listing: { select: { id: true, title: true, price: true } },
        seller: { select: { id: true, fullName: true, avatarUrl: true } },
      },
    });
  }

  /**
   * Retrieves active conversations for the authenticated user.
   */
  async getUserConversations(userId: string) {
    return this.prisma.conversation.findMany({
      where: {
        OR: [{ buyerId: userId }, { sellerId: userId }],
      },
      orderBy: { lastMessageAt: 'desc' },
      include: {
        listing: {
          select: {
            id: true,
            title: true,
            price: true,
            media: {
              take: 1,
              orderBy: { sortOrder: 'asc' },
              select: { publicUrl: true },
            },
          },
        },
        buyer: { select: { id: true, fullName: true, avatarUrl: true } },
        seller: { select: { id: true, fullName: true, avatarUrl: true } },
      },
    });
  }

  /**
   * Retrieves paginated messages in a conversation, ensuring participant authorization (IDOR check).
   */
  async getMessages(conversationId: string, userId: string, page = 1, limit = 30) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
    });

    if (!conversation) {
      throw new NotFoundException('Conversation not found');
    }

    if (conversation.buyerId !== userId && conversation.sellerId !== userId) {
      throw new ForbiddenException('You are not a participant in this conversation');
    }

    // Mark unread messages sent by the other party as read
    await this.prisma.message.updateMany({
      where: {
        conversationId,
        senderId: { not: userId },
        isRead: false,
      },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    });

    const skip = (page - 1) * limit;

    const [total, messages] = await Promise.all([
      this.prisma.message.count({ where: { conversationId } }),
      this.prisma.message.findMany({
        where: { conversationId },
        skip,
        take: limit,
        orderBy: { createdAt: 'asc' },
        include: {
          sender: { select: { id: true, fullName: true, avatarUrl: true } },
        },
      }),
    ]);

    return {
      messages,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Sends a text message inside a verified conversation.
   */
  async sendMessage(conversationId: string, senderId: string, text: string) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
    });

    if (!conversation) {
      throw new NotFoundException('Conversation not found');
    }

    if (conversation.buyerId !== senderId && conversation.sellerId !== senderId) {
      throw new ForbiddenException('You are not a participant in this conversation');
    }

    return this.prisma.$transaction(async (tx) => {
      const message = await tx.message.create({
        data: {
          conversationId,
          senderId,
          messageText: text,
        },
        include: {
          sender: { select: { id: true, fullName: true, avatarUrl: true } },
        },
      });

      await tx.conversation.update({
        where: { id: conversationId },
        data: {
          lastMessageText: text.slice(0, 500),
          lastMessageAt: new Date(),
        },
      });

      return message;
    });
  }
}
