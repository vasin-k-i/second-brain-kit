# SessionStart hook «Второй мозг» (Windows). stdout → контекст КАЖДОЙ сессии.
# Путь к _BRAIN подставляет установщик (__BRAIN_DIR__).
$ErrorActionPreference = "SilentlyContinue"
$Brain = "__BRAIN_DIR__"
if (-not (Test-Path -LiteralPath $Brain)) { exit 0 }

Write-Output "# Второй мозг — ядро (автозагрузка SessionStart)"
Write-Output ""
Write-Output "Контекст из твоего хранилища. Используй как фон, не дублируй дословно в ответах."
Write-Output "**В конце содержательной сессии — запиши память обратно:** ОБНОВИ _BRAIN/hot.md (3-6 строк: над чем работали, следующий шаг, тронутые файлы); если был итог/решение/находка — допиши в _BRAIN/Выводы / _BRAIN/Решения / _BRAIN/Заметки. Без лишних вопросов, коротко отчитываясь «сохранил в …»."
Write-Output ""
foreach ($f in @("hot.md","INDEX.md","STATE.md","STACK.md")) {
  $p = Join-Path $Brain $f
  if (Test-Path -LiteralPath $p) {
    Write-Output "---"
    Write-Output "## _BRAIN/$f"
    Write-Output ""
    Get-Content -LiteralPath $p -Raw -Encoding UTF8 | Write-Output
    Write-Output ""
  }
}
