#!/usr/bin/env bash
#
# «Второй мозг» — ОБНОВЛЕНИЕ для тех, кто уже установил кит.
#
# Что делает (и ТОЛЬКО это, аккуратно и идемпотентно):
#   1. Обновляет/перезаписывает скиллы в ~/.claude/skills/ .
#   2. Ставит SessionStart-хук (если его не было) — движок, который грузит твоё ядро
#      в каждую сессию и напоминает записать итог. Прописывает его в ~/.claude/settings.json.
#   3. Дописывает правила записи памяти в мост ~/.claude/CLAUDE.md — ТОЛЬКО внутри
#      маркеров кита, остальные твои инструкции не трогает.
#
# Чего НЕ делает: не переносит и не пересоздаёт твои заметки, не трогает текст вне
# маркеров second-brain-kit, не лезет в твой vault. Все правки — с бэкапом (*.bak).
#
#   curl -fsSL https://raw.githubusercontent.com/vasin-k-i/second-brain-kit/main/install/update.sh | bash
#
set -euo pipefail

if [ -t 1 ]; then B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; N=$'\033[0m'; else B=""; G=""; Y=""; N=""; fi
ok()   { printf '%s\n' "${G}✓${N} $*"; }
warn() { printf '%s\n' "${Y}!${N} $*"; }
info() { printf '%s\n' "  $*"; }

# Откуда брать кит — по порядку: GitHub → зеркало Cloudflare → vasinki.ru. Свой архив: SB_KIT_URL=...
KIT_URLS="${SB_KIT_URL:-https://github.com/vasin-k-i/second-brain-kit/archive/refs/heads/main.tar.gz https://sb-kit.consul456.workers.dev/sb-lx9wf4cApInIY9VF883j/kit.tar.gz https://vasinki.ru/sb-lx9wf4cApInIY9VF883j/kit.tar.gz}"
command -v curl >/dev/null 2>&1 || { echo "✗ нужен curl" >&2; exit 1; }
command -v tar  >/dev/null 2>&1 || { echo "✗ нужен tar"  >&2; exit 1; }

CFG="${HOME}/.claude"
GLOBAL_MD="${CFG}/CLAUDE.md"
SETTINGS="${CFG}/settings.json"
HOOKS_DST="${CFG}/hooks"
SKILLS_DST="${CFG}/skills"
VERSION_STAMP="${CFG}/.sbk-version"
# Бэкапы прежних версий скиллов. ⚠️ Живут СНАРУЖИ ~/.second-brain-kit: шаг 0 ниже
# сносит ту папку целиком, и бэкапы внутри неё умерли бы на следующем же апдейте.
BACKUP_ROOT="${CFG}/sbk-backups"
# один таймстамп на весь запуск — иначе скиллы одного апдейта разъедутся по разным папкам
RUN_TS="$(date -u +%Y%m%dT%H%M%SZ)"

# Windows/schannel: смягчаем падение на проверке отзыва сертификата (CRYPT_E_NO_REVOCATION_CHECK)
CURL="curl -fsSL"
curl -V 2>/dev/null | grep -qi schannel && CURL="${CURL} --ssl-no-revoke"

TMP="$(mktemp -d)"; trap 'rm -rf "${TMP}"' EXIT
printf '%s\n' "${B}Обновляю «Второй мозг»…${N}"
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

# --- 0. обновить сам кит в ~/.second-brain-kit (там живут doctor.sh, install-codex.sh и шаблоны) ---
KIT_DST="${HOME}/.second-brain-kit"
if [ -d "${SRC}" ]; then
  rm -rf -- "${KIT_DST}"; mkdir -p "${KIT_DST}"
  cp -R -- "${SRC}/." "${KIT_DST}/"
  ok "Кит обновлён: ${KIT_DST}"
fi

# --- 1. скиллы: перезаписываем (чиним старые/частичные, доставляем новые) ---
# Перед перезаписью старую версию скилла кладём в ${BACKUP_ROOT}/${RUN_TS}/<скилл>/,
# чтобы ручные правки пользователя не исчезали молча.
mkdir -p "${SKILLS_DST}"
copied=0
backed=0
for d in "${SRC}/skills"/*/ "${SRC}/plugins/content/skills"/*/; do
  [ -d "${d}" ] && [ -f "${d}SKILL.md" ] || continue
  name="$(basename -- "${d}")"
  # бэкапим только реально установленный скилл (папка + SKILL.md), не пустышку
  if [ -d "${SKILLS_DST}/${name}" ] && [ -f "${SKILLS_DST}/${name}/SKILL.md" ]; then
    if mkdir -p "${BACKUP_ROOT}/${RUN_TS}" 2>/dev/null &&
       cp -R -- "${SKILLS_DST}/${name}" "${BACKUP_ROOT}/${RUN_TS}/${name}" 2>/dev/null; then
      backed=$((backed+1))
    else
      warn "не смог сохранить бэкап скилла ${name} — обновляю его без бэкапа"
    fi
  fi
  rm -rf -- "${SKILLS_DST}/${name}"
  cp -R -- "${d%/}" "${SKILLS_DST}/${name}"
  copied=$((copied+1))
