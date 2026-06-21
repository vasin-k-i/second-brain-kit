#!/usr/bin/env bash
#
# Второй мозг на Claude Code — bootstrap (macOS / Linux)
#
# Что делает (и только это — claude НЕ запускает):
#   1. Проверяет, что установлен `claude`.
#   2. Разворачивает каркас vault-template/_BRAIN/ в выбранную папку,
#      переименовывая *.template.md -> *.md.
#   3. Подключает мост памяти: БЭКАП существующего ~/.claude/CLAUDE.md (.bak)
#      и ДОПИСЫВАНИЕ блока @import горячего ядра (идемпотентно, не затирая).
#   4. Печатает инструкцию: запусти /setup-second-brain.
#
# Идемпотентно: повторный запуск безопасен. Корректно работает с
# кириллическими именами папок (всё в кавычках, IFS не ломаем).
#
set -euo pipefail

# --- цвета (без зависимостей) ---
if [ -t 1 ]; then B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; N=$'\033[0m'; else B=""; G=""; Y=""; R=""; N=""; fi
say()  { printf '%s\n' "$*"; }
ok()   { printf '%s\n' "${G}✓${N} $*"; }
warn() { printf '%s\n' "${Y}!${N} $*"; }
err()  { printf '%s\n' "${R}✗${N} $*" >&2; }

# --- ОС: только для Windows (Git Bash) включаем доп. ветки; на macOS/Linux всё как было ---
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*) IS_WIN=1 ;;
  *)                    IS_WIN=0 ;;
esac

# Windows: прописать %USERPROFILE%\.local\bin в Windows user PATH (идемпотентно),
# чтобы команда `claude` работала в PowerShell/cmd. На macOS/Linux НЕ вызывается.
win_add_path() {
  command -v powershell.exe >/dev/null 2>&1 || return 1
  powershell.exe -NoProfile -Command '$bin = Join-Path $env:USERPROFILE ".local\bin"; $p = [Environment]::GetEnvironmentVariable("Path","User"); if (-not $p) { $p = "" }; if ($p -notlike "*$bin*") { [Environment]::SetEnvironmentVariable("Path", ($p.TrimEnd(";") + ";" + $bin), "User") }' >/dev/null 2>&1
}

# --- путь к репозиторию (директория этого скрипта/..) ---
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd -P)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null 2>&1 && pwd -P)"
TEMPLATE_DIR="${REPO_DIR}/vault-template/_BRAIN"

say ""
say "${B}Устанавливаю «Второй мозг на Claude Code»…${N}"
say ""

# --- 1. проверка claude (НЕ блокируем; авто-чиним частый PATH-кейс ~/.local/bin) ---
CLAUDE_BIN=""
if command -v claude >/dev/null 2>&1; then
  CLAUDE_BIN="$(command -v claude)"
elif [ "${IS_WIN}" = 1 ] && [ -f "${HOME}/.local/bin/claude.exe" ]; then
  # Windows: claude.exe есть, но не в PATH PowerShell → пропишем в Windows user PATH (только Windows)
  CLAUDE_BIN="${HOME}/.local/bin/claude.exe"
  export PATH="${HOME}/.local/bin:${PATH}"
  if win_add_path; then
    ok "Прописал claude в PATH Windows — в новом терминале команда \`claude\` заработает."
  else
    warn "Не смог прописать PATH автоматически — см. шаг 4 в инструкции vasinki.ru/install."
  fi
elif [ -x "${HOME}/.local/bin/claude" ]; then
  CLAUDE_BIN="${HOME}/.local/bin/claude"
  export PATH="${HOME}/.local/bin:${PATH}"
  # дописать PATH в профиль шелла, чтобы `claude` работал в новых терминалах (идемпотентно)
  for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
    case "$rc" in *.zshrc) : ;; *) [ -e "$rc" ] || continue ;; esac   # .zshrc создаём (Mac=zsh), .bashrc — только если есть
    grep -qF '.local/bin' "$rc" 2>/dev/null || printf '\n# второй мозг: claude в PATH\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$rc"
  done
  ok "Добавил ~/.local/bin в PATH — в новом терминале \`claude\` заработает."
