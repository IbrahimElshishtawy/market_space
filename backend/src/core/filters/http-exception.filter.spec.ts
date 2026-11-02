import { HttpExceptionFilter } from './http-exception.filter';
import { HttpException, HttpStatus, BadRequestException } from '@nestjs/common';

describe('HttpExceptionFilter', () => {
  let filter: HttpExceptionFilter;

  beforeEach(() => {
    filter = new HttpExceptionFilter();
  });

  it('should format standard HttpException with code, message, and trace_id', () => {
    const mockSend = jest.fn();
    const mockStatus = jest.fn().mockReturnValue({ send: mockSend });
    const mockHeader = jest.fn();

    const mockHost: any = {
      switchToHttp: () => ({
        getResponse: () => ({
          status: mockStatus,
          header: mockHeader,
        }),
        getRequest: () => ({
          headers: { 'x-trace-id': 'test-trace-id-123' },
          raw: { traceId: 'test-trace-id-123' },
        }),
      }),
    };

    const exception = new HttpException('Forbidden access', HttpStatus.FORBIDDEN);
    filter.catch(exception, mockHost);

    expect(mockStatus).toHaveBeenCalledWith(HttpStatus.FORBIDDEN);
    expect(mockHeader).toHaveBeenCalledWith('x-trace-id', 'test-trace-id-123');
    expect(mockSend).toHaveBeenCalledWith({
      success: false,
      error: {
        code: 'FORBIDDEN',
        message: 'Forbidden access',
        details: null,
        trace_id: 'test-trace-id-123',
      },
    });
  });

  it('should format validation errors into VALIDATION_FAILED with field details', () => {
    const mockSend = jest.fn();
    const mockStatus = jest.fn().mockReturnValue({ send: mockSend });
    const mockHeader = jest.fn();

    const mockHost: any = {
      switchToHttp: () => ({
        getResponse: () => ({
          status: mockStatus,
          header: mockHeader,
        }),
        getRequest: () => ({
          headers: {},
          raw: { traceId: 'val-trace-456' },
        }),
      }),
    };

    const exception = new BadRequestException([
      'phone must be an Egyptian mobile number',
      'price must not be negative',
    ]);
    filter.catch(exception, mockHost);

    expect(mockStatus).toHaveBeenCalledWith(HttpStatus.BAD_REQUEST);
    expect(mockSend).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        error: expect.objectContaining({
          code: 'VALIDATION_FAILED',
          message: 'Validation failed for one or more fields',
          details: [
            { issue: 'phone must be an Egyptian mobile number' },
            { issue: 'price must not be negative' },
          ],
          trace_id: 'val-trace-456',
        }),
      }),
    );
  });

  it('should format unhandled 500 error gracefully with trace_id', () => {
    const mockSend = jest.fn();
    const mockStatus = jest.fn().mockReturnValue({ send: mockSend });
    const mockHeader = jest.fn();

    const mockHost: any = {
      switchToHttp: () => ({
        getResponse: () => ({
          status: mockStatus,
          header: mockHeader,
        }),
        getRequest: () => ({
          headers: { 'x-trace-id': 'unhandled-trace-789' },
          raw: {},
        }),
      }),
    };

    const exception = new Error('Database connection exploded');
    filter.catch(exception, mockHost);

    expect(mockStatus).toHaveBeenCalledWith(HttpStatus.INTERNAL_SERVER_ERROR);
    expect(mockSend).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        error: expect.objectContaining({
          code: 'INTERNAL_SERVER_ERROR',
          message: 'An unexpected server error occurred.',
          trace_id: 'unhandled-trace-789',
        }),
      }),
    );
  });
});
