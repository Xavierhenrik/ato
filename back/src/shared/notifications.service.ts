import * as https from 'https';

const ONESIGNAL_BASE_URL = 'onesignal.com';

function httpsRequest(options: https.RequestOptions, body?: string): Promise<{ statusCode: number; data: string }> {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk: Buffer) => { data += chunk.toString(); });
      res.on('end', () => resolve({ statusCode: res.statusCode ?? 0, data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

export class NotificationsService {
  /**
   * Sends a push notification to a OneSignal player.
   * Returns { success: false } without throwing if ONESIGNAL_APP_ID is not configured.
   */
  async sendPush(
    playerId: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<{ success: boolean; error?: string }> {
    const appId = process.env['ONESIGNAL_APP_ID'];
    const apiKey = process.env['ONESIGNAL_API_KEY'];

    if (!appId) {
      console.warn(JSON.stringify({ event: 'onesignal_missing_config', msg: 'ONESIGNAL_APP_ID not set — push skipped' }));
      return { success: false };
    }

    const payload = JSON.stringify({
      app_id: appId,
      include_player_ids: [playerId],
      headings: { en: title },
      contents: { en: body },
      ...(data ? { data } : {}),
    });

    try {
      const result = await httpsRequest(
        {
          hostname: ONESIGNAL_BASE_URL,
          path: '/api/v1/notifications',
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Basic ${apiKey ?? ''}`,
            'Content-Length': Buffer.byteLength(payload),
          },
        },
        payload,
      );

      if (result.statusCode >= 200 && result.statusCode < 300) {
        return { success: true };
      }

      const error = `OneSignal API returned ${result.statusCode}: ${result.data}`;
      console.error(JSON.stringify({ event: 'onesignal_send_failed', statusCode: result.statusCode, body: result.data }));
      return { success: false, error };
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      console.error(JSON.stringify({ event: 'onesignal_send_error', error: message }));
      return { success: false, error: message };
    }
  }

  /**
   * Validates that a OneSignal player ID exists.
   * Returns true if the player is found (HTTP 200), false otherwise.
   */
  async validatePlayer(playerId: string): Promise<boolean> {
    const appId = process.env['ONESIGNAL_APP_ID'];

    if (!appId) {
      console.warn(JSON.stringify({ event: 'onesignal_missing_config', msg: 'ONESIGNAL_APP_ID not set — validatePlayer returns false' }));
      return false;
    }

    try {
      const result = await httpsRequest({
        hostname: ONESIGNAL_BASE_URL,
        path: `/api/v1/players/${encodeURIComponent(playerId)}?app_id=${encodeURIComponent(appId)}`,
        method: 'GET',
        headers: {
          'Authorization': `Basic ${process.env['ONESIGNAL_API_KEY'] ?? ''}`,
        },
      });

      return result.statusCode === 200;
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      console.error(JSON.stringify({ event: 'onesignal_validate_error', playerId, error: message }));
      return false;
    }
  }
}

export const notificationsService = new NotificationsService();
