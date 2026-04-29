import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

// Tipos de evento RevenueCat relevantes
type RCEvent = {
  event: {
    type: string;
    app_user_id: string;
    product_id?: string;
    expiration_at_ms?: number;
  };
};

export class SubscriptionsService {
  async getStatus(userId: string) {
    const sub = await db.subscription.findUnique({ where: { userId } });
    if (!sub) throw Errors.notFound('Assinatura');

    const isActive = sub.status === 'active' && (sub.plan === 'free' || (sub.expiresAt ? sub.expiresAt > new Date() : true));

    return {
      plan: sub.plan,
      status: sub.status,
      isActive,
      expiresAt: sub.expiresAt,
    };
  }

  async handleWebhook(body: Record<string, unknown>) {
    const { event } = body as RCEvent;
    if (!event) return;

    const supabaseId = event.app_user_id;
    const user = await db.user.findUnique({ where: { supabaseId } });
    if (!user) return;

    switch (event.type) {
      case 'INITIAL_PURCHASE':
      case 'RENEWAL':
        await db.subscription.update({
          where: { userId: user.id },
          data: {
            plan: 'pro',
            status: 'active',
            activatedAt: new Date(),
            expiresAt: event.expiration_at_ms ? new Date(event.expiration_at_ms) : null,
          },
        });
        break;

      case 'CANCELLATION':
      case 'EXPIRATION':
        await db.subscription.update({
          where: { userId: user.id },
          data: { status: event.type === 'EXPIRATION' ? 'expired' : 'cancelled' },
        });
        break;
    }
  }
}
