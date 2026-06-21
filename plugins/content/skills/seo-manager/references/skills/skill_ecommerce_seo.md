---
role: seo_manager
description: E-commerce SEO — product pages, category optimization, structured data, faceted navigation, Merchant Center
---

# E-commerce SEO

**Контекст:** Применяется для SEO-оптимизации интернет-магазинов. Результат — стратегия e-commerce SEO с оптимизацией product/category pages, structured data, управлением faceted navigation и интеграцией с Merchant Center.

**Роль:** При использовании этого навыка обязательно ориентируйся на философию и принципы работы роли [@roles/seo_manager/_role_seo_manager.md](../_role_seo_manager.md). Навык определяет КАК выполнять задачу, а роль определяет КАК ДУМАТЬ при её выполнении. Для работы с терминами используй материалы из [`knowledge/`](../knowledge/).

---

## 1. Назначение

### 1.1 Задача навыка

Разработать E-commerce SEO стратегию, которая:
- Оптимизирует architecture для crawlability и UX
- Создаёт уникальные product и category pages
- Внедряет e-commerce structured data
- Управляет faceted navigation без crawl budget waste
- Интегрирует с Google Merchant Center

### 1.2 Data Contract

| | Описание |
|---|----------|
| **Input** | URL магазина, каталог (категории, товары), текущий technical status, Merchant Center access |
| **Output** | E-commerce SEO strategy, product page template, category optimization plan, faceted navigation rules, Merchant Center setup |

---

## 2. Методология

### 2.1 Теоретическая база

**E-commerce SEO Framework** — баланс между scale (тысячи товаров) и quality (уникальный контент). Category pages — primary SEO targets, product pages — transactional intent.

### 2.2 Ключевые принципы

- **Scale + quality:** Уникальные descriptions для всех products, не manufacturer copy.
- **Category pages = SEO hubs:** Более важны для rankings, чем individual products.
- **Faceted navigation = crawl budget risk:** Фильтры создают миллионы URL, нужен контроль.
- **Structured data = rich results:** Product schema критична для Shopping и rich snippets.

---

## 3. Алгоритм выполнения

### 3.1 Шаг 1. E-commerce Technical Audit

**Цель:** Оценить техническое состояние магазина.

**Действия:**
1. Site architecture:
   - Глубина клика до products (цель: ≤3)
   - URL structure (readable?)
   - Navigation crawlability (HTML links vs JavaScript)
2. Indexation status:
   - Сколько страниц в индексе vs всего?
   - Нежелательные страницы в индексе (filters, sorts)?
   - Duplicate content issues
3. Faceted navigation:
   - Сколько URL-вариаций создают фильтры?
   - Как обрабатываются? (noindex, canonical, robots.txt)
4. Page speed:
   - Core Web Vitals для category и product pages
   - Image optimization status

**Результат:** Technical audit findings.

---

### 3.2 Шаг 2. Site Architecture Optimization

**Цель:** Оптимизировать структуру магазина.

**Действия:**
1. **Иерархия:**
   ```
   Homepage
   ├── Category 1
   │   ├── Subcategory 1.1
   │   │   ├── Product A
   │   │   └── Product B
   │   └── Subcategory 1.2
   ├── Category 2
   └── Blog
   ```

2. **URL structure:**
   - ✅ `/category/subcategory/product-name`
   - ❌ `/p?id=12345&cat=7&sort=price`

3. **Navigation:**
   - Mega menus для больших каталогов
   - `<a href="">` links (не JavaScript-only)
   - Breadcrumbs на каждой странице
   - HTML sitemap для users и bots
   - Footer links к важным категориям

4. **Internal linking:**
   - Related products на product pages
   - Featured products на category pages
   - Cross-category links где релевантно

**Результат:** Architecture recommendations.

---

### 3.3 Шаг 3. Product Page Optimization

**Цель:** Оптимизировать product pages.

**Действия:**
1. **On-page elements:**
   | Элемент | Best Practice |
   |---------|--------------|
   | Title | Product Name + Brand + Key Attribute |
   | H1 | Product Name |
   | Description | Unique, 150+ words, benefits |
   | Images | Multiple angles, alt text, zoom |
   | Reviews | User reviews с schema |
   | Price | Visible, structured data |
   | Availability | In stock/out of stock |

2. **Unique product descriptions:**
   - ❌ Не копируй manufacturer descriptions
   - ✅ Пиши уникальные с:
     - Benefits (не только features)
     - Use cases
     - Specifications
     - Keywords естественно

3. **Product images:**
   - Alt text: descriptive + keywords
   - File names: `red-running-shoes-nike.jpg`
   - Multiple images: разные углы
   - Image sitemaps

4. **User reviews:**
   - Критичны для E-E-A-T (Experience)
   - Fresh content
   - Long-tail keywords naturally
   - AggregateRating schema

**Результат:** Product page template.

---

### 3.4 Шаг 4. Category Page Optimization

**Цель:** Оптимизировать category pages как SEO hubs.

**Действия:**
1. **Category content:**
   - Intro text: 100-300 слов с keywords
   - FAQ section: common questions
   - Buying guides: помощь в выборе
   - Featured products: best sellers, new arrivals

2. **On-page optimization:**
   | Элемент | Рекомендация |
   |---------|-------------|
   | Title | Category Name + Brand/Store |
   | H1 | Category Name |
   | Intro | Unique, keyword-rich paragraph |
   | Products | Grid/list с key info |

