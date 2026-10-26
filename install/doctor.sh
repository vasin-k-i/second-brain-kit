#!/usr/bin/env bash
#
# «Второй мозг» — проверка установки (и починка).
#
#   bash ~/.second-brain-kit/install/doctor.sh          # только проверить
#   bash ~/.second-brain-kit/install/doctor.sh --fix    # проверить и починить
#
# Зачем: когда что-то отваливается (хук не зарегистрирован, мозг переехал в облако,
# скиллы встали частично), это НЕ видно — просто «Claude меня не помнит». Доктор
# показывает каждое звено цепочки: где мозг → мост → движок памяти → команды.
set -uo pipefail

FIX=0
[ "${1:-}" = "--fix" ] && FIX=1

if [ -t 1 ]; then B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; N=$'\033[0m'; else B=""; G=""; Y=""; R=""; N=""; fi
ok()   { printf '%s\n' "${G}✓${N} $*"; }
warn() { printf '%s\n' "${Y}!${N} $*"; WARNS=$((WARNS+1)); }
bad()  { printf '%s\n' "${R}✗${N} $*"; ERRS=$((ERRS+1)); }
info() { printf '%s\n' "  $*"; }
head_() { printf '\n%s\n' "${B}$*${N}"; }
WARNS=0; ERRS=0; FIXED=0

CFG="${HOME}/.claude"
GLOBAL_MD="${CFG}/CLAUDE.md"
SETTINGS="${CFG}/settings.json"
SKILLS="${CFG}/skills"
HOOK="${CFG}/hooks/load-second-brain.sh"
KIT="${HOME}/.second-brain-kit"
VERSION_STAMP="${CFG}/.sbk-version"
BACKUP_ROOT="${CFG}/sbk-backups"

printf '%s\n' "${B}Проверяю «Второй мозг»…${N}"

# ---------- 1. Claude Code ----------
head_ "1. Claude Code"
if command -v claude >/dev/null 2>&1; then
  ok "команда claude есть: $(command -v claude)"
elif [ -x "${HOME}/.local/bin/claude" ] || [ -f "${HOME}/.local/bin/claude.exe" ]; then
  warn "claude установлен, но не в PATH. Открой НОВЫЙ терминал или выполни: export PATH=\"\$HOME/.local/bin:\$PATH\""
else
  warn "claude не найден. Поставь Claude Code: https://code.claude.com/docs/en/setup"
fi

