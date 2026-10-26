#!/usr/bin/env bash
#
# «Второй мозг» — установщик. Качает кит и ставит: папка с заметками, память, команды.
#
#   curl -fsSL https://raw.githubusercontent.com/vasin-k-i/second-brain-kit/main/install.sh | bash
#
# Обычно его запускает агент по файлу УСТАНОВИ-МЕНЯ.md. Путь к заметкам — аргумент
# или SB_VAULT (по умолчанию ~/SecondBrain). Ввод с клавиатуры не читает.
#
set -euo pipefail

# Откуда брать кит — по порядку, пока не скачается:
#   1) GitHub (открытый репозиторий, всегда свежий main)
#   2) зеркало на Cloudflare (если GitHub не открывается)
#   3) vasinki.ru (если не открывается ни то, ни другое — например, без VPN в части сетей)
# Свой архив: SB_KIT_URL=...
KIT_URLS="${SB_KIT_URL:-https://github.com/vasin-k-i/second-brain-kit/archive/refs/heads/main.tar.gz https://sb-kit.consul456.workers.dev/sb-lx9wf4cApInIY9VF883j/kit.tar.gz https://vasinki.ru/sb-lx9wf4cApInIY9VF883j/kit.tar.gz}"
DEST="${HOME}/.second-brain-kit"   # постоянное место кита (тут живут doctor.sh, update.sh, шаблоны)

command -v curl >/dev/null 2>&1 || { echo "✗ нужен curl" >&2; exit 1; }
command -v tar  >/dev/null 2>&1 || { echo "✗ нужен tar"  >&2; exit 1; }

# Windows/schannel: curl падает на проверке отзыва сертификата (CRYPT_E_NO_REVOCATION_CHECK)
# в некоторых сетях — на Windows смягчаем флагом, на macOS/Linux ничего не меняем.
CURL="curl -fsSL"
curl -V 2>/dev/null | grep -qi schannel && CURL="${CURL} --ssl-no-revoke"

TMP="$(mktemp -d)"; trap 'rm -rf "${TMP}"' EXIT
echo "Скачиваю кит «Второй мозг»…"
got=""
for u in ${KIT_URLS}; do
  if ${CURL} --connect-timeout 20 --max-time 300 "${u}" -o "${TMP}/kit.tar.gz" 2>/dev/null &&
     tar -tzf "${TMP}/kit.tar.gz" >/dev/null 2>&1; then
    got="${u}"; break
  fi
  echo "…не открылось: ${u%%/archive/*} — пробую следующий адрес"
done
[ -n "${got}" ] || { echo "✗ кит не скачался ни с одного адреса. Проверь интернет или VPN и повтори." >&2; exit 1; }
tar -xzf "${TMP}/kit.tar.gz" -C "${TMP}"

# Имя верхней папки у архивов разное (second-brain-kit-main/, second-brain-kit/) —
# ищем корень кита по файлу install/install.sh, а не по имени.
INNER="$(find "${TMP}" -type f -path '*/install/install.sh' | head -1)"
[ -n "${INNER}" ] || { echo "✗ в скачанном архиве нет install/install.sh" >&2; exit 1; }
SRC="$(cd -- "$(dirname -- "${INNER}")/.." && pwd -P)"

rm -rf "${DEST}"; mkdir -p "$(dirname "${DEST}")"; cp -R "${SRC}/." "${DEST}/"
echo "✓ Кит в ${DEST}"

bash "${DEST}/install/install.sh" "${1:-}"
