import { Controller, Get, HttpStatus, Res } from '@nestjs/common';
import { FastifyReply } from 'fastify';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { PrismaService } from '../database/prisma.service';

@ApiTags('Health')
@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('live')
  @ApiOperation({ summary: 'Liveness probe' })
  @ApiResponse({ status: 200, description: 'Service is alive' })
  getLiveness() {
    return {
      status: 'ok',
      uptimeSeconds: process.uptime(),
      memoryRssMb: Math.round(process.memoryUsage().rss / 1024 / 1024),
      timestamp: new Date().toISOString(),
    };
  }

  @Get('ready')
  @ApiOperation({ summary: 'Readiness probe' })
  @ApiResponse({ status: 200, description: 'Dependencies are healthy' })
  async getReadiness(@Res() res: FastifyReply) {
    let dbHealthy = false;

    try {
      await this.prisma.$queryRaw`SELECT 1`;
      dbHealthy = true;
    } catch {
      dbHealthy = false;
    }

    const isHealthy = dbHealthy;
    const responsePayload = {
      status: isHealthy ? 'healthy' : 'unhealthy',
      checks: {
        database: dbHealthy ? 'up' : 'down',
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