done
ok "Скиллы обновлены: ${copied} → ${SKILLS_DST}"
if [ "${backed}" -gt 0 ]; then
  info "Прежние версии скиллов (${backed}) сохранены: ${BACKUP_ROOT}/${RUN_TS}"
  info "Правил скилл под себя — твоя версия там, апдейт ничего не потерял."
fi

# версия кита: штамп для доктора и поддержки (простой текст, без JSON)
SBK_VERSION="unknown"
if [ -f "${SRC}/VERSION" ]; then
  v="$(head -n 1 "${SRC}/VERSION" 2>/dev/null | tr -d '[:space:]' || true)"
  [ -n "${v}" ] && SBK_VERSION="${v}"
fi
mkdir -p "${CFG}"
{
  printf 'version=%s\n' "${SBK_VERSION}"
  printf 'installed_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "${VERSION_STAMP}"
ok "Версия кита: ${SBK_VERSION} (штамп: ${VERSION_STAMP})"


# --- 2. найти, где лежит _BRAIN (из @-ссылок в мосте или дефолт) ---
BRAIN_DIR=""
if [ -f "${GLOBAL_MD}" ]; then
  ref="$(grep -oE '@[^[:space:]]+/_BRAIN/[A-Za-z0-9._-]+\.md' "${GLOBAL_MD}" | head -1 || true)"
  if [ -n "${ref}" ]; then
    p="${ref#@}"
    case "${p}" in "~/"*) p="${HOME}/${p#\~/}" ;; esac
    BRAIN_DIR="$(dirname "${p}")"
  fi
fi
# ссылка может указывать на несуществующий путь (stale / симлинк отсутствует) — тогда фолбэк
[ -n "${BRAIN_DIR}" ] && [ ! -d "${BRAIN_DIR}" ] && BRAIN_DIR=""
if [ -z "${BRAIN_DIR}" ]; then
  for cand in "${HOME}/SecondBrain/_BRAIN" "${HOME}/Second Brain/_BRAIN"; do
    [ -d "${cand}" ] && { BRAIN_DIR="${cand}"; break; }
  done
fi
VAULT_MD=""
[ -n "${BRAIN_DIR}" ] && VAULT_MD="$(dirname "${BRAIN_DIR}")/CLAUDE.md"

# --- 3. SessionStart-хук + регистрация в settings.json ---
if [ -n "${BRAIN_DIR}" ] && [ -d "${BRAIN_DIR}" ]; then
  mkdir -p "${HOOKS_DST}"
  HOOK="${HOOKS_DST}/load-second-brain.sh"
  if [ -f "${SRC}/install/hooks/load-second-brain.sh" ]; then
    sed "s#__BRAIN_DIR__#${BRAIN_DIR}#g" "${SRC}/install/hooks/load-second-brain.sh" > "${HOOK}"
    chmod +x "${HOOK}"
    ok "SessionStart-хук установлен: ${HOOK}"
  else
    warn "Шаблон хука не найден в ките — пропускаю."
    HOOK=""
  fi

  if [ -n "${HOOK}" ] && command -v python3 >/dev/null 2>&1; then
    [ -f "${SETTINGS}" ] && cp -p -- "${SETTINGS}" "${SETTINGS}.bak"
    python3 - "${SETTINGS}" "bash ${HOOK}" <<'PY'
import json, os, sys
sf, cmd = sys.argv[1], sys.argv[2]
os.makedirs(os.path.dirname(sf), exist_ok=True)
try:
    s = json.load(open(sf)); assert isinstance(s, dict)
except Exception:
    s = {}
ss = s.setdefault("hooks", {}).setdefault("SessionStart", [])
already = any("load-second-brain" in h.get("command", "")
             for grp in ss for h in grp.get("hooks", []))
if not already:
    ss.append({"hooks": [{"type": "command", "command": cmd}]})
