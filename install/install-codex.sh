#!/usr/bin/env bash
#
# «Второй мозг» — подключение к OpenAI Codex (в дополнение к Claude Code).
#
#   bash ~/.second-brain-kit/install/install-codex.sh [/путь/к/мозгу]
#
# Что делает:
#   1. Кладёт те же команды-помощники в скиллы Codex (~/.codex/skills и ~/.agents/skills —
#      разные версии Codex смотрят в разные папки, поэтому кладём в обе).
#   2. Пишет мост памяти в ~/.codex/AGENTS.md (глобальные инструкции Codex) — идемпотентно,
#      только внутри своих маркеров, чужой текст не трогает.
#   3. Ставит SessionStart-хук: тот же движок, что в Claude Code, но вывод заворачивается
#      в JSON-протокол Codex (hookSpecificOutput.additionalContext), и регистрирует его
#      в ~/.codex/config.toml.
#
# Мозг (заметки) НЕ трогает и никуда не переносит — он общий у Claude Code и Codex.
set -euo pipefail

if [ -t 1 ]; then B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; N=$'\033[0m'; else B=""; G=""; Y=""; R=""; N=""; fi
ok()   { printf '%s\n' "${G}✓${N} $*"; }
warn() { printf '%s\n' "${Y}!${N} $*"; }
err()  { printf '%s\n' "${R}✗${N} $*" >&2; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd -P)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null 2>&1 && pwd -P)"

CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
AGENTS_MD="${CODEX_HOME}/AGENTS.md"
CONFIG_TOML="${CODEX_HOME}/config.toml"
HOOKS_DIR="${CODEX_HOME}/hooks"

printf '\n%s\n\n' "${B}Подключаю «Второй мозг» к Codex…${N}"

