---
role: seo_manager
description: Entity SEO — оптимизация под Knowledge Graph, structured data, topical authority, semantic SEO
---

# Entity SEO

**Контекст:** Применяется для оптимизации сайта и бренда под сущности (entities) Google Knowledge Graph. Результат — стратегия построения entity presence, structured data implementation, topical authority development.

**Роль:** При использовании этого навыка обязательно ориентируйся на философию и принципы работы роли [@roles/seo_manager/_role_seo_manager.md](../_role_seo_manager.md). Навык определяет КАК выполнять задачу, а роль определяет КАК ДУМАТЬ при её выполнении. Для работы с терминами используй материалы из [`knowledge/`](../knowledge/).

---

## 1. Назначение

### 1.1 Задача навыка

Разработать Entity SEO стратегию, которая:
- Определяет целевые entities для бренда/сайта
- Создаёт связи с существующими entities в Knowledge Graph
- Внедряет structured data для better entity understanding
- Строит topical authority через semantic coverage
- Работает на получение Knowledge Panel (если применимо)

### 1.2 Data Contract

| | Описание |
|---|----------|
| **Input** | URL сайта, описание бренда/персоны, ниша, текущий structured data status, Wikipedia/Wikidata presence |
| **Output** | Entity strategy, structured data recommendations, Knowledge Graph optimization plan, topical authority roadmap |

---

## 2. Методология

### 2.1 Теоретическая база

**Entity-First SEO** — Google переходит от "strings" (ключевых слов) к "things" (сущностям). Entity — уникальный объект в Knowledge Graph с определёнными атрибутами и связями. SEO строится через связи с recognized entities.

**Semantic Triples** — Subject → Predicate → Object. Google понимает мир через тройки: "Nike" → "is a" → "Brand", "Nike" → "produces" → "Running Shoes".

### 2.2 Ключевые принципы

- **Entities > Keywords:** Оптимизация под сущности и связи, не под плотность слов.
- **Связи создают entities:** Можно стать entity через verified connections с существующими entities.
- **Knowledge Graph = Google's dictionary:** Structured data — язык общения с KG.
- **Topical authority через coverage:** Полное покрытие темы показывает экспертизу в entity.

---

## 3. Алгоритм выполнения

### 3.1 Шаг 1. Entity Audit

**Цель:** Понять текущее entity presence.

**Действия:**
1. Проверь, есть ли бренд/персона в Knowledge Graph:
   - Google Knowledge Graph Search API
   - Поиск бренда в Google — есть Knowledge Panel?
   - Поиск в Wikidata/Wikipedia
2. Если есть Knowledge Panel:
   - Какая информация отображается?
   - Какие связи показаны?
   - Есть ли ошибки?
3. Проанализируй structured data на сайте:
   - Какие schema types используются?
   - Rich Results Test — есть ли ошибки?
   - Search Console → Enhancements
4. Определи related entities:
   - С какими entities бренд должен ассоциироваться?
   - Какие entities упоминаются на сайте?

**Результат:** Entity audit report.

---

### 3.2 Шаг 2. Entity Strategy Definition

**Цель:** Определить целевые entities и связи.

**Действия:**
1. Определи primary entity:
   - Тип: Organization, Person, Product, LocalBusiness?
   - Уникальное имя (brand name disambiguation)
   - Ключевые атрибуты
2. Определи связи (predicates):
   - "offers" → Products/Services
   - "locatedIn" → Location
   - "foundedBy" → Founder
   - "sameAs" → Social profiles
3. Определи related entities для association:
   - Industry entities (concepts, topics)
   - Geographic entities
   - People entities (founders, experts)
   - Product/service entities
4. Две стратегии:
   - **Стать Entity:** Бренд/персона = recognized entity в KG
   - **Стать экспертом по Entity:** Ассоциироваться как authority по теме

**Результат:** Entity strategy map.

---

### 3.3 Шаг 3. Structured Data Implementation

**Цель:** Внедрить structured data для entity signals.

**Действия:**
1. **Organization/Person Schema:**
   ```json
   {
     "@context": "https://schema.org",
     "@type": "Organization",
     "name": "Brand Name",
     "url": "https://example.com",
     "logo": "https://example.com/logo.png",
     "description": "...",
     "sameAs": [
       "https://www.facebook.com/brand",
       "https://twitter.com/brand",
       "https://www.linkedin.com/company/brand"
     ],
     "founder": {
       "@type": "Person",
       "name": "Founder Name"
     }
   }
   ```

2. **Webpage Schema с about/mentions:**
   ```json
   {
     "@context": "https://schema.org",
     "@type": "WebPage",
     "name": "Page Title",
     "about": {
       "@type": "Thing",
       "name": "Topic",
       "sameAs": "https://en.wikipedia.org/wiki/Topic"
     },
     "mentions": [
       {
         "@type": "Thing",
         "name": "Related Entity",
         "sameAs": "https://en.wikipedia.org/wiki/Related_Entity"
       }
     ]
   }
   ```

3. **Content-specific schemas:**
   - Article, NewsArticle, BlogPosting
   - Product, Offer
   - FAQ, HowTo
   - Review, AggregateRating

4. Валидация:
   - Rich Results Test
   - Schema Markup Validator
   - Search Console Enhancements

**Результат:** Structured data implementation plan.

---

### 3.4 Шаг 4. Topical Authority Building

**Цель:** Построить semantic coverage темы.

