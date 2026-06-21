# Установка «Второго мозга на Claude Code»

Единая инструкция под **macOS / Linux** и **Windows**. Где шаги отличаются — помечено **▶ здесь различие**.

Общая логика одна:
**Claude Code → подключить marketplace → запустить bootstrap (готовит каркас и мост памяти) → `/setup-second-brain` (Claude проводит интервью).**

Bootstrap-скрипт **не запускает** Claude сам — он только готовит файлы. Запуск `/setup-second-brain` — твой шаг.

---

## Шаг 1. Установить Claude Code

Нужен установленный и залогиненный Claude Code.

```
npm install -g @anthropic-ai/claude-code   # или см. официальную инструкцию Anthropic
claude                                      # запустить и залогиниться
```

Проверка, что команда видна:

- **▶ macOS / Linux:**
  ```bash
  command -v claude
  ```
- **▶ Windows (PowerShell):**
  ```powershell
  Get-Command claude
  ```

Если команды нет — bootstrap остановится и подскажет это же.

---

## Шаг 2. Подключить marketplace

В открытом Claude Code:

```
/plugin marketplace add <repo>
```

`<repo>` — путь/URL репозитория `second-brain-kit`. Это даёт ядро и скиллы (`/setup-second-brain`, `/capture`, `/find`, модули и т.д.). Различий по ОС нет.

---

## Шаг 3. Запустить bootstrap

Bootstrap: проверяет `claude`, разворачивает каркас `_BRAIN/` в выбранную папку (`*.template.md` → `*.md`), бэкапит существующий глобальный `CLAUDE.md` в `.bak` и **дописывает** блок `@import` горячего ядра (идемпотентно — повторный запуск безопасен, ничего не затирает).

- **▶ macOS / Linux** — bash:
  ```bash
  bash install/install.sh
  # или указать папку сразу:
  bash install/install.sh "$HOME/SecondBrain"
  ```
  По умолчанию vault: `~/SecondBrain`. Глобальный конфиг: `~/.claude/CLAUDE.md` (бэкап `~/.claude/CLAUDE.md.bak`).

- **▶ Windows** — PowerShell:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\install\install.ps1
  # или указать папку сразу:
  powershell -ExecutionPolicy Bypass -File .\install\install.ps1 -VaultDir "$env:USERPROFILE\SecondBrain"
  ```
  По умолчанию vault: `%USERPROFILE%\SecondBrain`. Глобальный конфиг: `%USERPROFILE%\.claude\CLAUDE.md` (бэкап `…\CLAUDE.md.bak`).

**▶ Различия по сути:**

| | macOS / Linux | Windows |
|---|---|---|
| Команда запуска | `bash install/install.sh` | `powershell -ExecutionPolicy Bypass -File .\install\install.ps1` |
| Домашняя папка | `~` / `$HOME` | `%USERPROFILE%` / `$env:USERPROFILE` |
| Разделитель пути | `/` | `\` |
| Глобальный конфиг | `~/.claude/CLAUDE.md` | `%USERPROFILE%\.claude\CLAUDE.md` |
| Бэкап | `CLAUDE.md.bak` | `CLAUDE.md.bak` |

Оба варианта: идемпотентны, бэкапят перед правкой, корректно работают с **кириллическими именами папок**.

---

## Шаг 4. Запустить интервью

Открой Claude Code и выполни:

```
/setup-second-brain
```

Claude задаст несколько вопросов и наполнит второй мозг: контекст, проекты, фокус, при желании — инфраструктуру (указатели на ключи, **не сами ключи**) и опциональные модули (видео-пайплайн, SEO + правила работы с сайтами).

Углублённый добор позже:
```
/setup-second-brain --deep
```

---

## Что меняет bootstrap (прозрачность)

- **Создаёт** каркас vault: `<vault>/_BRAIN/…` и `<vault>/CLAUDE.md` (метод). Уже существующие файлы **не перезаписывает**.
- **Бэкапит** глобальный `CLAUDE.md` в `.bak` перед любой правкой.
- **Дописывает** в глобальный `CLAUDE.md` блок между маркерами `<!-- second-brain-kit:begin -->` … `<!-- second-brain-kit:end -->` с `@import` горячего ядра (`STATE.md`, `STACK.md`, `INDEX.md`, `hot.md`) и методом. Повторный запуск **перегенерирует только этот блок**, остальное не трогает.

Откат: восстанови `CLAUDE.md` из `.bak` и удали папку vault, если нужно начать заново.

---

## Приватность

- Секреты в `.md` **не пишем** — только указатели, где лежит ключ (`.env` проекта / менеджер паролей).
- Личное/финансы — вне горячего ядра (оно грузится в каждой сессии и видно на записи экрана).
- Каркас и метод обезличены; персональное наполняет только интервью.
