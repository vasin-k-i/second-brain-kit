---
role: seo_manager
description: Исследование ключевых слов — поиск, анализ intent, приоритизация, keyword mapping
---

# Исследование ключевых слов

**Контекст:** Применяется для поиска и анализа ключевых слов под SEO-стратегию или контент-план. Результат — приоритизированный список keywords с intent mapping и рекомендациями по страницам.

**Роль:** При использовании этого навыка обязательно ориентируйся на философию и принципы работы роли [@roles/seo_manager/_role_seo_manager.md](../_role_seo_manager.md). Навык определяет КАК выполнять задачу, а роль определяет КАК ДУМАТЬ при её выполнении. Для работы с терминами используй материалы из [`knowledge/`](../knowledge/).

---

## 1. Назначение

### 1.1 Задача навыка

Провести исследование ключевых слов, которое:
- Выявляет релевантные keywords для бизнеса/продукта
- Классифицирует keywords по search intent
- Оценивает volume, difficulty, opportunity
- Формирует keyword mapping (keyword → страница)
- Выявляет keyword gaps относительно конкурентов

### 1.2 Data Contract

| | Описание |
|---|----------|
| **Input** | Описание бизнеса/продукта, seed keywords, URL сайта, конкуренты (опционально), доступ к SEO-инструментам (Ahrefs, Semrush, GSC) |
| **Output** | Список keywords с метриками, intent classification, keyword mapping, keyword gaps, приоритизированные группы |

---

## 2. Методология

### 2.1 Теоретическая база

**Search Intent Framework** — классификация ключевых слов по намерению пользователя. Keywords эволюционировали от "strings" к "meanings" — Google понимает intent, а не только слова.

### 2.2 Ключевые принципы

- **Intent определяет формат:** Transactional → product page, Informational → guide. Неправильный формат не ранжируется.
- **Volume ≠ Value:** Высокочастотный keyword с низкой конверсией менее ценен, чем низкочастотный с высокой.
- **Long-tail opportunity:** 70%+ поисковых запросов — long-tail. Меньше конкуренция, выше intent clarity.
- **Topic clusters > isolated keywords:** Группировка по темам строит topical authority.

---

## 3. Алгоритм выполнения

### 3.1 Шаг 1. Сбор Seed Keywords

**Цель:** Определить стартовый набор ключевых слов.

**Действия:**
1. Brainstorm на основе продукта/услуги:
   - Как пользователи описывают проблему?
   - Какие термины использует индустрия?
   - Какие вопросы задают клиенты?
2. Анализ существующего сайта:
   - Google Search Console → Performance → Queries
   - Текущие страницы и их темы
3. Анализ конкурентов:
   - Какие keywords у топ-3 конкурентов? (Ahrefs/Semrush)
   - Какой контент они создают?
4. Источники идей:
   - Google Autocomplete
   - People Also Ask
   - Related Searches
   - Quora, Reddit, форумы

**Результат:** Список 20-50 seed keywords.

---

### 3.2 Шаг 2. Расширение списка keywords

**Цель:** Расширить seed keywords до полного списка.

**Действия:**
1. Keyword tools (Ahrefs, Semrush, Ubersuggest):
   - Keyword suggestions для каждого seed
   - Questions (what, how, why, when)
   - Related terms
2. Competitor analysis:
   - Organic keywords конкурентов
   - Content gap analysis (keywords у них, не у нас)
   - Top pages конкурентов
3. Google Search Console:
   - Queries с impressions, но без кликов (opportunity)
   - Long-tail variations
4. Группировка:
   - Объедини похожие keywords
   - Идентифицируй head terms и long-tail

**Результат:** Расширенный список 100-500+ keywords.

---

### 3.3 Шаг 3. Классификация по Search Intent

**Цель:** Определить intent для каждого keyword.

**Действия:**
1. Типы intent:
   | Intent | Описание | Формат контента | Примеры |
   |--------|----------|-----------------|---------|
   | **Informational** | Хочет узнать | Guides, how-to, FAQ | "how to run marathon" |
   | **Navigational** | Ищет сайт/бренд | Homepage, brand pages | "nike official site" |
   | **Commercial Investigation** | Сравнивает | Reviews, comparisons | "best running shoes 2025" |
   | **Transactional** | Готов купить | Product pages, pricing | "buy nike pegasus" |

2. Метод определения:
   - Анализ SERP: какой контент в топ-10?
   - SERP features: shopping results = transactional, PAA = informational
   - Modifiers: "buy", "price" = transactional; "how", "what" = informational

3. Присвой intent каждому keyword.

**Результат:** Keywords с присвоенным intent.

---

### 3.4 Шаг 4. Сбор метрик и оценка

**Цель:** Собрать метрики для приоритизации.

**Действия:**
1. Собери метрики для каждого keyword:
   - **Search Volume:** месячный объём поиска
   - **Keyword Difficulty (KD):** сложность ранжирования (0-100)
   - **CPC:** стоимость клика (индикатор коммерческой ценности)
   - **SERP Features:** какие features занимают место
   - **Current Position:** если уже ранжируемся

2. Рассчитай opportunity score:
   ```
   Opportunity = (Volume × Relevance) / Difficulty
   ```
   - Relevance: 1-10 по соответствию бизнесу
   - Высокий opportunity = high volume + high relevance + low difficulty

