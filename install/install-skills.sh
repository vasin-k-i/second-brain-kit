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

# Откуда брать кит — по порядку: GitHub → зеркало Cloudflare → vasinki.ru. Свой архив: SB_KIT_URL=...
KIT_URLS="${SB_KIT_URL:-https://github.com/vasin-k-i/second-brain-kit/archive/refs/heads/main.tar.gz https://sb-kit.consul456.workers.dev/sb-lx9wf4cApInIY9VF883j/kit.tar.gz https://vasinki.ru/sb-lx9wf4cApInIY9VF883j/kit.tar.gz}"
command -v curl >/dev/null 2>&1 || { echo "✗ нужен curl" >&2; exit 1; }
command -v tar  >/dev/null 2>&1 || { echo "✗ нужен tar"  >&2; exit 1; }

# Windows/schannel: смягчаем падение на проверке отзыва сертификата (CRYPT_E_NO_REVOCATION_CHECK)
CURL="curl -fsSL"
curl -V 2>/dev/null | grep -qi schannel && CURL="${CURL} --ssl-no-revoke"

TMP="$(mktemp -d)"; trap 'rm -rf "${TMP}"' EXIT
echo "Скачиваю скиллы «Второй мозг»…"
got=""
for u in ${KIT_URLS}; do
  if ${CURL} --connect-timeout 20 --max-time 300 "${u}" -o "${TMP}/kit.tar.gz" 2>/dev/null &&
     tar -tzf "${TMP}/kit.tar.gz" >/dev/null 2>&1; then
    got="${u}"; break
  fi
  echo "…не открылось: ${u%%/archive/*} — пробую следующий адрес"
done
[ -n "${got}" ] || { echo "✗ кит не скачался ни с одного адреса. Проверь интернет или VPN и повтори." >&2; exit 1; }
tar -xzf "${TMP}/kit.tar.gz" -C "${TMP}" 2>/dev/null
# корень кита — по файлу install/install.sh (у архива GitHub верхняя папка second-brain-kit-main/)
INNER="$(find "${TMP}" -type f -path '*/install/install.sh' | head -1)"
[ -n "${INNER}" ] || { echo "✗ в скачанном архиве нет install/install.sh" >&2; exit 1; }
SRC="$(cd -- "$(dirname -- "${INNER}")/.." && pwd -P)"

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
