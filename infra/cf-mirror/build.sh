#!/usr/bin/env bash
# Запасные адреса кита: зеркало на Cloudflare (воркер sb-kit) и vasinki.ru.
# Источник один — открытый GitHub. Сначала push в main, потом этот скрипт.
#
#   ./build.sh            # собрать бандл воркера из свежего main
#   ./build.sh --vps      # + выложить тот же кит и скрипты на vasinki.ru (старые установки обновляются оттуда)
#
# Дальше: npx wrangler@3 deploy
set -euo pipefail
cd "$(dirname "$0")"

REPO_TAR="https://github.com/vasin-k-i/second-brain-kit/archive/refs/heads/main.tar.gz"
RAW="https://raw.githubusercontent.com/vasin-k-i/second-brain-kit/main"
VPS_DIR="/opt/vasin-hub/public/sb-lx9wf4cApInIY9VF883j"

rm -rf build; mkdir -p build/src
if [ -n "${KIT_SRC_TAR:-}" ]; then   # свой архив вида GitHub (для выкладки до push)
  cp "${KIT_SRC_TAR}" build/main.tar.gz
else
  echo "→ качаю main с GitHub…"
  curl -fsSL "${REPO_TAR}" -o build/main.tar.gz
fi
tar -xzf build/main.tar.gz -C build/src
# верхняя папка = second-brain-kit/ — её ждут старые update.sh у пользователей
mv build/src/second-brain-kit-main build/src/second-brain-kit
COPYFILE_DISABLE=1 tar -czf build/kit.tar.gz -C build/src second-brain-kit
for f in install.sh install/update.sh install/install-skills.sh install/update.ps1; do
  cp "build/src/second-brain-kit/${f}" "build/$(basename "${f}")"
done
echo "  версия: $(cat build/src/second-brain-kit/VERSION 2>/dev/null || echo '?')"

python3 - <<'PY'
import base64, json, pathlib
data = pathlib.Path('build/kit.tar.gz').read_bytes()
pathlib.Path('kit-b64.js').write_text(
    "// АВТОГЕНЕРАЦИЯ (build.sh) — не править руками.\n"
    f"// kit.tar.gz, {len(data)} байт\n"
    f"export const KIT_B64 = '{base64.b64encode(data).decode()}';\n", encoding='utf-8')
sh = pathlib.Path('build/install.sh').read_text(encoding='utf-8')
pathlib.Path('install-sh.js').write_text(
    "// АВТОГЕНЕРАЦИЯ (build.sh) из install.sh в корне репозитория — не править руками.\n"
    f"export const INSTALL_SH = {json.dumps(sh, ensure_ascii=False)};\n", encoding='utf-8')
print(f"  kit.tar.gz: {len(data)} байт; install.sh: {len(sh)} символов")
PY

if [ "${1:-}" = "--vps" ]; then
  echo "→ выкладываю на vasinki.ru (${VPS_DIR})…"
  SSH="ssh -o ConnectTimeout=15 college-vps"; SCP="scp -o ConnectTimeout=15"
  if ! ${SSH} true 2>/dev/null; then
    SSH="ssh -J biletop-vps college-vps"; SCP="scp -o ProxyJump=biletop-vps"
  fi
  ts="$(date +%Y%m%d-%H%M%S)"
  ${SSH} "cd ${VPS_DIR} && for f in kit.tar.gz install.sh update.sh install-skills.sh update.ps1; do [ -f \$f ] && cp -p \$f \$f.bak.${ts}; done; true"
  ${SCP} build/kit.tar.gz build/install.sh build/update.sh build/install-skills.sh build/update.ps1 "college-vps:${VPS_DIR}/"
  echo "  бэкапы: *.bak.${ts}"
fi

echo "✓ собрано. Деплой зеркала: npx wrangler@3 deploy"