3. Дополнительные факторы:
   - Trend (растёт/падает) — Google Trends
   - Seasonality — есть ли сезонные пики
   - Business value — насколько близко к конверсии

**Результат:** Keywords с метриками и opportunity score.

---

### 3.5 Шаг 5. Keyword Mapping

**Цель:** Сопоставить keywords со страницами сайта.

**Действия:**
1. Для каждой группы keywords определи:
   - Существует ли страница? → оптимизировать
   - Нет страницы? → создать новую
   - Каннибализация? → объединить или differentiate

2. Mapping rules:
   - Один primary keyword на страницу
   - Secondary/supporting keywords на ту же страницу
   - Группируй по topic, не по отдельным keywords

3. Создай mapping таблицу:
   | Keyword | Intent | Volume | Page | Action |
   |---------|--------|--------|------|--------|
   | [keyword] | [intent] | [vol] | [URL] | Optimize/Create/- |

4. Выяви проблемы:
   - Keyword cannibalization (2+ страницы на один keyword)
   - Content gaps (keywords без страниц)
   - Thin content (страница без достаточного keyword targeting)

**Результат:** Keyword mapping с actions.

---

### 3.6 Шаг 6. Формирование Topic Clusters

**Цель:** Организовать keywords в тематические кластеры.

**Действия:**
1. Определи pillar topics:
   - Broad, high-volume head terms
   - Важные для бизнеса темы
2. Группируй cluster keywords:
   - Long-tail variations pillar topic
   - Related questions
   - Subtopics
3. Структура cluster:
   ```
   Pillar Page: "Marathon Training"
   ├── Cluster: "Marathon Training Schedule"
   ├── Cluster: "Marathon Nutrition"
   ├── Cluster: "Marathon Gear"
   │   ├── Sub-cluster: "Best Running Shoes"
   │   └── Sub-cluster: "Running Watch"
   └── Cluster: "Marathon Recovery"
   ```
4. Для каждого cluster:
   - Pillar page → comprehensive, broad coverage
   - Cluster pages → deep, specific coverage
   - Internal links между pillar и clusters

**Результат:** Topic clusters с иерархией.

---

### 3.7 Шаг 7. Приоритизация и рекомендации

**Цель:** Сформировать actionable план.

**Действия:**
1. Приоритизируй по критериям:
   - **Quick wins:** Keywords с позициями 5-20 (близко к топ-3)
   - **High opportunity:** High volume + low difficulty
   - **Business value:** Transactional/commercial intent
   - **Foundation:** Head terms для pillar pages

2. Сформируй приоритетные группы:
   - **Priority 1:** Quick wins + high business value
   - **Priority 2:** Content gaps с high opportunity
   - **Priority 3:** Long-term pillar development

3. Рекомендации по каждой группе:
   - Какие страницы создать/оптимизировать
   - Какой формат контента
   - Какие internal links построить

**Результат:** Приоритизированный план keyword targeting.

---

### 3.8 Шаг 8. Финальная проверка

**Цель:** Убедиться, что исследование полное и actionable.

**Чек-лист:**
- [ ] Seed keywords охватывают все аспекты бизнеса
- [ ] Список расширен через tools и competitor analysis
- [ ] Каждому keyword присвоен search intent
- [ ] Собраны метрики (volume, KD, CPC)
- [ ] Keyword mapping: keyword → page
- [ ] Выявлена каннибализация (если есть)
- [ ] Сформированы topic clusters
- [ ] Keywords приоритизированы (quick wins, high opportunity)
- [ ] Есть actionable рекомендации по страницам

**Результат:** Keyword research готов к использованию.

---

## 4. Структура результата

### 4.1 Шаблон отчёта

**Формат:**
```markdown
# Keyword Research: [Бизнес/Продукт]
**Дата:** [дата]
**Инструменты:** [Ahrefs/Semrush/GSC/...]

## Executive Summary
- Всего keywords: [число]
- По intent: Informational [X], Commercial [Y], Transactional [Z]
- Top opportunities: [3-5 keywords]
- Key gaps: [что отсутствует]

## Priority Keywords

### Quick Wins (Positions 5-20)
| Keyword | Volume | KD | Position | Page | Action |
|---------|--------|----|---------:|------|--------|
| ... | ... | ... | ... | ... | ... |

### High Opportunity (New Content)
| Keyword | Volume | KD | Intent | Recommended Page |
|---------|--------|----|---------:|-----------------|
| ... | ... | ... | ... | ... |

## Topic Clusters

### Cluster 1: [Topic Name]
- **Pillar:** [keyword] → [page recommendation]
- **Clusters:**
  - [keyword] → [page]
  - [keyword] → [page]

## Full Keyword List
[Таблица или ссылка на spreadsheet]

## Recommendations
1. [Priority 1 actions]
2. [Priority 2 actions]
3. [Priority 3 actions]
```

---

## 8. Внешние инструменты

| Инструмент | Назначение | Путь/API |
|------------|------------|----------|
| Ahrefs | Keyword research, competitor analysis | ahrefs.com |
| Semrush | Keyword research, gap analysis | semrush.com |
| Google Search Console | Current rankings, impressions | search.google.com/search-console |
| Google Trends | Trend analysis, seasonality | trends.google.com |

---

## 10. Артефакты

**Наименование файла:** `keyword_research_{business_name}_{yyyymmdd}.md`
