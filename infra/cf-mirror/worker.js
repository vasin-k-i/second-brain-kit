// sb-kit — зеркало раздачи кита «Второй мозг» на Cloudflare edge.
//
// Зачем: основной хост vasinki.ru (89.108.98.173, РФ) не достаётся примерно с половины
// зарубежных сетей и VPN — TCP открывается, дальше тишина/«Connection reset by peer».
// Аудитория кита сидит на Claude → сидит на VPN → упирается ровно в это.
// Воркер отдаёт те же два файла с CF-edge: доступно и из РФ (проверено на workers.dev),
// и из-за границы.
//
// Кит вшит в бандл (kit-b64.js), а НЕ проксируется с РФ-VPS: CF→РФ-origin рвётся
// на больших телах (та же грабля, что с баннером бота).
//
// Обновление кита и деплой — build.sh рядом.

import { KIT_B64 } from './kit-b64.js';       // генерится build.sh
import { INSTALL_SH } from './install-sh.js'; // генерится build.sh

const SECRET = 'sb-lx9wf4cApInIY9VF883j'; // gitleaks:allow — исторический путь, не секрет: там открытый кит

let kitBytes = null;
function kit() {
  if (!kitBytes) {
    const bin = atob(KIT_B64);
    const out = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
    kitBytes = out;
  }
  return kitBytes;
}

const NOINDEX = { 'X-Robots-Tag': 'noindex, nofollow' };

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname.replace(/\/+$/, '');

    if (path === `/${SECRET}/install.sh`) {
      return new Response(INSTALL_SH, {
        headers: {
          'Content-Type': 'text/x-shellscript; charset=utf-8',
          'Cache-Control': 'public, max-age=300',
          ...NOINDEX,
        },
      });
    }

    if (path === `/${SECRET}/kit.tar.gz`) {
      const body = kit();
      return new Response(body, {
        headers: {
          'Content-Type': 'application/gzip',
          'Content-Length': String(body.length),
          'Content-Disposition': 'attachment; filename="kit.tar.gz"',
          'Cache-Control': 'public, max-age=300',
          ...NOINDEX,
        },
      });
    }

    return new Response('Not found\n', { status: 404, headers: NOINDEX });
  },
};
