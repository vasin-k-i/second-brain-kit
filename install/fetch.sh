#!/usr/bin/env bash
#
# «Второй мозг» — fetch-установщик. Скачивает кит с гейт-URL и ставит. Без архива вручную.
# Этот файл раздаётся с хоста как install.sh; KIT_URL подставляется при деплое.
# Покупатель запускает одной строкой:
#   curl -fsSL https://<домен>/<секрет>/install.sh | bash
#
set -euo pipefail

KIT_URL="${SB_KIT_URL:-__KIT_URL__}"   # подставляется при деплое (sed)
DEST="${HOME}/.second-brain-kit"        # постоянное место кита (чтобы /plugin видел)

case "${KIT_URL}" in
  http*://*) : ;;  # подставлен реальный URL — ок
  *) echo "✗ KIT_URL не задан — это шаблон, не раздавай как есть." >&2; exit 1 ;;
esac
command -v curl >/dev/null 2>&1 || { echo "✗ нужен curl" >&2; exit 1; }
command -v tar  >/dev/null 2>&1 || { echo "✗ нужен tar"  >&2; exit 1; }

# Windows/schannel: curl падает на проверке отзыва сертификата (CRYPT_E_NO_REVOCATION_CHECK)
# в некоторых сетях — на Windows смягчаем флагом, на macOS/Linux ничего не меняем.
CURL="curl -fsSL"
curl -V 2>/dev/null | grep -qi schannel && CURL="${CURL} --ssl-no-revoke"

TMP="$(mktemp -d)"; trap 'rm -rf "${TMP}"' EXIT
echo "Скачиваю кит «Второй мозг»…"
${CURL} "${KIT_URL}" -o "${TMP}/kit.tar.gz"
tar -xzf "${TMP}/kit.tar.gz" -C "${TMP}"

# тарбол распаковывается в second-brain-kit/
SRC="${TMP}/second-brain-kit"
[ -d "${SRC}" ] || SRC="$(dirname "$(find "${TMP}" -name install -type d | head -1)")"

rm -rf "${DEST}"; mkdir -p "$(dirname "${DEST}")"; cp -R "${SRC}/." "${DEST}/"
echo "✓ Кит в ${DEST}"

# разворот каркаса + мост памяти + раскладка скиллов (тестированный install.sh)
bash "${DEST}/install/install.sh" "${1:-}"