json.dump(s, open(sf, "w"), ensure_ascii=False, indent=2)
print("registered" if not already else "exists")
PY
    ok "Хук прописан в settings.json (бэкап: ${SETTINGS}.bak)"
  elif [ -n "${HOOK}" ]; then
    warn "python3 не найден — добавь хук в ${SETTINGS} вручную:"
    warn '  "hooks": { "SessionStart": [ { "hooks": [ { "type": "command", "command": "bash '"${HOOK}"'" } ] } ] }'
  fi
else
  warn "Не нашёл папку _BRAIN — хук не ставлю. Если мозг в нестандартном месте, запусти /setup-second-brain."
fi

# --- 4. дописать правила записи в мост (ТОЛЬКО внутри маркеров кита) ---
MARK_BEGIN="<!-- second-brain-kit:begin -->"
MARK_END="<!-- second-brain-kit:end -->"
RULES_BEGIN="<!-- sbk:rules:begin -->"
RULES_END="<!-- sbk:rules:end -->"

RULES_FILE="${TMP}/rules.txt"
{
  printf '%s\n' "${RULES_BEGIN}"
  printf '%s\n' "## Память — записывать находки обратно"
  printf '%s\n' "- Пиши по ходу сессии, не только в конце: как только сформировалась мысль, факт или принято решение — сразу сохраняй, не откладывая."
  printf '%s\n' "- Находку / факт / цифру / метод → \`_BRAIN/Заметки/\` (первая строка — теги \`#источник #тема\`). Инфра/ключи/домены → \`_BRAIN/STACK.md\`."
  printf '%s\n' "- Решение с обоснованием → \`_BRAIN/Решения/\` (ADR). Итог сессии → \`_BRAIN/Выводы/<дата>.md\`."
  printf '%s\n' "- В конце содержательной сессии ОБНОВИ \`_BRAIN/hot.md\` (3–6 строк: над чем работали, следующий шаг, тронутые файлы)."
  printf '%s\n' "- Пиши без лишних вопросов, коротко отчитываясь «сохранил в …». Секреты в \`.md\` не пишем — только указатели. Даты ГГГГ-ММ-ДД."
  printf '%s\n' "${RULES_END}"
} > "${RULES_FILE}"

if [ -f "${GLOBAL_MD}" ] && grep -qF "${MARK_BEGIN}" "${GLOBAL_MD}"; then
  cp -p -- "${GLOBAL_MD}" "${GLOBAL_MD}.bak"
  TMP_MD="$(mktemp)"
  # один проход: вырезаем старый блок правил (если был) и вставляем свежий
  # прямо перед маркером конца блока кита. Остальное — не трогаем.
  awk -v rb="${RULES_BEGIN}" -v re="${RULES_END}" -v me="${MARK_END}" -v rf="${RULES_FILE}" '
    function dump(  l){ while ((getline l < rf) > 0) print l; close(rf) }
    index($0, rb) { inrule=1; next }
    inrule        { if (index($0, re)) inrule=0; next }
    index($0, me) { dump(); print; next }
    { print }
  ' "${GLOBAL_MD}" > "${TMP_MD}"
  mv -- "${TMP_MD}" "${GLOBAL_MD}"
  ok "Правила записи добавлены в мост памяти (бэкап: ${GLOBAL_MD}.bak)"
elif [ -f "${GLOBAL_MD}" ]; then
  warn "В ~/.claude/CLAUDE.md нет маркеров кита (нестандартный/ручной файл) — не трогаю его."
  warn "Хук всё равно несёт правило «обнови hot.md» в каждую сессию — логи писаться будут."
fi

# --- 5. Codex, если есть на машине: те же команды и тот же мозг ---
if [ "${SB_NO_CODEX:-0}" != 1 ] && { [ -d "${HOME}/.codex" ] || command -v codex >/dev/null 2>&1; }; then
  if [ -f "${SRC}/install/install-codex.sh" ] && [ -n "${BRAIN_DIR}" ]; then
    if bash "${SRC}/install/install-codex.sh" "$(dirname "${BRAIN_DIR}")" >/dev/null 2>&1; then
      ok "Codex подключён к тому же мозгу (команды через \$, напр. \$capture)"
      warn "При первом запуске Codex спросит, доверяешь ли новому хуку — ответь да."
    fi
  fi
fi

printf '\n%s\n' "${B}Готово ✓${N}"
printf '%s\n' "Команды обновлены. Хук и правила — см. строки выше."
printf '%s\n' "Перезапусти Claude Code (закрой и открой), чтобы хук подхватился."
