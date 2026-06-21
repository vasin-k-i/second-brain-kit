---
role: seo_manager
description: Комплексный технический аудит сайта — crawlability, indexability, Core Web Vitals, structured data, mobile-first
---

# Технический SEO-аудит

**Контекст:** Применяется для диагностики технического состояния сайта, выявления проблем с индексацией, скоростью и структурой. Результат — приоритизированный список технических проблем с рекомендациями по исправлению.

**Роль:** При использовании этого навыка обязательно ориентируйся на философию и принципы работы роли [@roles/seo_manager/_role_seo_manager.md](../_role_seo_manager.md). Навык определяет КАК выполнять задачу, а роль определяет КАК ДУМАТЬ при её выполнении. Для работы с терминами используй материалы из [`knowledge/`](../knowledge/).

---

## 1. Назначение

### 1.1 Задача навыка

Провести комплексный технический аудит сайта, который:
- Выявляет проблемы с crawlability (доступность для сканирования)
- Определяет проблемы с indexability (индексация страниц)
- Оценивает Core Web Vitals и page experience
- Проверяет structured data и mobile-first readiness
- Формирует приоритизированный план исправлений

### 1.2 Data Contract

| | Описание |
|---|----------|
| **Input** | URL сайта, доступ к Google Search Console (опционально), доступ к crawl tool (Screaming Frog, Sitebulb) |
| **Output** | Отчёт с проблемами по категориям (Critical/High/Medium/Low), рекомендации по исправлению, чек-лист приоритетных действий |

---

## 2. Методология

### 2.1 Теоретическая база

**Technical SEO Framework** — системный подход к аудиту по трём столпам: Crawlability → Indexability → Renderability. Без правильной технической базы даже лучший контент не получит видимости.

### 2.2 Ключевые принципы

- **Фундамент первичен:** Технические проблемы блокируют весь остальной SEO. Сначала crawlability, потом контент.
- **Приоритизация по impact:** Critical проблемы (blocked pages, server errors) решаются в первую очередь.
- **Mobile-first:** Google индексирует мобильную версию как основную.
- **Core Web Vitals — фактор ранжирования:** LCP < 2.5s, INP < 200ms, CLS < 0.1 — официальные пороги.

---

## 3. Алгоритм выполнения

### 3.1 Шаг 1. Сбор данных и инструментов

**Цель:** Подготовить данные для аудита.

**Действия:**
1. Получи доступ к Google Search Console (Coverage, Core Web Vitals, Mobile Usability)
2. Запусти crawl сайта через Screaming Frog / Sitebulb / аналог
3. Проверь robots.txt и XML sitemap
4. Собери данные PageSpeed Insights для ключевых страниц

**Результат:** Полный набор данных для анализа.

---

### 3.2 Шаг 2. Аудит Crawlability

**Цель:** Проверить, может ли Googlebot найти и просканировать все важные страницы.

**Действия:**
1. Проверь robots.txt:
   - Не блокирует ли важные разделы
   - Указан ли sitemap
   - Нет ли ошибок синтаксиса
2. Проверь XML sitemap:
   - Все важные страницы включены
   - Нет noindex страниц в sitemap
   - Lastmod актуален
   - Размер < 50MB, < 50,000 URL
3. Проверь internal linking:
   - Orphan pages (страницы без входящих ссылок)
   - Глубина клика > 3 для важных страниц
   - Broken internal links
4. Проверь crawl budget:
   - Redirect chains (> 2 редиректов)
   - Duplicate content без canonical
   - Faceted navigation / URL parameters

**Результат:** Список проблем crawlability с severity.

---

### 3.3 Шаг 3. Аудит Indexability

**Цель:** Проверить, добавит ли Google страницы в индекс.

**Действия:**
1. Проверь meta robots:
   - noindex на важных страницах (ошибка)
   - Отсутствие noindex на служебных (утечка crawl budget)
2. Проверь canonicalization:
   - Дубликаты без canonical
   - Self-referencing canonical отсутствует
   - Canonical на noindex страницу
   - HTTP/HTTPS, www/non-www, trailing slash variations
3. Проверь индексацию в Search Console:
   - Coverage report: Excluded, Error
   - "Discovered – currently not indexed"
   - "Crawled – currently not indexed"
4. Проверь через `site:domain.com`:
   - Количество проиндексированных vs ожидаемых
   - Нежелательные страницы в индексе

**Результат:** Список проблем indexability с severity.

---

### 3.4 Шаг 4. Аудит Core Web Vitals и Page Experience

**Цель:** Оценить скорость и UX.

**Действия:**
1. Проверь Core Web Vitals (PageSpeed Insights, Search Console):
   - LCP (Largest Contentful Paint): < 2.5s хорошо, > 4s плохо
   - INP (Interaction to Next Paint): < 200ms хорошо, > 500ms плохо
   - CLS (Cumulative Layout Shift): < 0.1 хорошо, > 0.25 плохо
2. Проверь Page Experience сигналы:
   - HTTPS включён
   - Mobile-friendly (Search Console Mobile Usability)
   - No intrusive interstitials
