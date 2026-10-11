import { Test, TestingModule } from '@nestjs/testing';
import { WorkerService } from './worker.service';
import { ListingExpiryProcessor } from './listing-expiry.processor';
import { MediaCleanupProcessor } from './media-cleanup.processor';
import { PaymentReconciliationProcessor } from './payment-reconciliation.processor';
import { NotificationProcessor } from './notification.processor';

describe('WorkerService', () => {
  let service: WorkerService;
  let listingExpiryMock: jest.Mocked<ListingExpiryProcessor>;
  let notificationProcessorMock: jest.Mocked<NotificationProcessor>;

  beforeEach(async () => {
    listingExpiryMock = {
      processExpiredListings: jest.fn().mockResolvedValue({ expiredCount: 5 }),
    } as any;

    notificationProcessorMock = {
      processNotificationJob: jest.fn().mockResolvedValue(true),
    } as any;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WorkerService,
        { provide: ListingExpiryProcessor, useValue: listingExpiryMock },
        {
          provide: MediaCleanupProcessor,
          useValue: { processAbandonedMedia: jest.fn().mockResolvedValue({ purgedCount: 0 }) },
        },
        {
          provide: PaymentReconciliationProcessor,
          useValue: { processStaleTransactions: jest.fn().mockResolvedValue({ reconciledCount: 0 }) },
        },
        { provide: NotificationProcessor, useValue: notificationProcessorMock },
      ],
    }).compile();

    service = module.get<WorkerService>(WorkerService);
  });

  afterEach(() => {
    service.onModuleDestroy();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should enqueue and process async notifications', async () => {
    const result = await service.enqueueNotification({
      targetUserId: 'user-123',
      title: 'New Message',
      body: 'You have a message from buyer',
    });

    expect(result).toBe(true);
    expect(notificationProcessorMock.processNotificationJob).toHaveBeenCalledWith(
      expect.objectContaining({ targetUserId: 'user-123' }),
    );
  });
});
