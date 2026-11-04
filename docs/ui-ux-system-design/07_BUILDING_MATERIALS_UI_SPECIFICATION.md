# 07 — Building Materials & Electrical Supplies UI Specification

## 1. Vertical Overview & Commercial Context

The **Building Materials & Electrical Supplies** vertical (`/building-materials`) targets Egypt's vital construction, contracting, and infrastructure sectors. It brings together industrial manufacturers, steel rolling mills, cement distributors, electrical wholesale suppliers, and contractors.

In accordance with **ADR-001, ADR-008, and ADR-009**, the V1 release operates strictly as a **`contact_only` wholesale marketplace**. Commercial transactions, negotiations, and delivery scheduling take place via direct communication channels (in-app chat, supplier phone calls, or WhatsApp).

---

## 2. Strict Scope Boundary & Prototype UI Classification

> [!IMPORTANT]
> **Prototype UI Disclaimer**: The Flutter codebase currently contains functional prototype screens for Shopping Cart (`BuildingMaterialsCartPage`), Checkout (`BuildingMaterialsCheckoutPage`), Orders Feed (`BuildingMaterialsOrdersPage`), and Order Tracking (`BuildingMaterialsOrderDetailPage`). 
> 
> Under approved decisions **ADR-008 (Transaction Modes)** and **ADR-009 (Commerce Module Boundary)**, these screens are **strictly Tier 3 (Future V3 Features)**. In the approved V1 release:
> - The Cart and Checkout buttons must be replaced with "تواصل مع المورد" (Contact Supplier) or "طلب تسعير مباشر" (Direct Inquiry via Chat).
> - Orders and Staged Shipments are deferred until the V3 transactional commerce engine is launched.

---

## 3. Screen Specifications

### Screen: Building Materials Home & Price Ticker (`SCR-MAT-001`)

