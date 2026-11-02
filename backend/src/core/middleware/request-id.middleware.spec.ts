import { RequestIdMiddleware, REQUEST_ID_HEADER, TRACE_ID_HEADER } from './request-id.middleware';

describe('RequestIdMiddleware', () => {
  let middleware: RequestIdMiddleware;

  beforeEach(() => {
    middleware = new RequestIdMiddleware();
  });

  it('should generate UUID trace_id and request_id when none provided', () => {
    const req: any = { headers: {} };
    const res: any = { setHeader: jest.fn(), headersSent: false };
    const next = jest.fn();

    middleware.use(req, res, next);

    expect(req.headers[REQUEST_ID_HEADER]).toBeDefined();
    expect(req.headers[TRACE_ID_HEADER]).toBeDefined();
    expect(req.headers[REQUEST_ID_HEADER]).toEqual(req.headers[TRACE_ID_HEADER]);
    expect(res.setHeader).toHaveBeenCalledWith(
      REQUEST_ID_HEADER,
      req.headers[REQUEST_ID_HEADER],
    );
    expect(res.setHeader).toHaveBeenCalledWith(
      TRACE_ID_HEADER,
      req.headers[TRACE_ID_HEADER],
    );
    expect(next).toHaveBeenCalled();
  });

  it('should preserve incoming x-trace-id header', () => {
    const existingTraceId = 'client-trace-12345';
    const req: any = { headers: { 'x-trace-id': existingTraceId } };
    const res: any = { setHeader: jest.fn(), headersSent: false };
    const next = jest.fn();

    middleware.use(req, res, next);

    expect(req.headers[TRACE_ID_HEADER]).toBe(existingTraceId);
    expect(req.headers[REQUEST_ID_HEADER]).toBe(existingTraceId);
    expect(res.setHeader).toHaveBeenCalledWith(TRACE_ID_HEADER, existingTraceId);
    expect(next).toHaveBeenCalled();
  });
});