# ---------- 2. где мозг ----------
head_ "2. Где лежит второй мозг"
BRAIN=""
if [ -f "${GLOBAL_MD}" ]; then
  ref="$(grep -oE '@[^[:space:]]+/_BRAIN/[A-Za-z0-9._-]+\.md' "${GLOBAL_MD}" 2>/dev/null | head -1 || true)"
  [ -n "${ref}" ] && BRAIN="$(dirname "${ref#@}")"
fi
# хук — второй источник правды о пути
HOOK_BRAIN=""
[ -f "${HOOK}" ] && HOOK_BRAIN="$(grep -m1 '^BRAIN=' "${HOOK}" 2>/dev/null | sed 's/^BRAIN="//; s/"$//' || true)"
[ -n "${BRAIN}" ] && [ ! -d "${BRAIN}" ] && BRAIN=""
if [ -z "${BRAIN}" ] && [ -n "${HOOK_BRAIN}" ] && [ -d "${HOOK_BRAIN}" ]; then BRAIN="${HOOK_BRAIN}"; fi
# Мозг могли перенести и переименовать (частый случай — переезд в облако),
# поэтому не только стандартные пути: ищем папку _BRAIN по типовым корням.
find_brain() {
  local root depth found
  for spec in "${HOME}:3" \
              "${HOME}/Library/Mobile Documents:5" \
              "${HOME}/Documents:3" "${HOME}/Desktop:3" \
              "${HOME}/Yandex.Disk.localized:3" "${HOME}/YandexDisk:3" \
              "${HOME}/Google Drive:3" "${HOME}/Dropbox:3" "${HOME}/OneDrive:3"; do
    root="${spec%:*}"; depth="${spec##*:}"
    [ -d "${root}" ] || continue
    found="$(find "${root}" -maxdepth "${depth}" \
              \( -name node_modules -o -name .git -o -name Caches -o -name .Trash \) -prune -o \
              -type d -name _BRAIN -print 2>/dev/null | head -5)"
    while IFS= read -r c; do
      [ -n "${c}" ] || continue
      # настоящий мозг — тот, где лежит ядро
      { [ -f "${c}/INDEX.md" ] || [ -f "${c}/hot.md" ] || [ -f "${c}/STATE.md" ]; } && { printf '%s' "${c}"; return 0; }
    done <<EOF
${found}
EOF
  done
  return 1
}
if [ -z "${BRAIN}" ]; then
  BRAIN="$(find_brain || true)"
  [ -n "${BRAIN}" ] && warn "мозг нашёлся не там, где записано в настройках: ${BRAIN}"
fi
if [ -n "${BRAIN}" ] && [ -d "${BRAIN}" ]; then
  ok "мозг здесь: ${BRAIN}"
  info "заметок в ядре: $(ls "${BRAIN}"/*.md 2>/dev/null | wc -l | tr -d ' ')"
else
  bad "не нашёл папку _BRAIN — мозг не развёрнут или лежит в нестандартном месте."
  info "Разверни: bash ${KIT}/install/install.sh «/путь/к/папке»  (или запусти /setup-second-brain)"
fi

# --fix: мозг найден, но настройки указывают не туда (переехал/переименовали) —
# перепривязываем разом мост, движок и права, переустановкой поверх (она идемпотентна).
if [ "${FIX}" = 1 ] && [ -n "${BRAIN}" ] && [ -d "${BRAIN}" ] && [ -f "${KIT}/install/install.sh" ]; then
  need=0
  grep -qF "${BRAIN}" "${GLOBAL_MD}" 2>/dev/null || need=1
  [ "${HOOK_BRAIN}" != "${BRAIN}" ] && need=1
  if [ "${need}" = 1 ]; then
    if bash "${KIT}/install/install.sh" "$(dirname "${BRAIN}")" >/dev/null 2>&1; then
      ok "перепривязал мост и движок памяти к ${BRAIN}"
      FIXED=$((FIXED+1))
      HOOK_BRAIN="$(grep -m1 '^BRAIN=' "${HOOK}" 2>/dev/null | sed 's/^BRAIN="//; s/"$//' || true)"
    else
      warn "не смог перепривязать автоматически — запусти: bash ${KIT}/install/install.sh «$(dirname "${BRAIN}")»"
    fi
  fi
fi

# незаполненные плейсхолдеры = /setup-second-brain не прогоняли
if [ -n "${BRAIN}" ] && [ -d "${BRAIN}" ]; then
  ph=$(grep -rl '{{' "${BRAIN}"/*.md 2>/dev/null | wc -l | tr -d ' ')
  [ "${ph}" -gt 0 ] && warn "в ${ph} файлах ядра остались шаблонные {{плейсхолдеры}} — запусти /setup-second-brain, чтобы наполнить под себя"
fi

# ---------- 3. мост памяти ----------
head_ "3. Мост памяти (~/.claude/CLAUDE.md)"
if [ -f "${GLOBAL_MD}" ] && grep -qF 'second-brain-kit:begin' "${GLOBAL_MD}"; then
  ok "мост на месте"
  dead=0
  while IFS= read -r p; do
    p="${p#@}"; case "${p}" in "~/"*) p="${HOME}/${p#\~/}" ;; esac
    [ -e "${p}" ] || { warn "мост ссылается на несуществующий файл: ${p}"; dead=1; }
  done < <(sed -n '/second-brain-kit:begin/,/second-brain-kit:end/p' "${GLOBAL_MD}" | grep -E '^@' || true)
  [ "${dead}" = 0 ] && ok "все @-ссылки моста живые"
elif [ -f "${GLOBAL_MD}" ]; then
  warn "файл есть, но блока кита в нём нет (ставили руками?) — переустанови: bash ${KIT}/install/install.sh"
else
  bad "нет ~/.claude/CLAUDE.md — мост не подключён"
fi

# ---------- 4. движок памяти (SessionStart-хук) ----------
head_ "4. Движок памяти (хук SessionStart)"
if [ ! -f "${HOOK}" ]; then
  bad "хук не установлен — контекст НЕ грузится сам в сессию"
else
  ok "файл хука есть"
  if [ -n "${HOOK_BRAIN}" ] && [ ! -d "${HOOK_BRAIN}" ]; then
    bad "хук смотрит на несуществующий путь: ${HOOK_BRAIN}"
    info "так бывает после переезда мозга в облако"
    if [ "${FIX}" = 1 ] && [ -n "${BRAIN}" ]; then
      cp -p "${HOOK}" "${HOOK}.bak" 2>/dev/null
      awk -v b="${BRAIN}" 'NR==1||!/^BRAIN=/{print;next}{print "BRAIN=\"" b "\""}' "${HOOK}" > "${HOOK}.tmp" && mv "${HOOK}.tmp" "${HOOK}"
      chmod +x "${HOOK}"; ok "починил путь в хуке → ${BRAIN}"; FIXED=$((FIXED+1))
    fi
  elif [ -n "${HOOK_BRAIN}" ]; then
    ok "путь в хуке валиден"
  fi
  out="$(bash "${HOOK}" 2>/dev/null | head -c 400)"
  if [ -n "${out}" ]; then ok "хук запускается и отдаёт контекст"; else bad "хук ничего не печатает — контекст пустой"; fi
fi

reg=0
if [ -f "${SETTINGS}" ] && command -v python3 >/dev/null 2>&1; then
  reg=$(python3 - "${SETTINGS}" <<'PY' 2>/dev/null || echo 0
import json,sys
try: s=json.load(open(sys.argv[1]))
except Exception: print(0); raise SystemExit
print(1 if any("load-second-brain" in h.get("command","")
    for g in s.get("hooks",{}).get("SessionStart",[]) for h in g.get("hooks",[])) else 0)
PY
)
fi
if [ "${reg}" = 1 ]; then
  ok "хук зарегистрирован в settings.json"
else
  bad "хук НЕ зарегистрирован в ~/.claude/settings.json — он не сработает"
  if [ "${FIX}" = 1 ] && [ -f "${HOOK}" ] && command -v python3 >/dev/null 2>&1; then
    [ -f "${SETTINGS}" ] && cp -p "${SETTINGS}" "${SETTINGS}.bak"
    python3 - "${SETTINGS}" "bash ${HOOK}" <<'PY'
import json,os,sys
sf,cmd=sys.argv[1],sys.argv[2]
os.makedirs(os.path.dirname(sf),exist_ok=True)
try: s=json.load(open(sf)); assert isinstance(s,dict)
except Exception: s={}
ss=s.setdefault("hooks",{}).setdefault("SessionStart",[])
if not any("load-second-brain" in h.get("command","") for g in ss for h in g.get("hooks",[])):
    ss.append({"hooks":[{"type":"command","command":cmd}]})
json.dump(s,open(sf,"w"),ensure_ascii=False,indent=2)
PY
    ok "зарегистрировал хук"; FIXED=$((FIXED+1))
  fi
fi

# ---------- 5. вес ядра ----------
head_ "5. Вес ядра (грузится в КАЖДУЮ сессию)"
if [ -n "${BRAIN}" ] && [ -d "${BRAIN}" ]; then
  tot=0
  for f in hot.md INDEX.md STATE.md STACK.md; do
    [ -f "${BRAIN}/${f}" ] || continue
    s=$(LC_ALL=C wc -c < "${BRAIN}/${f}" | tr -d ' '); tot=$((tot+s))
    [ "${s}" -gt 20000 ] && warn "${f}: ${s} байт — будет обрезан при загрузке, разнеси старое по Заметкам/Архиву"
  done
  info "всего ядро: ${tot} байт"
  [ "${tot}" -gt 60000 ] && warn "ядро тяжёлое (>60 КБ) — часть не влезет в автозагрузку"
  [ "${tot}" -le 60000 ] && ok "вес в норме"
fi

# ---------- 6. команды-помощники ----------
head_ "6. Команды-помощники (скиллы)"
n=$(ls -d "${SKILLS}"/*/ 2>/dev/null | wc -l | tr -d ' ')
if [ "${n}" -ge 15 ]; then ok "установлено скиллов: ${n}"
elif [ "${n}" -gt 0 ]; then warn "скиллов только ${n} (ожидается ~19) — обнови: bash ${KIT}/install/install-skills.sh"
else bad "скиллов нет — команды /capture, /find и остальные не появятся"; fi

# ---------- 7. Codex ----------
head_ "7. Codex (если пользуешься)"
if [ -d "${HOME}/.codex" ] || command -v codex >/dev/null 2>&1; then
  cs=0
  for d in "${HOME}/.codex/skills" "${HOME}/.agents/skills"; do
    [ -d "${d}" ] && cs=$((cs + $(ls -d "${d}"/*/ 2>/dev/null | wc -l | tr -d ' ')))
  done
  [ "${cs}" -gt 0 ] && ok "скиллы в Codex: ${cs}" || warn "Codex есть, но кит к нему не подключён"
  if [ -f "${HOME}/.codex/AGENTS.md" ] && grep -qF 'second-brain-kit:begin' "${HOME}/.codex/AGENTS.md" 2>/dev/null; then
    ok "мост памяти Codex (~/.codex/AGENTS.md) на месте"
  else
    warn "нет моста памяти для Codex"
  fi
  if [ "${cs}" = 0 ] || ! grep -qF 'second-brain-kit:begin' "${HOME}/.codex/AGENTS.md" 2>/dev/null; then
    if [ "${FIX}" = 1 ] && [ -f "${KIT}/install/install-codex.sh" ]; then
      bash "${KIT}/install/install-codex.sh" >/dev/null 2>&1 && { ok "подключил кит к Codex"; FIXED=$((FIXED+1)); }
    else
      info "подключить: bash ${KIT}/install/install-codex.sh"
    fi
  fi
else
  info "Codex не установлен — пропускаю"
fi

# ---------- 8. версия кита и бэкапы скиллов ----------
head_ "8. Версия кита и бэкапы скиллов"
if [ -f "${VERSION_STAMP}" ]; then
  ver="$(grep -m1 '^version=' "${VERSION_STAMP}" 2>/dev/null | cut -d= -f2- || true)"
  inst="$(grep -m1 '^installed_at=' "${VERSION_STAMP}" 2>/dev/null | cut -d= -f2- || true)"
  if [ -n "${ver}" ] && [ "${ver}" != "unknown" ]; then
    ok "версия кита: ${ver}"
  else
    warn "версия в штампе не определена (version=unknown) — обнови кит, чтобы проставилась"
  fi
  [ -n "${inst}" ] && info "установлен/обновлён: ${inst}"
else
  warn "версия не определена (кит установлен до внедрения версионирования, или версия-файл повреждён)"
  info "штамп появится при следующем обновлении кита → ${VERSION_STAMP}"
fi
if [ -d "${BACKUP_ROOT}" ]; then
  snaps=$(ls -d "${BACKUP_ROOT}"/*/ 2>/dev/null | wc -l | tr -d ' ')
  if [ "${snaps}" -gt 0 ]; then
    info "бэкапы скиллов: ${snaps} снимк(ов) в ${BACKUP_ROOT}"
    info "это прежние версии скиллов, сохранённые перед обновлением — там твои ручные правки, если обновление их затёрло"
  fi
fi

# ---------- итог ----------
head_ "Итог"
if [ "${ERRS}" = 0 ] && [ "${WARNS}" = 0 ]; then
  ok "всё на месте, второй мозг работает"
else
  printf '%s\n' "проблем: ${ERRS}, предупреждений: ${WARNS}"
  [ "${FIXED}" -gt 0 ] && ok "починено автоматически: ${FIXED} (перезапусти Claude Code)"
  [ "${FIX}" = 0 ] && [ "${ERRS}" -gt 0 ] && printf '%s\n' "Попробовать починить: ${G}bash ${KIT}/install/doctor.sh --fix${N}"
fi
exit 0
