#!/usr/bin/env bash
#
# «Второй мозг на Claude Code» — установщик из публичного GitHub-репозитория.
# Качает кит с GitHub, распаковывает и ставит. Никаких архивов вручную.
#
# Одна команда (macOS / Linux, и Windows через Git Bash):
#   curl -fsSL https://raw.githubusercontent.com/vasin-k-i/second-brain-kit/main/install.sh | bash
#
set -euo pipefail

# По умолчанию берём свежий main с GitHub. Можно переопределить своим тарболом: SB_KIT_URL=...
KIT_URL="${SB_KIT_URL:-https://github.com/vasin-k-i/second-brain-kit/archive/refs/heads/main.tar.gz}"
DEST="${HOME}/.second-brain-kit"   # постоянное место кита (чтобы /plugin его видел)

command -v curl >/dev/null 2>&1 || { echo "✗ нужен curl" >&2; exit 1; }
command -v tar  >/dev/null 2>&1 || { echo "✗ нужен tar"  >&2; exit 1; }

# Windows/schannel: curl падает на проверке отзыва сертификата (CRYPT_E_NO_REVOCATION_CHECK)
# в некоторых сетях — на Windows смягчаем флагом, на macOS/Linux ничего не меняем.
CURL="curl -fsSL"
curl -V 2>/dev/null | grep -qi schannel && CURL="${CURL} --ssl-no-revoke"

TMP="$(mktemp -d)"; trap 'rm -rf "${TMP}"' EXIT
echo "Скачиваю кит «Второй мозг» с GitHub…"
${CURL} "${KIT_URL}" -o "${TMP}/kit.tar.gz"
tar -xzf "${TMP}/kit.tar.gz" -C "${TMP}"

# top-dir GitHub-тарбола = <repo>-<branch>/ (имя меняется) → находим корень кита
# по install/install.sh, не завязываясь на конкретное имя папки.
INNER="$(find "${TMP}" -type f -path '*/install/install.sh' | head -1)"
[ -n "${INNER}" ] || { echo "✗ не нашёл install/install.sh в скачанном ките" >&2; exit 1; }
SRC="$(cd -- "$(dirname -- "${INNER}")/.." && pwd -P)"

rm -rf "${DEST}"; mkdir -p "$(dirname "${DEST}")"; cp -R "${SRC}/." "${DEST}/"
echo "✓ Кит в ${DEST}"

# разворот каркаса + мост памяти + раскладка скиллов (тестированный install.sh)
bash "${DEST}/install/install.sh" "${1:-}"
