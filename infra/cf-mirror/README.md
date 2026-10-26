# sb-kit — запасные адреса кита

Основной источник кита — открытый GitHub `vasin-k-i/second-brain-kit` (ветка main).
Установщики пробуют адреса по очереди: **GitHub → зеркало Cloudflare → vasinki.ru**.

## Зачем запасные

- GitHub открывается не из всех сетей.
- `vasinki.ru` живёт на РФ-IP `89.108.98.173` и **не достаётся примерно с половины зарубежных
  сетей и VPN**: TCP открывается, дальше тишина или `Connection reset by peer` (замер 2026-08-06).
- Зеркало на Cloudflare достаётся и из РФ, и из-за границы.

| Что | URL |
|---|---|
| Зеркало | `https://sb-kit.consul456.workers.dev/sb-lx9wf4cApInIY9VF883j/install.sh` и `…/kit.tar.gz` |
| vasinki.ru | `https://vasinki.ru/sb-lx9wf4cApInIY9VF883j/install.sh`, `kit.tar.gz`, `update.sh`, `install-skills.sh`, `update.ps1` |

Путь `sb-lx9wf4cApInIY9VF883j` исторический: раньше там лежал закрытый полный кит с Writer.
С 2026-10-26 Writer в кит не входит, там тот же открытый кит, что на GitHub. Путь оставлен,
потому что по нему обновляются старые установки.

## Обновить запасные адреса

Кит вшит в бандл воркера base64-строкой, а **не** проксируется с РФ-VPS: CF→РФ-origin рвётся
на больших телах.

```bash
# 1) push в main репозитория
cd ~/Projects/second-brain-kit/infra/cf-mirror
./build.sh --vps           # качает main с GitHub, собирает бандл, кладёт кит и скрипты на vasinki.ru
npx wrangler@3 deploy      # wrangler 4 требует Node >= 22; авторизация — OAuth wrangler
```

Проверка — md5 зеркала и vasinki.ru совпадают с `build/kit.tar.gz`:

```bash
md5 -q build/kit.tar.gz
curl -fsS https://sb-kit.consul456.workers.dev/sb-lx9wf4cApInIY9VF883j/kit.tar.gz | md5 -q
curl -fsS https://vasinki.ru/sb-lx9wf4cApInIY9VF883j/kit.tar.gz | md5 -q
```

⚠️ Роут `*.workers.dev` после первого деплоя минуту-другую отдаёт `error code: 1042` — это пропагация.
