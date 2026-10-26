# SessionStart hook «Второй мозг» (Windows). stdout → контекст КАЖДОЙ сессии.
# Путь к _BRAIN подставляет установщик (__BRAIN_DIR__).
$ErrorActionPreference = "SilentlyContinue"
$Brain = "__BRAIN_DIR__"

# Потолок ядра: оно грузится в каждую сессию, раздутый STACK.md незаметно съедает
# окно контекста. Длинный файл обрезается по строкам, хук честно об этом говорит.
$MaxPerFile = if ($env:SB_HOOK_MAX_BYTES) { [int]$env:SB_HOOK_MAX_BYTES } else { 20000 }
$MaxTotal   = if ($env:SB_HOOK_MAX_TOTAL) { [int]$env:SB_HOOK_MAX_TOTAL } else { 60000 }

if (-not (Test-Path -LiteralPath $Brain)) { exit 0 }

Write-Output "# Второй мозг — ядро (автозагрузка SessionStart)"
Write-Output ""
Write-Output "Контекст из твоего хранилища. Используй как фон, не дублируй дословно в ответах."
Write-Output "**В конце содержательной сессии — запиши память обратно:** ОБНОВИ _BRAIN/hot.md (3-6 строк: над чем работали, следующий шаг, тронутые файлы); если был итог/решение/находка — допиши в _BRAIN/Выводы / _BRAIN/Решения / _BRAIN/Заметки. Без лишних вопросов, коротко отчитываясь «сохранил в …»."
Write-Output ""

$spent = 0
foreach ($f in @("hot.md","INDEX.md","STATE.md","STACK.md")) {
  $p = Join-Path $Brain $f
  if (-not (Test-Path -LiteralPath $p)) { continue }

  $left = $MaxTotal - $spent
  Write-Output "---"
  Write-Output "## _BRAIN/$f"
  Write-Output ""
  if ($left -le 0) {
    Write-Output "НЕ ЗАГРУЖЕН: ядро уже превысило $MaxTotal байт. Прочитай сам, если нужен: $p"
    Write-Output ""
    continue
  }
  $limit = [Math]::Min($MaxPerFile, $left)
  $size = (Get-Item -LiteralPath $p).Length

  if ($size -le $limit) {
    Get-Content -LiteralPath $p -Raw -Encoding UTF8 | Write-Output
    $spent += $size
  } else {
    $n = 0
    foreach ($line in (Get-Content -LiteralPath $p -Encoding UTF8)) {
      $n += [System.Text.Encoding]::UTF8.GetByteCount($line) + 1
      if ($n -gt $limit) { break }
      Write-Output $line
    }
    $spent += $limit
    Write-Output ""
    Write-Output "> Файл обрезан: $size байт при лимите $limit. Загружено начало."
    Write-Output "> Полный файл — $p. Разнеси старое по _BRAIN/Заметки/ и _BRAIN/Архив/, чтобы ядро осталось лёгким."
  }
  Write-Output ""
}