3. Для страниц с плохими CWV определи причины:
   - LCP: большие изображения, медленный сервер, render-blocking resources
   - INP: тяжёлый JavaScript, long tasks
   - CLS: изображения без размеров, динамическая вставка контента

**Результат:** Список страниц с проблемами CWV и рекомендации.

---

### 3.5 Шаг 5. Аудит Structured Data

**Цель:** Проверить корректность structured data.

**Действия:**
1. Проверь наличие базовых schema:
   - Organization / LocalBusiness
   - BreadcrumbList
   - Article / Product / FAQ (в зависимости от типа страниц)
2. Валидация через Rich Results Test:
   - Синтаксические ошибки
   - Missing required fields
   - Warnings
3. Проверь Search Console → Enhancements:
   - Product, FAQ, Article и др.
   - Errors vs Valid vs Valid with warnings

**Результат:** Список ошибок structured data с рекомендациями.

---

### 3.6 Шаг 6. Аудит Mobile-First

**Цель:** Убедиться, что мобильная версия полноценна.

**Действия:**
1. Проверь mobile usability (Search Console):
   - Clickable elements too close
   - Content wider than screen
   - Text too small to read
2. Проверь паритет контента:
   - Весь важный контент есть на mobile
   - Structured data одинаковые
   - Meta tags одинаковые
3. Проверь mobile-specific issues:
   - Viewport настроен
   - Touch targets достаточного размера
   - No horizontal scroll

**Результат:** Список mobile-specific проблем.

---

### 3.7 Шаг 7. Приоритизация и формирование отчёта

**Цель:** Сформировать actionable отчёт.

**Действия:**
1. Классифицируй проблемы по severity:
   - **Critical:** Блокируют индексацию (noindex на важных, robots.txt blocks, server errors)
   - **High:** Серьёзно влияют на rankings (duplicate content, CWV в красной зоне, mobile issues)
   - **Medium:** Влияют на эффективность (orphan pages, missing canonical, schema errors)
   - **Low:** Minor optimizations (warnings, best practices)
2. Для каждой проблемы укажи:
   - Описание проблемы
   - Затронутые страницы/URLs
   - Рекомендация по исправлению
   - Приоритет
3. Сформируй executive summary:
   - 3-5 ключевых проблем
   - Общая оценка технического здоровья
   - Top-3 приоритетных действия

**Результат:** Полный отчёт готов.

---

### 3.8 Шаг 8. Финальная проверка

**Цель:** Убедиться, что аудит полон и actionable.

**Чек-лист:**
- [ ] Robots.txt проверен (синтаксис, блокировки, sitemap)
- [ ] XML sitemap проверен (полнота, актуальность, noindex)
- [ ] Internal linking проанализирован (orphans, depth, broken)
- [ ] Meta robots проверен (noindex на важных, canonical)
- [ ] Индексация проверена (Search Console Coverage, site:)
- [ ] Core Web Vitals проверены (LCP, INP, CLS для ключевых страниц)
- [ ] Structured data проверена (Rich Results Test, Enhancements)
- [ ] Mobile-first проверен (usability, паритет контента)
- [ ] Проблемы классифицированы по severity (Critical/High/Medium/Low)
- [ ] Для каждой проблемы есть рекомендация по исправлению
- [ ] Executive summary содержит top-3 приоритетных действия

**Результат:** Технический SEO-аудит готов к передаче.

---

## 4. Структура результата

### 4.1 Шаблон отчёта

**Формат:**
```markdown
# Technical SEO Audit: [domain.com]
**Дата:** [дата]
**Инструменты:** [список использованных инструментов]

## Executive Summary
- **Общая оценка:** [Good/Needs Improvement/Critical Issues]
- **Ключевые проблемы:** [3-5 bullet points]
- **Top-3 приоритетных действия:**
  1. [действие]
  2. [действие]
  3. [действие]

## Crawlability
### Critical
- [проблема] — [затронутые URLs] — [рекомендация]

### High
...

## Indexability
...

## Core Web Vitals
...

## Structured Data
...

## Mobile-First
...

## Полный список задач
| # | Severity | Категория | Проблема | Рекомендация | URLs |
|---|----------|-----------|----------|--------------|------|
| 1 | Critical | Crawlability | ... | ... | ... |
```

**Форматирование:**
- Severity цветовое: Critical (🔴), High (🟠), Medium (🟡), Low (🟢)
- URLs группировать или давать count + examples
- Рекомендации конкретные, actionable

---

## 8. Внешние инструменты

| Инструмент | Назначение | Путь/API |
|------------|------------|----------|
| Google Search Console | Coverage, CWV, Mobile Usability | search.google.com/search-console |
| PageSpeed Insights | Core Web Vitals, Lighthouse | pagespeed.web.dev |
| Rich Results Test | Structured data validation | search.google.com/test/rich-results |
| Screaming Frog | Crawling, технический анализ | screamingfrog.co.uk |

---

## 10. Артефакты

**Наименование файла:** `technical_seo_audit_{domain}_{yyyymmdd}.md`