**Действия:**
1. Определи core topics (entities) для authority:
   - Какие концепции должны ассоциироваться с брендом?
   - Какие subtopics нужно покрыть?
2. Semantic coverage analysis:
   - Какие related entities упоминают конкуренты?
   - Какие terms/concepts используются в топ-10?
   - People Also Ask — какие вопросы?
3. Content для topical authority:
   - Pillar content по core topic
   - Cluster content по subtopics
   - Упоминание related entities в контенте
   - Internal links между related topics
4. Entity associations в контенте:
   - Упоминай recognized entities (people, places, concepts)
   - Используй exact names (не синонимы) для entity recognition
   - Ссылайся на authoritative sources (Wikipedia, official sites)

**Результат:** Topical authority roadmap.

---

### 3.5 Шаг 5. Knowledge Panel Strategy

**Цель:** Работа на получение/оптимизацию Knowledge Panel.

**Действия:**
1. **Если Knowledge Panel есть:**
   - Claim через Google Business Profile или Search Console
   - Проверь accuracy информации
   - Suggest edits для ошибок
   - Добавь missing information
2. **Если Knowledge Panel нет:**
   - Определи путь к entity status:
     - Wikipedia (если notable)
     - Wikidata entry
     - Authoritative mentions
     - Strong structured data
   - Wikidata strategy:
     - Создай entry с verifiable claims
     - Добавь identifiers (social, official site)
     - Link к other entities
3. **Notability building:**
   - Press coverage в notable publications
   - Mentions с links от authoritative sites
   - Industry awards, recognition
   - Book с ISBN, IMDB credits (если применимо)

**Результат:** Knowledge Panel action plan.

---

### 3.6 Шаг 6. Internal Linking для Entity SEO

**Цель:** Создать "mini Knowledge Graph" на сайте.

**Действия:**
1. Структура internal links:
   - Cornerstone content = entity hubs
   - Links от mentions к cornerstone
   - Bidirectional linking между related entities
2. Anchor text strategy:
   - Descriptive anchors с entity names
   - Consistent terminology
   - Natural placement в body text
3. Entity pages:
   - Dedicated pages для key entities (products, services, people)
   - Comprehensive coverage на entity page
   - Links TO и FROM entity page
4. Silo structure:
   - Group pages по topic/entity
   - Level 1: Entity hub
   - Level 2: Sub-entity pages
   - Level 3: Supporting content

**Результат:** Internal linking для entity SEO.

---

### 3.7 Шаг 7. Off-Site Entity Signals

**Цель:** Усилить entity signals вне сайта.

**Действия:**
1. **Consistent NAP/Brand:**
   - Одинаковое название везде
   - Consistent descriptions
   - Same logo/images
2. **Social profiles:**
   - Все major platforms claimed
   - sameAs links в structured data
   - Consistent information
3. **Third-party listings:**
   - Industry directories
   - Business directories
   - Google Business Profile
4. **Authoritative mentions:**
   - Press coverage
   - Industry publications
   - Expert contributions
5. **Wikipedia/Wikidata:**
   - Если notable — Wikipedia article
   - Wikidata entry с verifiable claims
   - Proper sourcing

**Результат:** Off-site entity signals plan.

---

### 3.8 Шаг 8. Финальная проверка

**Цель:** Убедиться, что стратегия полная.

**Чек-лист:**
- [ ] Entity audit проведён (KG presence, structured data, related entities)
- [ ] Primary entity определён (type, attributes, predicates)
- [ ] Structured data plan создан (Organization, WebPage, Content schemas)
- [ ] Topical authority roadmap готов (topics, coverage, content plan)
- [ ] Knowledge Panel strategy определена (claim/build)
- [ ] Internal linking для entities спланирован
- [ ] Off-site entity signals определены
- [ ] sameAs links к all social profiles
- [ ] Валидация structured data без ошибок

**Результат:** Entity SEO стратегия готова.

---

## 4. Структура результата

### 4.1 Шаблон стратегии

**Формат:**
```markdown
# Entity SEO Strategy: [Brand/Person]
**Дата:** [дата]

## Entity Audit
- **Knowledge Panel:** [Yes/No]
- **Wikipedia:** [Yes/No/Potential]
- **Current Structured Data:** [types used]
- **Entity Recognition:** [analysis]

## Primary Entity Definition
- **Type:** [Organization/Person/etc.]
- **Name:** [exact name]
- **Key Attributes:**
  - [attribute 1]: [value]
- **Key Predicates:**
  - [predicate] → [object entity]

## Structured Data Plan
### Organization Schema
[JSON-LD code]

### Page-Level Schema
[approach]

## Topical Authority Plan
- **Core Topics:**
  - [Topic 1] — [coverage status]
- **Content Needed:**
  - [content piece] — [target entity]

## Knowledge Panel Strategy
[Specific actions]

## Off-Site Entity Signals
- [ ] [action 1]
- [ ] [action 2]

## Success Metrics
- Knowledge Panel: [target]
- Entity recognition in NLP: [how to measure]
- Topical rankings: [keywords]
```

---

## 8. Внешние инструменты

| Инструмент | Назначение | Путь/API |
|------------|------------|----------|
| Knowledge Graph Search API | Check entity presence | developers.google.com |
| Wikidata | Entity database | wikidata.org |
| Schema Markup Validator | Validate structured data | validator.schema.org |
| Google NLP API | Entity extraction analysis | cloud.google.com/natural-language |

---

## 10. Артефакты

**Наименование файла:** `entity_seo_strategy_{brand}_{yyyymmdd}.md`
