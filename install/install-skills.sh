#!/usr/bin/env bash
#
# «Второй мозг» — установка ТОЛЬКО скиллов (команд-помощников).
#
# Для случая, когда скиллы не встали / встали частично / сломались, а второй мозг
# (папка с заметками) уже лежит где надо — в т.ч. перенесён в облако (iCloud и т.п.).
#
# Что делает (и ТОЛЬКО это):
#   - скачивает кит, кладёт/перезаписывает скиллы в ~/.claude/skills/ как обычные /команды.
# Чего НЕ делает:
#   - НЕ разворачивает каркас _BRAIN/, НЕ создаёт ~/SecondBrain,
#   - НЕ трогает ~/.claude/CLAUDE.md (мост памяти) и ~/.claude/settings.json.
# Поэтому он не «переедет» второй мозг и не сломает уже настроенное.
#
#   curl -fsSL https://raw.githubusercontent.com/vasin-k-i/second-brain-kit/main/install/install-skills.sh | bash
#
set -euo pipefail

KIT_URL="${SB_KIT_URL:-https://github.com/vasin-k-i/second-brain-kit/archive/refs/heads/main.tar.gz}"
case "${KIT_URL}" in http*://*) : ;; *) echo "✗ KIT_URL не задан" >&2; exit 1 ;; esac
command -v curl >/dev/null 2>&1 || { echo "✗ нужен curl" >&2; exit 1; }
command -v tar  >/dev/null 2>&1 || { echo "✗ нужен tar"  >&2; exit 1; }

# Windows/schannel: смягчаем падение на проверке отзыва сертификата (CRYPT_E_NO_REVOCATION_CHECK)
CURL="curl -fsSL"
curl -V 2>/dev/null | grep -qi schannel && CURL="${CURL} --ssl-no-revoke"

TMP="$(mktemp -d)"; trap 'rm -rf "${TMP}"' EXIT
echo "Скачиваю скиллы «Второй мозг»…"
${CURL} "${KIT_URL}" -o "${TMP}/kit.tar.gz"
tar -xzf "${TMP}/kit.tar.gz" -C "${TMP}"

# тарбол распаковывается в second-brain-kit/
SRC="${TMP}/second-brain-kit"
[ -d "${SRC}" ] || SRC="$(dirname "$(find "${TMP}" -name install -type d | head -1)")"

SKILLS_DST="${HOME}/.claude/skills"
mkdir -p "${SKILLS_DST}"
copied=0
for d in "${SRC}/skills"/*/ "${SRC}/plugins/content/skills"/*/; do
  [ -d "${d}" ] && [ -f "${d}SKILL.md" ] || continue
  name="$(basename -- "${d}")"
  rm -rf -- "${SKILLS_DST}/${name}"        # перезаписываем — чиним сломанные/частичные
  cp -R -- "${d%/}" "${SKILLS_DST}/${name}"
  copied=$((copied+1))
done

echo ""
echo "✓ Скиллы установлены: ${copied} → ${SKILLS_DST}"
echo "  Второй мозг (твои заметки) НЕ трогал — остался там, где лежит."
echo ""
echo "Последний шаг: перезапусти Claude Code (закрой и открой заново),"
echo "набери  /  — увидишь команды: /capture, /find, /setup-second-brain и другие."