# --- 1. где мозг: аргумент → мост Claude → хук Claude → стандартные места ---
BRAIN="${1:-}"
case "${BRAIN}" in "~"|"~/"*) BRAIN="${HOME}${BRAIN#\~}";; esac
[ -n "${BRAIN}" ] && [ -d "${BRAIN}/_BRAIN" ] && BRAIN="${BRAIN}/_BRAIN"
if [ -z "${BRAIN}" ] && [ -f "${HOME}/.claude/CLAUDE.md" ]; then
  ref="$(grep -oE '@[^[:space:]]+/_BRAIN/[A-Za-z0-9._-]+\.md' "${HOME}/.claude/CLAUDE.md" 2>/dev/null | head -1 || true)"
  [ -n "${ref}" ] && BRAIN="$(dirname "${ref#@}")"
fi
if [ -z "${BRAIN}" ] || [ ! -d "${BRAIN}" ]; then
  h="${HOME}/.claude/hooks/load-second-brain.sh"
  [ -f "${h}" ] && BRAIN="$(grep -m1 '^BRAIN=' "${h}" 2>/dev/null | sed 's/^BRAIN="//; s/"$//' || true)"
fi
if [ -z "${BRAIN}" ] || [ ! -d "${BRAIN}" ]; then
  for c in "${HOME}/SecondBrain/_BRAIN" "${HOME}/Second Brain/_BRAIN"; do
    [ -d "${c}" ] && { BRAIN="${c}"; break; }
  done
fi
if [ -z "${BRAIN}" ] || [ ! -d "${BRAIN}" ]; then
  err "Не нашёл папку _BRAIN. Сначала поставь кит (install.sh) или укажи путь:"
  err "  bash $0 «/путь/к/папке-мозга»"
  exit 1
fi
VAULT="$(dirname "${BRAIN}")"
ok "Мозг: ${BRAIN}"

mkdir -p "${CODEX_HOME}" "${HOOKS_DIR}"

# --- 2. скиллы в обе папки, куда смотрят разные версии Codex ---
copied=0
for dst in "${CODEX_HOME}/skills" "${HOME}/.agents/skills"; do
  mkdir -p "${dst}"
  for d in "${REPO_DIR}/skills"/*/ "${REPO_DIR}/plugins/content/skills"/*/; do
    [ -d "${d}" ] && [ -f "${d}SKILL.md" ] || continue
    name="$(basename -- "${d}")"
    rm -rf -- "${dst}/${name}"
    cp -R -- "${d%/}" "${dst}/${name}"
    copied=$((copied+1))
  done
done
ok "Команды-помощники в Codex: $((copied/2)) → ${CODEX_HOME}/skills и ~/.agents/skills"

# --- 3. мост памяти: ~/.codex/AGENTS.md (глобальные инструкции Codex) ---
# ⚠️ У Codex общий бюджет на AGENTS.md ~32 КБ, поэтому сюда кладём КОРОТКИЙ мост —
# сами файлы ядра подгружает хук, а не этот файл.
MARK_BEGIN="<!-- second-brain-kit:begin -->"
MARK_END="<!-- second-brain-kit:end -->"

build_bridge() {
  printf '%s\n' "${MARK_BEGIN}"
  printf '%s\n' "# Второй мозг — мост памяти (Codex)"
  printf '%s\n' "> Автоподключение через second-brain-kit. Не редактируй между маркерами — перегенерируется установщиком."
  printf '%s\n' ""
  printf '%s\n' "Источник правды по контексту пользователя — его хранилище:"
  printf '%s\n' "- заметки и ядро: \`${BRAIN}\`"
  printf '%s\n' "- метод работы с хранилищем: \`${VAULT}/CLAUDE.md\`"
  printf '%s\n' ""
  printf '%s\n' "Ядро (hot.md / INDEX.md / STATE.md / STACK.md) подгружает SessionStart-хук в начале сессии."
  printf '%s\n' "Если в контексте его нет (хук не одобрен или отключён) — прочитай эти четыре файла сам, прежде чем отвечать по делу."
  printf '%s\n' ""
  printf '%s\n' "## Память — записывать находки обратно"
  printf '%s\n' "- Пиши по ходу сессии, не только в конце: сформировалась мысль, факт или решение — сразу сохраняй."
  printf '%s\n' "- Находку / факт / цифру / метод → \`_BRAIN/Заметки/\` (первая строка — теги \`#источник #тема\`). Инфра/ключи/домены → \`_BRAIN/STACK.md\`."
  printf '%s\n' "- Решение с обоснованием → \`_BRAIN/Решения/\` (ADR). Итог сессии → \`_BRAIN/Выводы/<дата>.md\`."
  printf '%s\n' "- В конце содержательной сессии ОБНОВИ \`_BRAIN/hot.md\` (3–6 строк: над чем работали, следующий шаг, тронутые файлы)."
  printf '%s\n' "- Пиши без лишних вопросов, коротко отчитываясь «сохранил в …». Секреты в \`.md\` не пишем — только указатели. Даты ГГГГ-ММ-ДД."
  printf '%s\n' "${MARK_END}"
}

if [ -f "${AGENTS_MD}" ] && grep -qF "${MARK_BEGIN}" "${AGENTS_MD}"; then
  cp -p -- "${AGENTS_MD}" "${AGENTS_MD}.bak"
  TMP="$(mktemp)"
  awk -v b="${MARK_BEGIN}" 'index($0,b){exit} {print}' "${AGENTS_MD}" > "${TMP}"
  build_bridge >> "${TMP}"
  awk -v e="${MARK_END}" 'f{print} index($0,e){f=1}' "${AGENTS_MD}" >> "${TMP}"
  mv -- "${TMP}" "${AGENTS_MD}"
  ok "Мост памяти Codex обновлён (бэкап: ${AGENTS_MD}.bak)"
elif [ -f "${AGENTS_MD}" ]; then
  cp -p -- "${AGENTS_MD}" "${AGENTS_MD}.bak"
  { printf '\n'; build_bridge; } >> "${AGENTS_MD}"
  ok "Мост памяти дописан в ${AGENTS_MD} (бэкап: ${AGENTS_MD}.bak)"
else
  build_bridge > "${AGENTS_MD}"
  ok "Мост памяти создан: ${AGENTS_MD}"
fi

# --- 4. хук: тот же движок + обёртка в JSON-протокол Codex ---
CORE_HOOK="${HOOKS_DIR}/load-second-brain.sh"
WRAP_HOOK="${HOOKS_DIR}/codex-session-start.sh"
if [ -f "${REPO_DIR}/install/hooks/load-second-brain.sh" ]; then
  sed "s#__BRAIN_DIR__#${BRAIN}#g" "${REPO_DIR}/install/hooks/load-second-brain.sh" > "${CORE_HOOK}"
  chmod +x "${CORE_HOOK}"
else
  err "Не найден шаблон хука в ките — пропускаю движок памяти."; CORE_HOOK=""
fi

if [ -n "${CORE_HOOK}" ]; then
  # Codex ждёт на stdout JSON: {"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"…"}}
  cat > "${WRAP_HOOK}" <<'WRAP'
#!/usr/bin/env bash
# Обёртка для Codex: берёт вывод общего движка памяти и отдаёт его в JSON-протоколе
# Codex (hookSpecificOutput.additionalContext). Тело контекста — в load-second-brain.sh.
set -uo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd -P)"
BODY="$(bash "${DIR}/load-second-brain.sh" 2>/dev/null || true)"
[ -n "${BODY}" ] || exit 0
if command -v python3 >/dev/null 2>&1; then
  BODY="${BODY}" python3 -c 'import json,os;print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":os.environ["BODY"]}},ensure_ascii=False))'