fi
if [ -n "${CLAUDE_BIN}" ]; then
  ok "Claude Code найден: ${CLAUDE_BIN}"
else
  warn "Claude Code пока не в PATH — кит всё равно установлю."
  warn "Только что ставил Claude Code? Выполни:  export PATH=\"\$HOME/.local/bin:\$PATH\""
  warn "или открой НОВЫЙ терминал — и команда \`claude\` заработает."
  warn "Ещё не ставил — см. https://code.claude.com/docs/en/setup"
fi

# --- проверка шаблона ---
if [ ! -d "${TEMPLATE_DIR}" ]; then
  err "Не найден каркас: ${TEMPLATE_DIR}"
  say "  Запускай скрипт из распакованного репозитория second-brain-kit."
  exit 1
fi

# --- 2. куда ставим (без интерактива: curl|bash не читает ввод; путь — арг или $SB_VAULT) ---
DEFAULT_VAULT="${HOME}/SecondBrain"
VAULT_DIR="${1:-${SB_VAULT:-${DEFAULT_VAULT}}}"
# раскрытие ведущего ~
case "${VAULT_DIR}" in "~"|"~/"*) VAULT_DIR="${HOME}${VAULT_DIR#\~}";; esac

BRAIN_DIR="${VAULT_DIR}/_BRAIN"
mkdir -p "${BRAIN_DIR}"
ok "Папка с заметками: ${BRAIN_DIR}"

# --- 3. разворачиваем _BRAIN/, *.template.md -> *.md ---
created=0; skipped=0
# find -print0 + read -d '' — безопасно для кириллицы/пробелов в путях
while IFS= read -r -d '' src; do
  rel="${src#"${TEMPLATE_DIR}/"}"          # путь относительно шаблона
  case "${rel}" in
    *.template.md) dst_rel="${rel%.template.md}.md" ;;   # *.template.md -> *.md
    *)             dst_rel="${rel}" ;;                   # прочее — как есть
  esac
  dst="${BRAIN_DIR}/${dst_rel}"
  mkdir -p "$(dirname -- "${dst}")"
  if [ -e "${dst}" ]; then
    skipped=$((skipped+1))                  # не затираем уже наполненное
  else
    cp -p -- "${src}" "${dst}"
    created=$((created+1))
  fi
done < <(find "${TEMPLATE_DIR}" -type f -print0)

ok "Файлов создано: ${created}, пропущено (уже было): ${skipped}"

# --- корневой CLAUDE.md vault (метод), если есть шаблон ---
ROOT_TPL="${REPO_DIR}/vault-template/CLAUDE.template.md"
if [ -f "${ROOT_TPL}" ] && [ ! -e "${VAULT_DIR}/CLAUDE.md" ]; then
  cp -p -- "${ROOT_TPL}" "${VAULT_DIR}/CLAUDE.md"
  ok "Правила работы сохранены: ${VAULT_DIR}/CLAUDE.md"
fi

# --- 4. мост памяти: бэкап + дописать @import (идемпотентно) ---
CLAUDE_CFG_DIR="${HOME}/.claude"
GLOBAL_MD="${CLAUDE_CFG_DIR}/CLAUDE.md"
mkdir -p "${CLAUDE_CFG_DIR}"

MARK_BEGIN="<!-- second-brain-kit:begin -->"
MARK_END="<!-- second-brain-kit:end -->"
RULES_BEGIN="<!-- sbk:rules:begin -->"
RULES_END="<!-- sbk:rules:end -->"

