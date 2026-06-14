/**
 * Script de desenvolvimento — concede acesso PRO a um usuário pelo e-mail.
 * Uso: npx ts-node prisma/grant-pro.ts <email>
 */
import { PrismaClient } from '@prisma/client';

const db = new PrismaClient();

async function main() {
  const email = process.argv[2];
  if (!email) {
    console.error('Uso: npx ts-node prisma/grant-pro.ts <email>');
    process.exit(1);
  }

  const user = await db.user.findUnique({ where: { email } });
  if (!user) {
    console.error(`Usuário não encontrado: ${email}`);
    process.exit(1);
  }

  const sub = await db.subscription.upsert({
    where: { userId: user.id },
    update: {
      plan: 'pro',
      status: 'active',
      expiresAt: null,
      activatedAt: new Date(),
    },
    create: {
      userId: user.id,
      plan: 'pro',
      status: 'active',
      expiresAt: null,
      activatedAt: new Date(),
    },
  });

  console.log(`✅ PRO ativado para ${email} (subscriptionId: ${sub.id})`);
}

main().catch(console.error).finally(() => db.$disconnect());