else
  printf '%s\n' "${BODY}"   # без python3 — отдаём как есть, часть версий Codex примет и так
fi
WRAP
  chmod +x "${WRAP_HOOK}"
  ok "Движок памяти для Codex: ${WRAP_HOOK}"

  # регистрация в config.toml
  HOOK_CMD="bash ${WRAP_HOOK}"
  if [ -f "${CONFIG_TOML}" ] && grep -qE 'load-second-brain|codex-session-start' "${CONFIG_TOML}"; then
    ok "Хук уже прописан в ${CONFIG_TOML}"
  elif [ -f "${CONFIG_TOML}" ] && grep -qE '^\[\[?hooks' "${CONFIG_TOML}"; then
    cp -p -- "${CONFIG_TOML}" "${CONFIG_TOML}.bak"
    warn "В config.toml уже есть свои хуки — не трогаю, чтобы не сломать. Добавь вручную:"
    printf '\n  [[hooks.SessionStart]]\n  [[hooks.SessionStart.hooks]]\n  type = "command"\n  command = "%s"\n\n' "${HOOK_CMD}"
  else
    [ -f "${CONFIG_TOML}" ] && cp -p -- "${CONFIG_TOML}" "${CONFIG_TOML}.bak"
    {
      printf '\n# второй мозг: подгрузка ядра в начале сессии (second-brain-kit)\n'
      printf '[[hooks.SessionStart]]\n[[hooks.SessionStart.hooks]]\ntype = "command"\ncommand = "%s"\n' "${HOOK_CMD}"
    } >> "${CONFIG_TOML}"
    ok "Хук прописан в ${CONFIG_TOML}"
  fi
fi

printf '\n%s\n' "${B}Готово ✓ Второй мозг подключён к Codex.${N}"
printf '%s\n' "Мозг общий с Claude Code — заметки одни и те же, править можно откуда угодно."
printf '\n%s\n' "${Y}Важно:${N} при первом запуске Codex спросит, доверяешь ли ты новому хуку —"
printf '%s\n' "ответь да, иначе контекст не будет подгружаться сам."
printf '%s\n' "Команды-помощники в Codex вызываются через \$ (например \$capture, \$find) или /skills."
