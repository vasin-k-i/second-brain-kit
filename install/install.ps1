<#
  Второй мозг на Claude Code — bootstrap (Windows / PowerShell)

  Что делает (и только это — claude НЕ запускает):
    1. Проверяет, что установлен `claude`.
    2. Разворачивает каркас vault-template\_BRAIN\ в выбранную папку,
       переименовывая *.template.md -> *.md.
    3. Подключает мост памяти: БЭКАП существующего %USERPROFILE%\.claude\CLAUDE.md (.bak)
       и ДОПИСЫВАНИЕ блока @import горячего ядра (идемпотентно, не затирая).
    4. Печатает инструкцию: запусти /setup-second-brain.

  Идемпотентно: повторный запуск безопасен. Корректно работает с
  кириллическими именами папок (UTF-8 на чтение/запись).

  Запуск:
    powershell -ExecutionPolicy Bypass -File .\install\install.ps1
    # опц. путь vault:  ... -File .\install\install.ps1 -VaultDir "C:\Users\Имя\SecondBrain"
#>
[CmdletBinding()]
param(
  [string]$VaultDir = ""
)

$ErrorActionPreference = "Stop"
# UTF-8 без BOM для записи (важно для кириллицы и @import-путей)
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Say  ($m) { Write-Host $m }
function Ok   ($m) { Write-Host "[ok] $m"   -ForegroundColor Green }
function Warn ($m) { Write-Host "[!] $m"    -ForegroundColor Yellow }
function Err  ($m) { Write-Host "[x] $m"    -ForegroundColor Red }

# --- пути репозитория ---
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir     = Split-Path -Parent $ScriptDir
$TemplateDir = Join-Path $RepoDir "vault-template\_BRAIN"

Say ""
Say "Второй мозг на Claude Code — bootstrap (Windows)"
Say "Репозиторий: $RepoDir"
Say ""

# --- 1. проверка claude ---
$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) {
  Ok "Claude Code найден: $($claude.Source)"
} else {
  Err "Claude Code (команда claude) не найден."
  Say "  Установи Claude Code и залогинься, потом запусти бутстрап снова:"
  Say "    npm install -g @anthropic-ai/claude-code     # или см. официальную инструкцию"
  Say "    claude   # залогиниться"
  exit 1
}

# --- проверка шаблона ---
if (-not (Test-Path -LiteralPath $TemplateDir)) {
  Err "Не найден каркас: $TemplateDir"
  Say "  Запускай скрипт из распакованного репозитория second-brain-kit."
  exit 1
}

# --- 2. куда ставим ---
$DefaultVault = Join-Path $env:USERPROFILE "SecondBrain"
# Без вопросов с клавиатуры: ставит агент, а где хранить, спрашивает уже интервью.
if ([string]::IsNullOrWhiteSpace($VaultDir)) { $VaultDir = if ($env:SB_VAULT) { $env:SB_VAULT } else { $DefaultVault } }
$BrainDir = Join-Path $VaultDir "_BRAIN"
New-Item -ItemType Directory -Force -Path $BrainDir | Out-Null
Ok "Каркас будет в: $BrainDir"