3. **Pagination:**
   - rel="next" / rel="prev" (Google не использует, но не вредит)
   - View All опция (если не слишком большая)
   - Load More — убедись, что URLs crawlable
   - Canonical на первую страницу серии

4. **Filtering и sorting:**
   - Параметры сортировки: block или noindex
   - Canonical на base category

**Результат:** Category optimization plan.

---

### 3.5 Шаг 5. Faceted Navigation Management

**Цель:** Контролировать crawl budget от фильтров.

**Действия:**
1. **Проблема:**
   - Фильтры создают миллионы URL-комбинаций
   - Size × Color × Price × Brand = exponential URLs
   - Crawl budget waste + duplicate content

2. **Решения:**
   | Подход | Когда использовать |
   |--------|-------------------|
   | Noindex, follow | Filtered pages без search value |
   | Canonical | К base category page |
   | Robots.txt | Block crawling URL patterns |
   | JavaScript rendering | Filters без URL changes |

3. **Стратегия:**
   - Определи, какие фильтры имеют search value (popular combinations)
   - Эти → indexable с unique content
   - Остальные → noindex или block
   - Single filter = potentially indexable
   - Multiple filters = usually noindex

4. **Пример:**
   ```
   /shoes/                          → Index
   /shoes/?color=red                → Index (popular)
   /shoes/?size=10                  → Noindex
   /shoes/?color=red&size=10&...    → Noindex
   ```

**Результат:** Faceted navigation rules.

---

### 3.6 Шаг 6. E-commerce Structured Data

**Цель:** Внедрить schema для rich results.

**Действия:**
1. **Product Schema:**
   ```json
   {
     "@context": "https://schema.org",
     "@type": "Product",
     "name": "Nike Air Pegasus 40",
     "image": "https://example.com/shoe.jpg",
     "description": "Premium running shoes...",
     "brand": {
       "@type": "Brand",
       "name": "Nike"
     },
     "offers": {
       "@type": "Offer",
       "price": "129.99",
       "priceCurrency": "USD",
       "availability": "https://schema.org/InStock",
       "url": "https://example.com/shoe"
     },
     "aggregateRating": {
       "@type": "AggregateRating",
       "ratingValue": "4.5",
       "reviewCount": "127"
     }
   }
   ```

2. **Обязательные types:**
   - Product + Offer (price, availability)
   - AggregateRating (если есть reviews)
   - BreadcrumbList (на всех страницах)

3. **Rich results benefits:**
   - Product snippets: Price, availability, reviews
   - Merchant listings в Shopping tab
   - Price drop annotations
   - Shipping/returns info

4. **Валидация:**
   - Rich Results Test
   - Search Console → Enhancements → Product
   - Merchant Center → Diagnostics

**Результат:** Structured data implementation.

---

### 3.7 Шаг 7. Google Merchant Center Integration

**Цель:** Настроить Merchant Center.

**Действия:**
1. **Product Feed:**
   - Structured data file с product information
   - Форматы: XML, TXT, Google Sheets
   - Обязательные атрибуты:
     - id, title, description
     - link, image_link
     - price, availability
     - brand, gtin/mpn

2. **Benefits:**
   - Visibility в Shopping tab
   - Rich results с price, availability
   - Data verification
   - More frequent updates

3. **Feed optimization:**
   - Titles: Primary keyword + product + attribute
   - Descriptions: Unique, detailed
   - Images: High quality, white background
   - Categories: Правильная Google taxonomy

4. **Structured Data + MC:**
   - Оба источника дополняют друг друга
   - При расхождениях — MC может переопределить
   - Maintain consistency между website и feed

**Результат:** Merchant Center setup.

---

### 3.8 Шаг 8. Финальная проверка

**Цель:** Убедиться, что стратегия полная.

**Чек-лист:**
- [ ] Site architecture логичная, products в ≤3 кликах
- [ ] URL structure clean и readable
- [ ] Product descriptions уникальные (не manufacturer)
- [ ] Images optimized с alt text
- [ ] Reviews собираются и display
- [ ] Category pages имеют intro content
- [ ] Product schema добавлена
- [ ] AggregateRating schema для reviews
- [ ] Faceted navigation под контролем
- [ ] Google Merchant Center настроен
- [ ] Product feed актуальный

**Результат:** E-commerce SEO стратегия готова.

---

## 4. Структура результата

### 4.1 Шаблон стратегии

**Формат:**
```markdown
# E-commerce SEO Strategy: [Store Name]
**Дата:** [дата]

## Technical Audit Summary
- Products in index: [число] / [всего]
- Faceted URLs: [статус]
- Core Web Vitals: [статус]

## Architecture Recommendations
- [ ] [recommendation 1]
- [ ] [recommendation 2]

## Product Page Template
[структура и requirements]

## Category Optimization Plan
| Category | Current | Action |
|----------|---------|--------|

## Faceted Navigation Rules
| Filter Type | Action | Reason |
|-------------|--------|--------|

## Structured Data Status
- [ ] Product schema: [status]
- [ ] Offers: [status]
- [ ] Reviews: [status]

## Merchant Center
- Account: [status]
- Feed: [status]
- Errors: [число]

## Priority Actions
1. [action 1]
2. [action 2]
3. [action 3]
```

---

## 10. Артефакты

**Наименование файла:** `ecommerce_seo_strategy_{store}_{yyyymmdd}.md`
