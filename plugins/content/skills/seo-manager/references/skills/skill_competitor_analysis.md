---
role: seo_manager
description: Конкурентный SEO-анализ — keyword gaps, backlink analysis, content gaps, technical comparison
---

# Конкурентный SEO-анализ

**Контекст:** Применяется для анализа SEO-конкурентов и выявления возможностей. Результат — отчёт с keyword gaps, content opportunities, link building targets и tactical recommendations.

**Роль:** При использовании этого навыка обязательно ориентируйся на философию и принципы работы роли [@roles/seo_manager/_role_seo_manager.md](../_role_seo_manager.md). Навык определяет КАК выполнять задачу, а роль определяет КАК ДУМАТЬ при её выполнении. Для работы с терминами используй материалы из [`knowledge/`](../knowledge/).

---

## 1. Назначение

### 1.1 Задача навыка

Провести конкурентный SEO-анализ, который:
- Выявляет keyword gaps (keywords конкурентов, которых нет у нас)
- Анализирует content strategy конкурентов
- Находит link building opportunities от backlinks конкурентов
- Сравнивает technical SEO implementation
- Формирует actionable recommendations

### 1.2 Data Contract

| | Описание |
|---|----------|
| **Input** | URL своего сайта, список конкурентов (3-5), ниша/индустрия, доступ к SEO tools |
| **Output** | Competitor comparison matrix, keyword gap report, content opportunities, link targets, priority recommendations |

---

## 2. Методология

### 2.1 Теоретическая база

**Competitive Intelligence Framework** — систематический анализ конкурентов по всем направлениям SEO: visibility, content, technical, links. Цель — найти opportunities и threats.

### 2.2 Ключевые принципы

- **SEO-конкуренты ≠ бизнес-конкуренты:** Анализируй тех, кто ранжируется по твоим keywords.
- **Gap = Opportunity:** Что есть у конкурентов и нет у тебя — это opportunity.
- **Learn, don't copy:** Учись у конкурентов, но создавай лучше, а не копируй.
- **Prioritize by impact:** Не все gaps равны — фокус на high-impact opportunities.

---

## 3. Алгоритм выполнения

### 3.1 Шаг 1. Определение конкурентов

**Цель:** Выбрать правильных SEO-конкурентов для анализа.

**Действия:**
1. **Organic competitors:**
   - Кто ранжируется по твоим top keywords?
   - Ahrefs/Semrush → Organic Competitors report
   - Не обязательно прямые бизнес-конкуренты

2. **Selection criteria:**
   - Similar target keywords
   - Comparable or higher organic visibility
   - Relevant to your niche
   - Active SEO (не dormant sites)

3. **Competitor tiers:**
   | Tier | Description |
   |------|-------------|
   | Direct | Same products/services, same audience |
   | Indirect | Related products, overlapping audience |
   | Aspirational | Larger players, benchmark |

4. **Финальный список:** 3-5 конкурентов для deep analysis

**Результат:** Prioritized competitor list.

---

### 3.2 Шаг 2. Visibility Comparison

**Цель:** Сравнить общую органическую видимость.

**Действия:**
1. **Traffic metrics:**
   | Metric | You | Comp 1 | Comp 2 | Comp 3 |
   |--------|-----|--------|--------|--------|
   | Organic Traffic | | | | |
   | Keywords total | | | | |
   | Keywords top-10 | | | | |
   | Domain Rating | | | | |

2. **Traffic trends:**
   - 12-month traffic trend
   - Growing / stable / declining?
   - Impact of recent algorithm updates

3. **Top pages:**
   - Какие страницы driving traffic у каждого?
   - Типы контента (blog, product, tools)
   - Traffic distribution (concentrated vs spread)

4. **SERP overlap:**
   - Где конкуренты пересекаются?
   - Shared keywords
   - Head-to-head rankings

**Результат:** Visibility comparison matrix.

---

### 3.3 Шаг 3. Keyword Gap Analysis

**Цель:** Найти keywords, по которым ранжируются конкуренты, но не вы.

**Действия:**
1. **Gap analysis в tools:**
   - Ahrefs → Content Gap
   - Semrush → Keyword Gap
   - Filter: конкурент ranks, вы не rank

2. **Categorize gaps:**
   | Category | Description |
   |----------|-------------|
   | Missing | Competitor ranks, we don't |
   | Weak | We rank 11-50, competitor top-10 |
   | Untapped | Multiple competitors rank, we don't |

3. **Prioritize gaps:**
   - Volume: higher = more opportunity
   - Difficulty: lower = easier to capture
   - Relevance: alignment с бизнесом
   - Intent: transactional/commercial = higher value

4. **Analysis questions:**
   - Какие темы мы полностью пропустили?
   - Где конкуренты rank лучше — почему?
   - Какие long-tail variations мы упустили?

**Результат:** Prioritized keyword gap list.

---

### 3.4 Шаг 4. Content Analysis

**Цель:** Понять content strategy конкурентов.

**Действия:**
1. **Content inventory:**
   - Типы контента (blog, guides, tools, videos)
   - Количество контента
   - Publishing frequency

2. **Top performing content:**
   - Какой контент получает больше трафика?
   - Какой контент получает больше ссылок?
   - Форматы: length, structure, media

3. **Content quality assessment:**
   - Depth of coverage
   - E-E-A-T signals (authors, sources)
   - UX (design, readability)
   - Freshness (updates)

4. **Content gaps:**
   - Какие темы покрыты у конкурентов, но не у вас?
   - Какие форматы используют конкуренты? (tools, calculators, infographics)
   - Какой контент можно сделать ЛУЧШЕ?