# --- 3. разворачиваем _BRAIN\, *.template.md -> *.md ---
$created = 0; $skipped = 0
$prefix = $TemplateDir.TrimEnd('\') + '\'
Get-ChildItem -LiteralPath $TemplateDir -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($prefix.Length)              # путь относительно шаблона
  if ($rel -like "*.template.md") {
    $relDst = $rel.Substring(0, $rel.Length - ".template.md".Length) + ".md"
  } else {
    $relDst = $rel
  }
  $dst = Join-Path $BrainDir $relDst
  $dstDir = Split-Path -Parent $dst
  if (-not (Test-Path -LiteralPath $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
  if (Test-Path -LiteralPath $dst) {
    $script:skipped++                                        # не затираем наполненное
  } else {
    Copy-Item -LiteralPath $_.FullName -Destination $dst -Force
    $script:created++
  }
}
Ok "Файлов создано: $created, пропущено (уже было): $skipped"

# --- корневой CLAUDE.md vault (метод) ---
$RootTpl   = Join-Path $RepoDir "vault-template\CLAUDE.template.md"
$VaultMd   = Join-Path $VaultDir "CLAUDE.md"
if ((Test-Path -LiteralPath $RootTpl) -and (-not (Test-Path -LiteralPath $VaultMd))) {
  Copy-Item -LiteralPath $RootTpl -Destination $VaultMd -Force
  Ok "Метод vault: $VaultMd"
}

# --- 4. мост памяти: бэкап + дописать @import (идемпотентно) ---
$ClaudeCfgDir = Join-Path $env:USERPROFILE ".claude"
$GlobalMd     = Join-Path $ClaudeCfgDir "CLAUDE.md"
New-Item -ItemType Directory -Force -Path $ClaudeCfgDir | Out-Null

$MarkBegin  = "<!-- second-brain-kit:begin -->"
$MarkEnd    = "<!-- second-brain-kit:end -->"
$RulesBegin = "<!-- sbk:rules:begin -->"
$RulesEnd   = "<!-- sbk:rules:end -->"

function Build-Block {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.AppendLine($MarkBegin)
  [void]$sb.AppendLine("# Второй мозг — мост памяти (горячее ядро)")
  [void]$sb.AppendLine("> Автоподключение через second-brain-kit. Не редактируй между маркерами — перегенерируется бутстрапом.")
  [void]$sb.AppendLine("")
  [void]$sb.AppendLine("Источник правды — твой vault. Ядро (hot/INDEX/STATE/STACK) подгружает SessionStart-хук в каждую сессию. Опорные файлы:")
  [void]$sb.AppendLine("")
  foreach ($f in @("STATE.md","STACK.md")) {
    $p = Join-Path $BrainDir $f
    if (Test-Path -LiteralPath $p) { [void]$sb.AppendLine("@$p") }
  }
  [void]$sb.AppendLine("")
  [void]$sb.AppendLine("Метод работы с хранилищем:")
  if (Test-Path -LiteralPath $VaultMd) { [void]$sb.AppendLine("@$VaultMd") }
  [void]$sb.AppendLine("")
  [void]$sb.AppendLine($RulesBegin)
  [void]$sb.AppendLine("## Память — записывать находки обратно")
  [void]$sb.AppendLine("- Пиши по ходу сессии, не только в конце: как только сформировалась мысль, факт или принято решение — сразу сохраняй, не откладывая.")
  [void]$sb.AppendLine("- Находку / факт / цифру / метод → ``_BRAIN/Заметки/`` (первая строка — теги ``#источник #тема``). Инфра/ключи/домены → ``_BRAIN/STACK.md``.")
  [void]$sb.AppendLine("- Решение с обоснованием → ``_BRAIN/Решения/`` (ADR). Итог сессии → ``_BRAIN/Выводы/<дата>.md``.")
  [void]$sb.AppendLine("- В конце содержательной сессии ОБНОВИ ``_BRAIN/hot.md`` (3–6 строк: над чем работали, следующий шаг, тронутые файлы).")
  [void]$sb.AppendLine("- Пиши без лишних вопросов, коротко отчитываясь «сохранил в …». Секреты в ``.md`` не пишем — только указатели. Даты ГГГГ-ММ-ДД.")
  [void]$sb.AppendLine($RulesEnd)
  [void]$sb.AppendLine($MarkEnd)
  return $sb.ToString()
}

$block = Build-Block

if ((Test-Path -LiteralPath $GlobalMd) -and (Select-String -LiteralPath $GlobalMd -SimpleMatch $MarkBegin -Quiet)) {
  # блок уже есть — перегенерируем его содержимое, остальное не трогаем (идемпотентно)
  Copy-Item -LiteralPath $GlobalMd -Destination "$GlobalMd.bak" -Force
  $content = [System.IO.File]::ReadAllText($GlobalMd, $Utf8NoBom)
  $pattern = "(?s)" + [regex]::Escape($MarkBegin) + ".*?" + [regex]::Escape($MarkEnd)
  $new = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block.TrimEnd() })
  [System.IO.File]::WriteAllText($GlobalMd, $new, $Utf8NoBom)
  Ok "Мост памяти обновлён (бэкап: $GlobalMd.bak)"
}
elseif (Test-Path -LiteralPath $GlobalMd) {
  # файл есть, блока нет — бэкап и ДОПИСАТЬ в конец
  Copy-Item -LiteralPath $GlobalMd -Destination "$GlobalMd.bak" -Force
  $content = [System.IO.File]::ReadAllText($GlobalMd, $Utf8NoBom)
  $new = $content.TrimEnd() + "`r`n`r`n" + $block
  [System.IO.File]::WriteAllText($GlobalMd, $new, $Utf8NoBom)
  Ok "Мост памяти дописан (бэкап: $GlobalMd.bak)"
}
else {
  # файла нет — создаём
  [System.IO.File]::WriteAllText($GlobalMd, $block, $Utf8NoBom)
  Ok "Мост памяти создан: $GlobalMd"
}

