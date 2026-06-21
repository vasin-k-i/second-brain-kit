<#
  «Второй мозг» — ОБНОВЛЕНИЕ для уже установивших (Windows / PowerShell).

  Делает (идемпотентно, с бэкапами):
    1. Обновляет скиллы в %USERPROFILE%\.claude\skills\ (в т.ч. новый writer + seo-manager).
    2. Ставит SessionStart-хук (движок памяти) и прописывает его в settings.json.
    3. Дописывает правила записи в мост ~\.claude\CLAUDE.md — ТОЛЬКО внутри маркеров кита.
  Остальные инструкции и заметки не трогает.

  Запуск (одной строкой):
    irm https://raw.githubusercontent.com/vasin-k-i/second-brain-kit/main/install/update.ps1 | iex
#>
$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
function Ok($m){ Write-Host "[ok] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[!] $m" -ForegroundColor Yellow }

$KitUrl = if ($env:SB_KIT_URL) { $env:SB_KIT_URL } else { "https://github.com/vasin-k-i/second-brain-kit/archive/refs/heads/main.tar.gz" }
$ClaudeCfgDir = Join-Path $env:USERPROFILE ".claude"
$GlobalMd = Join-Path $ClaudeCfgDir "CLAUDE.md"
$Settings = Join-Path $ClaudeCfgDir "settings.json"
$SkillsDst = Join-Path $ClaudeCfgDir "skills"
$HooksDir = Join-Path $ClaudeCfgDir "hooks"