# собираем блок горячего ядра. Ядро (hot/INDEX/STATE/STACK) грузит SessionStart-хук
# (устойчив к облачным путям с пробелами); тут — опорные @import + правила записи,
# которые остаются в силе, даже если @import-путь сломается (перенос в облако).
build_block() {
  printf '%s\n' "${MARK_BEGIN}"
  printf '%s\n' "# Второй мозг — мост памяти (горячее ядро)"
  printf '%s\n' "> Автоподключение через second-brain-kit. Не редактируй между маркерами — перегенерируется бутстрапом."
  printf '%s\n' ""
  printf '%s\n' "Источник правды — твой vault. Ядро (hot/INDEX/STATE/STACK) подгружает SessionStart-хук в каждую сессию. Опорные файлы:"
  printf '%s\n' ""
  for f in STATE.md STACK.md; do
    if [ -e "${BRAIN_DIR}/${f}" ]; then
      printf '@%s\n' "${BRAIN_DIR}/${f}"
    fi
  done
  printf '%s\n' ""
  printf '%s\n' "Метод работы с хранилищем:"
  if [ -e "${VAULT_DIR}/CLAUDE.md" ]; then
    printf '@%s\n' "${VAULT_DIR}/CLAUDE.md"
  fi
  printf '%s\n' ""
  printf '%s\n' "${RULES_BEGIN}"
  printf '%s\n' "## Память — записывать находки обратно"
  printf '%s\n' "- Пиши по ходу сессии, не только в конце: как только сформировалась мысль, факт или принято решение — сразу сохраняй, не откладывая."
  printf '%s\n' "- Находку / факт / цифру / метод → \`_BRAIN/Заметки/\` (первая строка — теги \`#источник #тема\`). Инфра/ключи/домены → \`_BRAIN/STACK.md\`."
  printf '%s\n' "- Решение с обоснованием → \`_BRAIN/Решения/\` (ADR). Итог сессии → \`_BRAIN/Выводы/<дата>.md\`."
  printf '%s\n' "- В конце содержательной сессии ОБНОВИ \`_BRAIN/hot.md\` (3–6 строк: над чем работали, следующий шаг, тронутые файлы)."
  printf '%s\n' "- Пиши без лишних вопросов, коротко отчитываясь «сохранил в …». Секреты в \`.md\` не пишем — только указатели. Даты ГГГГ-ММ-ДД."
  printf '%s\n' "${RULES_END}"
  printf '%s\n' "${MARK_END}"
}

if [ -f "${GLOBAL_MD}" ] && grep -qF "${MARK_BEGIN}" "${GLOBAL_MD}"; then
  # блок уже есть — перегенерируем его содержимое, не трогая остальное (идемпотентно)
  cp -p -- "${GLOBAL_MD}" "${GLOBAL_MD}.bak"
  TMP="$(mktemp)"
  # всё ДО маркера начала
  awk -v b="${MARK_BEGIN}" 'index($0,b){exit} {print}' "${GLOBAL_MD}" > "${TMP}"
  # свежий блок
  build_block >> "${TMP}"
  # всё ПОСЛЕ маркера конца
  awk -v e="${MARK_END}" 'f{print} index($0,e){f=1}' "${GLOBAL_MD}" >> "${TMP}"
  mv -- "${TMP}" "${GLOBAL_MD}"
  ok "Память подключена — Claude будет помнить твой контекст (бэкап старого: ${GLOBAL_MD}.bak)"
elif [ -f "${GLOBAL_MD}" ]; then
  # файл есть, блока нет — бэкап и ДОПИСАТЬ в конец
  cp -p -- "${GLOBAL_MD}" "${GLOBAL_MD}.bak"
  { printf '\n'; build_block; } >> "${GLOBAL_MD}"
  ok "Память подключена — Claude будет помнить твой контекст (бэкап старого: ${GLOBAL_MD}.bak)"
else
  # файла нет — создаём
  build_block > "${GLOBAL_MD}"
  ok "Память подключена — Claude будет помнить твой контекст: ${GLOBAL_MD}"
fi

# --- 4b. SessionStart-хук: движок, который грузит ядро в каждую сессию и
#         напоминает записать итог (без него «второй мозг» не пишет логи) ---
HOOK_TPL="${REPO_DIR}/install/hooks/load-second-brain.sh"
HOOK_DST="${CLAUDE_CFG_DIR}/hooks/load-second-brain.sh"
SETTINGS_FILE="${CLAUDE_CFG_DIR}/settings.json"
if [ -f "${HOOK_TPL}" ]; then
  mkdir -p "${CLAUDE_CFG_DIR}/hooks"
  sed "s#__BRAIN_DIR__#${BRAIN_DIR}#g" "${HOOK_TPL}" > "${HOOK_DST}"
  chmod +x "${HOOK_DST}"
  if command -v python3 >/dev/null 2>&1; then
    [ -f "${SETTINGS_FILE}" ] && cp -p -- "${SETTINGS_FILE}" "${SETTINGS_FILE}.bak"
    python3 - "${SETTINGS_FILE}" "bash ${HOOK_DST}" <<'PY'