# --- 4b. SessionStart-хук: движок загрузки ядра + напоминание писать итог ---
$HookTpl  = Join-Path $RepoDir "install\hooks\load-second-brain.ps1"
$HooksDir = Join-Path $ClaudeCfgDir "hooks"
$HookDst  = Join-Path $HooksDir "load-second-brain.ps1"
$Settings = Join-Path $ClaudeCfgDir "settings.json"
if (Test-Path -LiteralPath $HookTpl) {
  New-Item -ItemType Directory -Force -Path $HooksDir | Out-Null
  $hookContent = [System.IO.File]::ReadAllText($HookTpl, $Utf8NoBom).Replace("__BRAIN_DIR__", $BrainDir)
  [System.IO.File]::WriteAllText($HookDst, $hookContent, $Utf8NoBom)

  $cmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$HookDst`""
  if (Test-Path -LiteralPath $Settings) {
    Copy-Item -LiteralPath $Settings -Destination "$Settings.bak" -Force
    try { $cfg = Get-Content -LiteralPath $Settings -Raw -Encoding UTF8 | ConvertFrom-Json } catch { $cfg = $null }
  } else { $cfg = $null }
  if ($null -eq $cfg) { $cfg = [PSCustomObject]@{} }

  $already = $false
  if (($cfg.PSObject.Properties.Name -contains "hooks") -and ($cfg.hooks.PSObject.Properties.Name -contains "SessionStart")) {
    foreach ($grp in @($cfg.hooks.SessionStart)) {
      foreach ($h in @($grp.hooks)) { if ($h.command -and ($h.command -match "load-second-brain")) { $already = $true } }
    }
  }
  if (-not $already) {
    if (-not ($cfg.PSObject.Properties.Name -contains "hooks")) {
      $cfg | Add-Member -NotePropertyName hooks -NotePropertyValue ([PSCustomObject]@{}) -Force
    }
    if (-not ($cfg.hooks.PSObject.Properties.Name -contains "SessionStart")) {
      $cfg.hooks | Add-Member -NotePropertyName SessionStart -NotePropertyValue @() -Force
    }
    $entry = [PSCustomObject]@{ hooks = @([PSCustomObject]@{ type = "command"; command = $cmd }) }
    $cfg.hooks.SessionStart = @($cfg.hooks.SessionStart) + $entry
    [System.IO.File]::WriteAllText($Settings, ($cfg | ConvertTo-Json -Depth 12), $Utf8NoBom)
    Ok "Движок памяти подключён (хук в settings.json; бэкап: $Settings.bak)"
  } else {
    Ok "Движок памяти уже подключён."
  }
}

# --- 4c. команды-помощники (скиллы) → %USERPROFILE%\.claude\skills ---
$SkillsDst = Join-Path $ClaudeCfgDir "skills"
New-Item -ItemType Directory -Force -Path $SkillsDst | Out-Null
$copied = 0
foreach ($base in @((Join-Path $RepoDir "skills"), (Join-Path $RepoDir "plugins\content\skills"))) {
  if (-not (Test-Path -LiteralPath $base)) { continue }
  foreach ($d in Get-ChildItem -LiteralPath $base -Directory) {
    if (-not (Test-Path -LiteralPath (Join-Path $d.FullName "SKILL.md"))) { continue }
    $dst = Join-Path $SkillsDst $d.Name
    if (Test-Path -LiteralPath $dst) { Remove-Item -LiteralPath $dst -Recurse -Force }
    Copy-Item -LiteralPath $d.FullName -Destination $dst -Recurse -Force
    $copied++
  }
}
Ok "Команды-помощники установлены: $copied → $SkillsDst"

# --- финал ---
Say ""
Say "Готово. Бутстрап подготовил каркас и мост памяти."
Say "Vault:        $VaultDir"
Say "Горячее ядро: $GlobalMd"
Say ""
Say "Следующий шаг — открой Claude Code и запусти:"
Say "    /setup-second-brain"
Say ""
Say "Дальше Claude проведёт интервью и наполнит второй мозг."
Say "Этот скрипт claude НЕ запускает — запусти его сам."