#### 1. Screen Identity
- **Screen ID:** `SCR-MAT-001`
- **Module:** Module E: Building Materials
- **Screen Name (AR):** سوق مواد البناء وتحديثات الأسعار
- **Screen Name (EN):** Building Materials Home & Price Ticker
- **Current Status:** **IMPLEMENTED** ([lib/features/building_materials/presentation/pages/building_materials_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/building_materials/presentation/pages/building_materials_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Contractor, Builder, Merchant
- **Entry Routes:** Home Category Tap, Bottom Nav Switcher (`/building-materials`)
- **Exit Routes:** `SCR-MAT-002` (Categories), `SCR-MAT-004` (Steel Rebar Listing), `SCR-MAT-005` (Product Detail)

#### 2. Layout Structure
```
+-------------------------------------------------------------+
| APP BAR: "مواد البناء والتأسيس"  [Search] [Daily Ticker Icon] |
+-------------------------------------------------------------+
| DAILY COMMODITY PRICE TICKER (SCR-MAT-001-A)                |
| [حديد عز: ٤١,٥٠٠ ج.م/طن ▲]  [أسمنت السويدي: ٢,١٥٠ ج.م/طن ▼]  |
+-------------------------------------------------------------+
| CONTRACTOR PROMOTIONAL HERO BANNER                          |
| "توريد مباشر من المصنع لموقع مشروعك بأفضل الأسعار"          |
+-------------------------------------------------------------+
| INDUSTRIAL CATEGORIES HORIZONTAL GRID (SCR-MAT-002)         |
| [حديد ومعادن]  [أسمنت وجبس]  [طوب وبلوك]  [كابلات وكهرباء]  |
+-------------------------------------------------------------+
| FEATURED SUPPLIERS & FACTORIES CAROUSEL                     |
| [مصنع السويس للصلب] [لافارج للأسمنت] [السويدي إلكتريك]       |
+-------------------------------------------------------------+
| RECENTLY ADDED MATERIAL PRODUCTS FEED                       |
| (Vertical list of MaterialProductCard components)           |
+-------------------------------------------------------------+
```

---

### Screen: Steel Rebar Specialized Daily Listing (`SCR-MAT-004`)

#### 1. Screen Identity
- **Screen ID:** `SCR-MAT-004`
- **Module:** Module E: Building Materials
- **Screen Name (AR):** شاشة حديد التسليح وبورصة الأسعار
- **Screen Name (EN):** Steel Rebar Specialized Daily Listing
- **Current Status:** **IMPLEMENTED** ([lib/features/building_materials/presentation/pages/steel_rebar_listing_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/building_materials/presentation/pages/steel_rebar_listing_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Contractor, Procurement Officer
- **Entry Routes:** Ticker tap or category select (`/building-materials/steel-rebar`)
- **Exit Routes:** `SCR-MAT-005` (Product Detail), Direct Call to Mill

#### 2. Specialized Functional Requirements
- **Live Mill Price Table:** Compares daily factory prices across top Egyptian steel mills (حديد عز، السويس للصلب، حديد المصريين، بشاي للصلب، المراكبي).
- **Diameter Spec Selector:** Chips to filter rebar diameters (١٠ مم، ١٢ مم، ١٦ مم، ١٨ مم).
- **Direct Dispatch Call:** Direct hotline button to authorized distribution depots.

---

### Screen: Material Product Detail Page (`SCR-MAT-005`)

#### 1. Screen Identity
- **Screen ID:** `SCR-MAT-005`
- **Module:** Module E: Building Materials
- **Screen Name (AR):** بطاقة تفاصيل مادة البناء والمنتج
- **Screen Name (EN):** Material Product Detail Page
- **Current Status:** **IMPLEMENTED** ([lib/features/building_materials/presentation/pages/building_material_product_detail_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/building_materials/presentation/pages/building_material_product_detail_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Buyer / Contractor
- **Entry Routes:** Product card tap (`/building-materials/product-detail?productId=:id`)
- **Exit Routes:** `SCR-CHT-002` (Chat Room), `SCR-MAT-006` (Supplier Profile)

#### 2. Layout Structure & UI Components
1. **Product Media Slider:** High-res photographs of raw materials, packaging, and manufacturer specification stamps.
2. **Pricing & Unit of Measure:**
   - Prominent price: `٤١,٥٠٠ ج.م / طن`
   - Minimum Order Quantity (MOQ): `أدنى كمية للتوريد: ٥ طن`
   - VAT & Transportation Note: `السعر شامل ضريبة القيمة المضافة / غير شامل النولون`
3. **Technical Specs Table:**
   - Grade / Standard: `مواصفة قياسية مصرية رقم ٢٦٢`
   - Manufacturer / Mill: `شركة حديد عز - الإسكندرية`
   - Available Inventory Location: `مستودع ٦ أكتوبر / العاشر من رمضان`
   - Packaging: `بندل مربوط ٥ طن / سلك رباط معتمد`
4. **Supplier Credential Card (`SCR-MAT-006`):** Verified industrial distributor badge, commercial registry number, address of nearest branch showroom.
5. **Persistent Contact Bar (V1 Approved):**
   - "تواصل فوري للشراء" (In-App Chat $\to$ `SCR-CHT-002`).
   - "اتصال هاتفي مباشر" (Direct phone dialer $\to$ `SCR-CHT-003`).
   - "طلب عرض سعر واتساب" (Native WhatsApp with auto-filled product SKU).

---

## 4. Building Materials Card System Specification

```
+--------------------------------------------------------------+
| MaterialProductCard Specification                            |
| Corner Radius: AppRadii.lg (16.0 dp), Elevation: Level 1     |
| Border: 1.0dp AppColors.border                               |
+--------------------------------------------------------------+
| Image Box: Square 1:1 or Landscape 4:3                       |
| - Top Right: Manufacturer Badge (e.g. "حديد عز")             |
| - Top Left: Delivery Badge ("توريد متاح لموقعك")             |
+--------------------------------------------------------------+
| Content Block:                                               |
| - Unit Price: ٤١,٥٠٠ ج.م (Large Cairo Bold)                  |
| - Product Title: حديد تسليح مشرشر عالي المقاومة قطر ١٦ مم     |
| - Specs Row: [أدنى طلب: ٥ طن] • [تسليم أرض المصنع]           |
| - Warehouse Location: [Pin Icon] "المنطقة الصناعية - العاشر" |
| - Footer: [Supplier Name] [Verified Factory / Distributor]   |
+--------------------------------------------------------------+
```

---

## 5. Building Materials Dynamic Attributes Schema (`category_fields`)

| Field Key | Label (AR) | Field Type | Required? | Validation Rules & Options |
|---|---|:---:|:---:|---|
| `material_category` | تصنيف المادة | `select` | **Yes** | `steel`, `cement`, `brick`, `cables`, `plumbing`, `insulation`, `sand_gravel` |
| `unit_of_measure` | وحدة القياس | `select` | **Yes** | `ton` (طن), `bag_50kg` (شيكارة ٥٠ كجم), `cubic_meter` (متر مكعب), `thousand_bricks` (ألف طوبة), `meter` (متر طولي) |
| `min_order_quantity`| الحد الأدنى للطلب | `number` | **Yes** | Min: `1` |
| `manufacturer` | المصنع أو العلامة التجارية | `text` | **Yes** | e.g. حديد عز، السويدي، أسمنت حلوان |
| `standard_spec` | المواصفة القياسية | `text` | No | e.g. ASTM A615, EN 10080, ES 262 |
| `freight_available` | إمكانية الشحن للموقع | `boolean` | **Yes** | `true`, `false` |
| `loading_crane` | توفر ونش تفريغ | `boolean` | No | `true`, `false` |
| `payment_on_delivery`| الدفع عند الاستلام | `boolean` | No | `true`, `false` |

