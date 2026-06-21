#!/usr/bin/env bash
#
# «Второй мозг» — ОБНОВЛЕНИЕ для тех, кто уже установил кит.
#
# Что делает (и ТОЛЬКО это, аккуратно и идемпотентно):
#   1. Обновляет/перезаписывает скиллы в ~/.claude/skills/ (в т.ч. новый writer + seo-manager).
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

KIT_URL="${SB_KIT_URL:-https://github.com/vasin-k-i/second-brain-kit/archive/refs/heads/main.tar.gz}"
case "${KIT_URL}" in http*://*) : ;; *) echo "✗ KIT_URL не задан" >&2; exit 1 ;; esac
command -v curl >/dev/null 2>&1 || { echo "✗ нужен curl" >&2; exit 1; }
command -v tar  >/dev/null 2>&1 || { echo "✗ нужен tar"  >&2; exit 1; }

CFG="${HOME}/.claude"
GLOBAL_MD="${CFG}/CLAUDE.md"
SETTINGS="${CFG}/settings.json"
HOOKS_DST="${CFG}/hooks"
SKILLS_DST="${CFG}/skills"

# Windows/schannel: смягчаем падение на проверке отзыва сертификата (CRYPT_E_NO_REVOCATION_CHECK)
CURL="curl -fsSL"
curl -V 2>/dev/null | grep -qi schannel && CURL="${CURL} --ssl-no-revoke"

TMP="$(mktemp -d)"; trap 'rm -rf "${TMP}"' EXIT
printf '%s\n' "${B}Обновляю «Второй мозг»…${N}"
${CURL} "${KIT_URL}" -o "${TMP}/kit.tar.gz"
tar -xzf "${TMP}/kit.tar.gz" -C "${TMP}" 2>/dev/null
SRC="${TMP}/second-brain-kit"
[ -d "${SRC}" ] || SRC="$(dirname "$(find "${TMP}" -name install -type d | head -1)")"

# --- 1. скиллы: перезаписываем (чиним старые/частичные, доставляем новые) ---
mkdir -p "${SKILLS_DST}"
copied=0
for d in "${SRC}/skills"/*/ "${SRC}/plugins/content/skills"/*/; do
  [ -d "${d}" ] && [ -f "${d}SKILL.md" ] || continue
  name="$(basename -- "${d}")"
  rm -rf -- "${SKILLS_DST}/${name}"
  cp -R -- "${d%/}" "${SKILLS_DST}/${name}"
  copied=$((copied+1))
done
ok "Скиллы обновлены: ${copied} → ${SKILLS_DST} (writer и seo-manager — свежие)"

# проверка, что полный writer реально лёг (а не остался старый)
if [ -f "${SKILLS_DST}/writer/references/role-full.md" ]; then
  ok "writer: полная версия (Ильяхов) на месте → ${SKILLS_DST}/writer"
else
  warn "writer без references/role-full.md — что-то перетёрло. Содержимое: $(ls "${SKILLS_DST}/writer" 2>/dev/null | tr '\n' ' ')"
fi
# «теневые» копии writer (плагин/проект) — могут перекрывать новый в UI
shadows="$(find "${HOME}/.claude" -type d -name writer 2>/dev/null | grep -vx "${SKILLS_DST}/writer" || true)"
if [ -n "${shadows}" ]; then
  warn "Нашёл другие копии writer — если в Claude/Cowork виден СТАРЫЙ, он берётся отсюда:"
  printf '%s\n' "${shadows}" | while IFS= read -r s; do
    [ -f "${s}/references/role-full.md" ] && tag="(тоже новый)" || tag="(СТАРЫЙ — перекрывает!)"
    warn "  ${s} ${tag}"
  done
  warn "Скажи — добавлю их перезапись в апдейт."
fi

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

printf '\n%s\n' "${B}Готово ✓${N}"
printf '%s\n' "Скиллы обновлены (writer/seo-manager — свежие). Хук и правила — см. строки выше."
printf '%s\n' "Перезапусти Claude Code (закрой и открой), чтобы хук подхватился."