$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("sbk-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $Tmp | Out-Null
try {
  Write-Host "Обновляю «Второй мозг»…"
  $tar = Join-Path $Tmp "kit.tar.gz"
  Invoke-WebRequest -Uri $KitUrl -OutFile $tar -UseBasicParsing
  tar -xzf $tar -C $Tmp
  # top-dir GitHub-тарбола = <repo>-<branch>/ (имя меняется) → ищем корень кита по install\install.sh
  $Src = Join-Path $Tmp "second-brain-kit"
  if (-not (Test-Path -LiteralPath $Src)) {
    $inner = Get-ChildItem -LiteralPath $Tmp -Recurse -Filter "install.sh" -File |
      Where-Object { $_.DirectoryName -like "*\install" } | Select-Object -First 1
    if ($inner) { $Src = Split-Path -Parent (Split-Path -Parent $inner.FullName) }
  }
  if (-not (Test-Path -LiteralPath $Src)) { throw "Не распаковался кит" }

  # --- 1. скиллы: перезаписываем ---
  New-Item -ItemType Directory -Force -Path $SkillsDst | Out-Null
  $copied = 0
  foreach ($base in @((Join-Path $Src "skills"), (Join-Path $Src "plugins\content\skills"))) {
    if (-not (Test-Path -LiteralPath $base)) { continue }
    Get-ChildItem -LiteralPath $base -Directory | ForEach-Object {
      if (Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md")) {
        $dst = Join-Path $SkillsDst $_.Name
        if (Test-Path -LiteralPath $dst) { Remove-Item -LiteralPath $dst -Recurse -Force }
        Copy-Item -LiteralPath $_.FullName -Destination $dst -Recurse -Force
        $script:copied++
      }
    }
  }
  Ok "Скиллы обновлены: $copied (writer и seo-manager — свежие)"

  # --- 2. найти _BRAIN ---
  $BrainDir = ""
  if (Test-Path -LiteralPath $GlobalMd) {
    $txt = [System.IO.File]::ReadAllText($GlobalMd, $Utf8NoBom)
    $m = [regex]::Match($txt, '@(?<p>[^\s]+[\\/]_BRAIN)[\\/][^\s]+\.md')
    if ($m.Success) {
      $p = $m.Groups["p"].Value
      if ($p.StartsWith("~")) { $p = $env:USERPROFILE + $p.Substring(1) }
      $BrainDir = $p
    }
  }
  if ([string]::IsNullOrWhiteSpace($BrainDir)) {
    $cand = Join-Path (Join-Path $env:USERPROFILE "SecondBrain") "_BRAIN"
    if (Test-Path -LiteralPath $cand) { $BrainDir = $cand }
  }

  # --- 3. хук + settings.json ---
  if ($BrainDir -and (Test-Path -LiteralPath $BrainDir)) {
    New-Item -ItemType Directory -Force -Path $HooksDir | Out-Null
    $HookTpl = Join-Path $Src "install\hooks\load-second-brain.ps1"
    $HookDst = Join-Path $HooksDir "load-second-brain.ps1"
    if (Test-Path -LiteralPath $HookTpl) {
      $hc = [System.IO.File]::ReadAllText($HookTpl, $Utf8NoBom).Replace("__BRAIN_DIR__", $BrainDir)
      [System.IO.File]::WriteAllText($HookDst, $hc, $Utf8NoBom)
      Ok "SessionStart-хук установлен: $HookDst"

      $cmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$HookDst`""
      if (Test-Path -LiteralPath $Settings) {
        Copy-Item -LiteralPath $Settings -Destination "$Settings.bak" -Force
        try { $cfg = Get-Content -LiteralPath $Settings -Raw -Encoding UTF8 | ConvertFrom-Json } catch { $cfg = $null }
      } else { $cfg = $null }
      if ($null -eq $cfg) { $cfg = [PSCustomObject]@{} }
      $already = $false
      if (($cfg.PSObject.Properties.Name -contains "hooks") -and ($cfg.hooks.PSObject.Properties.Name -contains "SessionStart")) {
        foreach ($grp in @($cfg.hooks.SessionStart)) { foreach ($h in @($grp.hooks)) { if ($h.command -and ($h.command -match "load-second-brain")) { $already = $true } } }
      }
      if (-not $already) {
        if (-not ($cfg.PSObject.Properties.Name -contains "hooks")) { $cfg | Add-Member -NotePropertyName hooks -NotePropertyValue ([PSCustomObject]@{}) -Force }
        if (-not ($cfg.hooks.PSObject.Properties.Name -contains "SessionStart")) { $cfg.hooks | Add-Member -NotePropertyName SessionStart -NotePropertyValue @() -Force }
        $entry = [PSCustomObject]@{ hooks = @([PSCustomObject]@{ type = "command"; command = $cmd }) }
        $cfg.hooks.SessionStart = @($cfg.hooks.SessionStart) + $entry
        [System.IO.File]::WriteAllText($Settings, ($cfg | ConvertTo-Json -Depth 12), $Utf8NoBom)
        Ok "Хук прописан в settings.json (бэкап: $Settings.bak)"
      } else { Ok "Хук уже был прописан." }
    }
  } else {
    Warn "Не нашёл папку _BRAIN — хук не ставлю. Запусти /setup-second-brain, если мозг в нестандартном месте."
  }

  # --- 4. правила записи в мост (только внутри маркеров) ---
  $MarkBegin = "<!-- second-brain-kit:begin -->"
  $MarkEnd   = "<!-- second-brain-kit:end -->"
  $RulesBegin = "<!-- sbk:rules:begin -->"
  $RulesEnd   = "<!-- sbk:rules:end -->"
  $rules = @(
    $RulesBegin,
    "## Память — записывать находки обратно",
    "- Пиши по ходу сессии, не только в конце: как только сформировалась мысль, факт или принято решение — сразу сохраняй, не откладывая.",
    "- Находку / факт / цифру / метод → ``_BRAIN/Заметки/`` (первая строка — теги ``#источник #тема``). Инфра/ключи/домены → ``_BRAIN/STACK.md``.",
    "- Решение с обоснованием → ``_BRAIN/Решения/`` (ADR). Итог сессии → ``_BRAIN/Выводы/<дата>.md``.",
    "- В конце содержательной сессии ОБНОВИ ``_BRAIN/hot.md`` (3–6 строк: над чем работали, следующий шаг, тронутые файлы).",
    "- Пиши без лишних вопросов, коротко отчитываясь «сохранил в …». Секреты в ``.md`` не пишем — только указатели. Даты ГГГГ-ММ-ДД.",
    $RulesEnd
  ) -join "`r`n"

  if ((Test-Path -LiteralPath $GlobalMd) -and (Select-String -LiteralPath $GlobalMd -SimpleMatch $MarkBegin -Quiet)) {
    Copy-Item -LiteralPath $GlobalMd -Destination "$GlobalMd.bak" -Force
    $txt = [System.IO.File]::ReadAllText($GlobalMd, $Utf8NoBom)
    # вырезаем старый блок правил, если был
    $txt = [regex]::Replace($txt, "(?s)" + [regex]::Escape($RulesBegin) + ".*?" + [regex]::Escape($RulesEnd) + "\r?\n?", "")
    # вставляем свежие правила перед маркером конца блока кита
    $txt = $txt.Replace($MarkEnd, $rules + "`r`n" + $MarkEnd)
    [System.IO.File]::WriteAllText($GlobalMd, $txt, $Utf8NoBom)
    Ok "Правила записи добавлены в мост (бэкап: $GlobalMd.bak)"
  } elseif (Test-Path -LiteralPath $GlobalMd) {
    Warn "В CLAUDE.md нет маркеров кита (ручной файл) — не трогаю. Хук всё равно несёт правило «обнови hot.md»."
  }

  Write-Host ""
  Ok "Готово. Перезапусти Claude Code, чтобы хук подхватился."
}
finally {
  Remove-Item -LiteralPath $Tmp -Recurse -Force -ErrorAction SilentlyContinue
}
