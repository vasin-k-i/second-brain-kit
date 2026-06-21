---
role: seo_manager
description: Оптимизация on-page элементов страницы — title, meta description, headers, content, internal links
---

# On-Page SEO оптимизация

**Контекст:** Применяется для оптимизации существующих или новых страниц под целевые ключевые слова. Результат — оптимизированная страница с правильными on-page элементами, соответствующая search intent.

**Роль:** При использовании этого навыка обязательно ориентируйся на философию и принципы работы роли [@roles/seo_manager/_role_seo_manager.md](../_role_seo_manager.md). Навык определяет КАК выполнять задачу, а роль определяет КАК ДУМАТЬ при её выполнении. Для работы с терминами используй материалы из [`knowledge/`](../knowledge/).

---

## 1. Назначение

### 1.1 Задача навыка

Оптимизировать on-page элементы страницы, которая:
- Соответствует search intent целевого ключевого слова
- Имеет оптимизированные HTML-элементы (title, meta, headers)
- Содержит качественный контент с естественным размещением keywords
- Имеет правильную структуру internal links
- Демонстрирует E-E-A-T сигналы

### 1.2 Data Contract

| | Описание |
|---|----------|
| **Input** | URL страницы или драфт контента, целевое ключевое слово (primary), secondary keywords (опционально), описание целевой аудитории |
| **Output** | Рекомендации по оптимизации on-page элементов, оптимизированные title/meta/headers, чек-лист изменений |

---

## 2. Методология

### 2.1 Теоретическая база

**Search Intent Matching** — сопоставление типа контента с поисковым намерением пользователя. Формат и содержание страницы должны соответствовать тому, что пользователь ожидает найти по запросу.

### 2.2 Ключевые принципы

- **Intent first:** Сначала определи intent, потом оптимизируй. Неправильный формат не ранжируется.
- **Title — главный фактор:** Title tag — самый важный on-page элемент. Primary keyword в начале.
- **Качество > плотность:** Keyword stuffing наказывается. Естественное использование keywords.
- **E-E-A-T в контенте:** Демонстрируй Experience, Expertise, Authoritativeness, Trustworthiness.

---

## 3. Алгоритм выполнения

### 3.1 Шаг 1. Анализ Search Intent

**Цель:** Определить тип intent и соответствующий формат контента.

**Действия:**
1. Проанализируй SERP по целевому keyword:
   - Какой тип контента в топ-10? (guides, product pages, listicles, videos)
   - Какие SERP features присутствуют? (Featured Snippet, PAA, Images)
2. Определи тип intent:
   - **Informational:** guides, how-to, FAQ → образовательный контент
   - **Navigational:** brand pages → сфокусированный на бренде
   - **Transactional:** product pages, pricing → конверсионный
   - **Commercial Investigation:** comparisons, reviews → помощь в выборе
3. Сравни текущую страницу с SERP expectations:
   - Соответствует ли формат?
   - Есть ли content gap?

**Результат:** Определён intent и целевой формат контента.

---

### 3.2 Шаг 2. Оптимизация Title Tag

**Цель:** Создать оптимальный title tag.

**Действия:**
1. Структура title:
   ```
   Primary Keyword — Secondary Keyword | Brand Name
   ```
2. Требования:
   - Длина: 50-60 символов (до обрезки в SERP)
   - Primary keyword — в начале title
   - Уникальность — не дублировать с другими страницами
   - Бренд — в конце, через | или —
3. Оптимизация под CTR:
   - Включи benefit или value proposition
   - Используй числа, если уместно (2025, 10 tips)
   - Избегай keyword stuffing

**Примеры:**
- ✅ `Running Shoes for Marathon Training — Nike Official Store`
- ❌ `Running Shoes SEO Shoes Best Running Shoes Buy`

**Результат:** Оптимизированный title tag.

---

### 3.3 Шаг 3. Оптимизация Meta Description

**Цель:** Создать meta description для максимального CTR.

**Действия:**
1. Структура meta description:
   ```
   [What] + [Benefit] + [CTA]
   ```
2. Требования:
   - Длина: 150-160 символов (desktop), 120 (mobile)
   - Keywords: будут выделены жирным при совпадении с запросом
   - Call-to-action: побуждай к клику
   - Unique selling point: почему эта страница лучше?
3. Не включать:
   - Дублирование с другими страницами
   - Списки ключевых слов
   - Неточное описание контента

**Пример:**
```
Complete guide to choosing running shoes for marathon. Learn how to find the perfect fit for your training. Shop now with free returns.
```

**Результат:** Оптимизированная meta description.

---

### 3.4 Шаг 4. Оптимизация Heading Structure

**Цель:** Создать логичную иерархию заголовков.

**Действия:**
1. H1 — главный заголовок:
   - Один H1 на страницу
   - Содержит primary keyword
   - Может отличаться от title (но согласован)
2. H2-H6 — структура контента:
   - Логическая иерархия (не перескакивать с H2 на H5)
   - Secondary keywords в H2/H3
   - Описывают содержимое раздела
3. Оптимизация под Featured Snippets:
   - Google часто берёт H2/H3 для snippets
   - Формулируй как вопросы, если уместно

**Шаблон структуры:**
```
H1: Primary Keyword + Value Proposition
  H2: Main Topic 1 (secondary keyword)
    H3: Subtopic 1.1
    H3: Subtopic 1.2
  H2: Main Topic 2 (secondary keyword)
  H2: FAQ (если применимо)
```

