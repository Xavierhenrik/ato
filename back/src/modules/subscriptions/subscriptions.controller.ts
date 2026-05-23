import { FastifyRequest, FastifyReply } from 'fastify';
import { SubscriptionsService } from './subscriptions.service';

export class SubscriptionsController {
  private svc = new SubscriptionsService();

  async getStatus(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.getStatus(user.id));
  }

  async revenueCatWebhook(req: FastifyRequest, reply: FastifyReply) {
    const secret = req.headers['x-revenuecat-secret'];
    if (secret !== process.env.REVENUECAT_WEBHOOK_SECRET) {
      return reply.code(401).send({ error: 'Unauthorized' });
    }

    const rcBody = req.body as { event?: { type?: string; app_user_id?: string } };
    req.log.info(
      { event: rcBody?.event?.type, userId: rcBody?.event?.app_user_id },
      'RevenueCat webhook'
    );

    const event = req.body as Record<string, unknown>;
    await this.svc.handleWebhook(event);

    return reply.code(200).send({ received: true });
  }
}