import json, os, sys
sf, cmd = sys.argv[1], sys.argv[2]
os.makedirs(os.path.dirname(sf), exist_ok=True)
try:
    s = json.load(open(sf)); assert isinstance(s, dict)
except Exception:
    s = {}
ss = s.setdefault("hooks", {}).setdefault("SessionStart", [])
if not any("load-second-brain" in h.get("command", "")
           for grp in ss for h in grp.get("hooks", [])):
    ss.append({"hooks": [{"type": "command", "command": cmd}]})
json.dump(s, open(sf, "w"), ensure_ascii=False, indent=2)
PY
    ok "Движок памяти подключён — контекст грузится сам, в конце сессии Claude обновляет hot.md."
  else
    warn "python3 не найден — хук создан (${HOOK_DST}), но не прописан в settings.json."
    warn "Запусти /setup-second-brain или добавь SessionStart-хук вручную."
  fi
fi

# --- 5. скиллы → ~/.claude/skills/ (чистые /команды, без маркетплейса) ---
SKILLS_DST="${CLAUDE_CFG_DIR}/skills"
mkdir -p "${SKILLS_DST}"
sk_copied=0; sk_skipped=0
for d in "${REPO_DIR}/skills"/*/ "${REPO_DIR}/plugins/content/skills"/*/; do
  [ -d "${d}" ] && [ -f "${d}SKILL.md" ] || continue
  name="$(basename -- "${d}")"
  if [ -e "${SKILLS_DST}/${name}" ]; then
    sk_skipped=$((sk_skipped+1))
  else
    cp -R -- "${d%/}" "${SKILLS_DST}/${name}"
    sk_copied=$((sk_copied+1))
  fi
done
ok "Команды-помощники установлены: ${sk_copied} (пропущено ${sk_skipped}) → ${SKILLS_DST}"

# --- 6. pre-grant прав на папку второго мозга (чтобы /setup не переспрашивал на каждый файл) ---
SETTINGS_FILE="${CLAUDE_CFG_DIR}/settings.json"
if command -v python3 >/dev/null 2>&1; then
  python3 - "${VAULT_DIR}" "${HOME}" "${SETTINGS_FILE}" <<'PY'
import json, os, sys
vault, home, sf = sys.argv[1], sys.argv[2], sys.argv[3]
rel = "~" + vault[len(home):] if (vault == home or vault.startswith(home + os.sep)) else vault
os.makedirs(os.path.dirname(sf), exist_ok=True)
try:
    s = json.load(open(sf)); assert isinstance(s, dict)
except Exception:
    s = {}
p = s.setdefault("permissions", {})
ad = p.setdefault("additionalDirectories", [])
if rel not in ad: ad.append(rel)
al = p.setdefault("allow", [])
for r in (f"Read({rel}/**)", f"Edit({rel}/**)", f"Write({rel}/**)", "Bash(ls:*)", "Bash(cat:*)"):
    if r not in al: al.append(r)
json.dump(s, open(sf, "w"), ensure_ascii=False, indent=2)
PY
  ok "Доступ к твоим заметкам выдан — настройка пойдёт без лишних вопросов."
else
  warn "python3 не найден — во время настройки жми «Always allow» (безопасно, правит только твои заметки)."
fi

# --- финал ---
say ""
say "${B}Готово ✓ Заметки, память и команды-помощники установлены.${N}"
say "Второй мозг:  ${VAULT_DIR}"
say "Команды:      ${SKILLS_DST}"
say ""
if [ -z "${CLAUDE_BIN}" ]; then
  say "${Y}Сначала открой НОВЫЙ терминал — тогда заработает команда ${G}claude${N}${Y} (обновится PATH).${N}"
  say ""
fi
say "${B}Последний шаг — открой приложение Claude Code (вкладка «Code»)${N}"
say "${B}или набери ${G}claude${N}${B} в терминале, и запусти:${N}"
say "    ${G}/setup-second-brain${N}"
say ""
say "Claude задаст пару вопросов (первым — где хранить второй мозг: на"
say "компьютере или в облаке) и наполнит его под тебя."