**Результат:** Оптимизированная heading structure.

---

### 3.5 Шаг 5. Оптимизация Content

**Цель:** Оптимизировать контент для SEO и пользователей.

**Действия:**
1. Keyword placement:
   - Primary keyword в first 100 words
   - Primary keyword в H1
   - Secondary/LSI keywords естественно по тексту
   - Избегай keyword stuffing (нет точной плотности)
2. E-E-A-T сигналы:
   - **Experience:** примеры из практики, case studies
   - **Expertise:** глубокое раскрытие темы, терминология
   - **Authoritativeness:** ссылки на источники, автор с bio
   - **Trustworthiness:** актуальная информация, contact info
3. Readability:
   - Короткие параграфы (2-4 предложения)
   - Bullet points и numbered lists
   - Визуальные элементы (images, tables)
   - Subheadings каждые 200-300 слов
4. Comprehensiveness:
   - Полностью отвечает на вопрос/intent
   - Покрывает related topics (смотри PAA)
   - Оригинальный контент, не скопированный

**Результат:** Оптимизированный контент.

---

### 3.6 Шаг 6. Оптимизация Internal Links

**Цель:** Создать правильную структуру внутренних ссылок.

**Действия:**
1. Anchor text:
   - Descriptive: описывает целевую страницу
   - Varied: не повторять один anchor для всех ссылок
   - Естественный: вписывается в контекст
   - ❌ Избегать: "click here", "read more"
2. Link patterns:
   - Ссылки на релевантные страницы (topical relevance)
   - Ссылки с авторитетных страниц на новые/важные
   - Pillar-Cluster: связывай pillar и cluster pages
3. Best practices:
   - Не более 100-150 ссылок на странице
   - Ссылки в body text ценнее, чем в navigation
   - Проверь на broken internal links

**Результат:** Оптимизированная internal linking structure.

---

### 3.7 Шаг 7. Оптимизация Images

**Цель:** Оптимизировать изображения для SEO.

**Действия:**
1. Alt text:
   - Описательный: что изображено на картинке
   - Keywords: где уместно, естественно
   - Accessibility: для screen readers
   - ❌ Избегать: "image1.jpg", keyword stuffing
2. File names:
   - Descriptive: `red-running-shoes-nike.jpg`
   - Hyphens, не underscores
   - Lowercase
3. Technical:
   - Format: WebP или AVIF (best compression)
   - Lazy loading: `loading="lazy"` (кроме above-the-fold)
   - Размеры: указывай width/height для CLS

**Результат:** Оптимизированные изображения.

---

### 3.8 Шаг 8. Финальная проверка

**Цель:** Убедиться, что все on-page элементы оптимизированы.

**Чек-лист:**
- [ ] Title tag: 50-60 символов, primary keyword в начале, уникальный
- [ ] Meta description: 150-160 символов, CTA, уникальная
- [ ] H1: один на страницу, содержит primary keyword
- [ ] H2-H3: структурируют контент, содержат secondary keywords
- [ ] Primary keyword: в first 100 words, в H1
- [ ] Content: соответствует search intent, comprehensive
- [ ] E-E-A-T: демонстрируется expertise, есть автор/источники
- [ ] Internal links: descriptive anchors, релевантные страницы
- [ ] Images: alt text описательный, файлы оптимизированы
- [ ] URL: readable, содержит keyword (если новая страница)

**Результат:** On-page оптимизация завершена.

---

## 4. Структура результата

### 4.1 Шаблон рекомендаций

**Формат:**
```markdown
# On-Page Optimization: [URL или название страницы]
**Target Keyword:** [primary keyword]
**Search Intent:** [informational/transactional/commercial/navigational]

## Current State Analysis
- Title: [текущий] → [проблема]
- Meta: [текущий] → [проблема]
- H1: [текущий] → [проблема]
- Content: [оценка]

## Recommendations

### Title Tag
**Current:** [текущий title]
**Recommended:** [оптимизированный title]
**Reason:** [почему]

### Meta Description
**Current:** [текущая meta]
**Recommended:** [оптимизированная meta]

### Heading Structure
**Recommended:**
- H1: [...]
- H2: [...]
  - H3: [...]

### Content Improvements
- [ ] [рекомендация 1]
- [ ] [рекомендация 2]

### Internal Links to Add
- [anchor text] → [target page]

## Priority Checklist
1. [ ] [высший приоритет]
2. [ ] [...]
```

---

## 9. Примеры

### 9.1 Правильное выполнение

**Target Keyword:** "best running shoes for marathon"

**Title:** `Best Running Shoes for Marathon Training 2025 | Runner's Guide`
- ✅ Primary keyword в начале
- ✅ Год для актуальности
- ✅ 58 символов

**Meta:** `Looking for the best marathon running shoes? Our expert guide compares top models for cushioning, support & durability. Find your perfect fit.`
- ✅ Keyword присутствует
- ✅ Benefit (expert guide, comparison)
- ✅ CTA (Find your perfect fit)

### 9.2 Типичные ошибки

**Ошибка:** Keyword stuffing в title

`Best Running Shoes - Running Shoes for Marathon - Buy Running Shoes`

**Почему неправильно:** Повтор ключевого слова, нет value proposition, выглядит спамно.

**Как исправить:** `Best Running Shoes for Marathon Training 2025 | Expert Reviews`

---

## 10. Артефакты

**Наименование файла:** `on_page_optimization_{page_name}_{yyyymmdd}.md`
