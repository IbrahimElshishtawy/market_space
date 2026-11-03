import { Controller, Get, HttpStatus, Res } from '@nestjs/common';
import { FastifyReply } from 'fastify';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { PrismaService } from '../database/prisma.service';
import { RedisService } from '../redis/redis.service';

@ApiTags('Health')
@Controller('health')
export class HealthController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redisService: RedisService,
  ) {}

  @Get(['liveness', 'live'])
  @ApiOperation({ summary: 'Liveness probe' })
  @ApiResponse({ status: 200, description: 'Service is alive and responsive' })
  getLiveness() {
    return {
      status: 'ok',
      uptimeSeconds: Math.floor(process.uptime()),
      memoryRssMb: Math.round(process.memoryUsage().rss / 1024 / 1024),
      timestamp: new Date().toISOString(),
    };
  }

  @Get(['readiness', 'ready'])
  @ApiOperation({ summary: 'Readiness probe' })
  @ApiResponse({
    status: 200,
    description: 'All core infrastructure dependencies are healthy',
  })
  @ApiResponse({
    status: 503,
    description: 'One or more core infrastructure dependencies are down',
  })
  async getReadiness(@Res() res: FastifyReply) {
    const [dbResult, postgisResult, cacheResult, queueResult] =
      await Promise.allSettled([
        this.prisma.ping(),
        this.prisma.checkPostgisSupport(),
        this.redisService.pingCache(),
        this.redisService.pingQueue(),
      ]);

    const dbHealthy = dbResult.status === 'fulfilled' ? dbResult.value : false;
    const postgisHealthy =
      postgisResult.status === 'fulfilled'
        ? postgisResult.value.supported
        : false;
    const postgisVersion =
      postgisResult.status === 'fulfilled'
        ? postgisResult.value.version
        : undefined;
    const cacheHealthy =
      cacheResult.status === 'fulfilled' ? cacheResult.value : false;
    const queueHealthy =
      queueResult.status === 'fulfilled' ? queueResult.value : false;

    const isHealthy =
      dbHealthy && postgisHealthy && cacheHealthy && queueHealthy;

    const responsePayload = {
      status: isHealthy ? 'healthy' : 'unhealthy',
      checks: {
        database: dbHealthy ? 'up' : 'down',
        postgis: postgisHealthy ? `up (${postgisVersion ?? 'active'})` : 'down',
        redis_cache: cacheHealthy ? 'up' : 'down',
        redis_queue: queueHealthy ? 'up' : 'down',
      },
      timestamp: new Date().toISOString(),
    };

    const statusCode = isHealthy
      ? HttpStatus.OK
      : HttpStatus.SERVICE_UNAVAILABLE;

    return res.status(statusCode).send({
      success: isHealthy,
      data: responsePayload,
    });
  }
}