5. **Skyscraper opportunities:**
   - Top linked content конкурентов
   - Можно ли создать better version?

**Результат:** Content analysis и opportunities.

---

### 3.5 Шаг 5. Backlink Analysis

**Цель:** Проанализировать ссылочные профили и найти opportunities.

**Действия:**
1. **Profile comparison:**
   | Metric | You | Comp 1 | Comp 2 | Comp 3 |
   |--------|-----|--------|--------|--------|
   | Referring Domains | | | | |
   | Domain Rating | | | | |
   | Links velocity/month | | | | |

2. **Link sources analysis:**
   - Откуда получают ссылки конкуренты?
   - Типы источников (editorial, guest posts, directories)
   - Quality distribution (high DA vs low DA)

3. **Common linkers:**
   - Сайты, которые ссылаются на 2+ конкурентов
   - Высокая вероятность получить ссылку
   - Priority targets для outreach

4. **Unique link sources:**
   - Откуда top конкурент получает, а другие нет?
   - Unique strategies (PR, partnerships, content types)

5. **Anchor text analysis:**
   - Branded vs keyword anchors
   - Natural distribution?

**Результат:** Link opportunities list.

---

### 3.6 Шаг 6. Technical Comparison

**Цель:** Сравнить техническую реализацию.

**Действия:**
1. **Core Web Vitals:**
   | Metric | You | Comp 1 | Comp 2 |
   |--------|-----|--------|--------|
   | LCP | | | |
   | INP | | | |
   | CLS | | | |

2. **Technical implementation:**
   - Mobile-friendliness
   - Structured data types
   - Site architecture
   - URL structure

3. **Indexation:**
   - Pages indexed (`site:domain.com`)
   - Index bloat или under-indexation?

4. **Technical advantages:**
   - Где конкуренты технически лучше?
   - Где вы лучше?
   - Какие technical features у конкурентов? (search, filters, tools)

**Результат:** Technical comparison matrix.

---

### 3.7 Шаг 7. SWOT и Recommendations

**Цель:** Синтезировать findings в actionable recommendations.

**Действия:**
1. **SWOT analysis:**
   - **Strengths:** Где мы лучше конкурентов?
   - **Weaknesses:** Где отстаём?
   - **Opportunities:** Что конкуренты не делают или делают плохо?
   - **Threats:** Где конкуренты могут обойти нас?

2. **Priority recommendations:**
   - **Quick wins:** Low effort, high impact (fix weaknesses)
   - **Strategic initiatives:** High effort, high impact (capture opportunities)
   - **Defensive actions:** Protect strengths from threats

3. **Tactical actions:**
   | Category | Action | Priority | Impact |
   |----------|--------|----------|--------|
   | Keywords | Target [gap] | High | [traffic] |
   | Content | Create [topic] | Medium | [traffic] |
   | Links | Outreach [sites] | High | [links] |
   | Technical | Fix [issue] | High | [impact] |

**Результат:** Prioritized recommendations.

---

### 3.8 Шаг 8. Финальная проверка

**Цель:** Убедиться, что анализ полный и actionable.

**Чек-лист:**
- [ ] Правильные SEO-конкуренты выбраны (3-5)
- [ ] Visibility comparison завершён (traffic, keywords, DR)
- [ ] Keyword gap analysis проведён и приоритизирован
- [ ] Content analysis с gaps и opportunities
- [ ] Backlink analysis с target list
- [ ] Technical comparison завершён
- [ ] SWOT analysis сформирован
- [ ] Recommendations приоритизированы (quick wins, strategic)
- [ ] Actions конкретные и actionable

**Результат:** Competitive analysis готов.

---

## 4. Структура результата

### 4.1 Шаблон отчёта

**Формат:**
```markdown
# Competitive SEO Analysis: [Your Site]
**Дата:** [дата]
**Конкуренты:** [list]

## Executive Summary
- Key finding 1
- Key finding 2
- Top 3 opportunities
- Top 3 threats

## Visibility Comparison
| Metric | You | Comp 1 | Comp 2 | Comp 3 |
|--------|-----|--------|--------|--------|
| ... | ... | ... | ... | ... |

## Keyword Gaps
### High Priority
| Keyword | Volume | Difficulty | Competitor | Action |
|---------|--------|------------|------------|--------|

### Medium Priority
...

## Content Opportunities
- [Opportunity 1]: [description]
- [Opportunity 2]: [description]

## Link Building Targets
### Common Linkers (link to 2+ competitors)
| Site | DR | Links to Comps | Contact |
|------|----|--------------:|---------|

### Unique Sources
...

## Technical Comparison
[matrix]

## SWOT Analysis
- **Strengths:** [list]
- **Weaknesses:** [list]
- **Opportunities:** [list]
- **Threats:** [list]

## Recommendations
### Quick Wins (Do Now)
1. [action]
2. [action]

### Strategic Initiatives (Plan)
1. [action]
2. [action]

### Defensive Actions
1. [action]
```

---

## 8. Внешние инструменты

| Инструмент | Назначение | Путь/API |
|------------|------------|----------|
| Ahrefs | Keyword gap, backlink analysis | ahrefs.com |
| Semrush | Competitive research | semrush.com |
| SimilarWeb | Traffic estimates | similarweb.com |
| PageSpeed Insights | Technical comparison | pagespeed.web.dev |

---

## 10. Артефакты

**Наименование файла:** `competitor_analysis_{your_site}_{yyyymmdd}.md`
