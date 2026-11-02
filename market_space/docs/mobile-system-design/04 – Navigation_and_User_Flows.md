# 04 – Navigation & User Flows

## 1. Navigation Architecture Overview

Navigation in Deal One is driven by `GoRouter` (v14.6.2) defined in [lib/app/app_router.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app_router.dart). The application uses a hybrid navigation strategy combining a root-level persistent **Tab Shell** (`GlobalNavigationScaffold`) and imperative/declarative **Sub-Route Pushes** for detail screens, wizards, and specialized flows.

```
Root App Entry Point: '/' -> GlobalNavigationScaffold (IndexedStack)
├── Tab 0: Home ('/')
├── Tab 1: Explore ('/explore')
├── Tab 2: Activity ('/activity')
├── Tab 3: Favorites ('/favorites')
└── Tab 4: Profile ('/profile')
```

Sub-routes are pushed on top of the root navigator (`rootNavigatorKey`), hiding the global bottom navigation bar when navigating into full-screen experiences like detail pages, checkout funnels, and maps.

---

## 2. Complete Application Route Inventory

The following table documents all declared routes in `app_router.dart`:

| Route Path | Route Name Constant | Target Screen Widget | Navigation Type | Access Level |
|---|---|---|---|---|
| `/` | `RouteNames.root` | `GlobalNavigationScaffold` | Shell Root | Public |
| `/real-estate` | `RouteNames.realEstate` | `RealEstatePage` | Push / Nav | Public |
| `/real-estate/detail` | `RouteNames.realEstateDetail` | `RealEstateDetailPage` | Push | Public |
| `/real-estate/map` | `RouteNames.realEstateMap` | `RealEstateMapPage` | Push | Public |
| `/real-estate/reels` | `RouteNames.realEstateReels` | `RealEstateReelsPage` | Push | Public |
| `/real-estate/favorites` | `RouteNames.realEstateFavorites` | `RealEstateFavoritesPage` | Push | Public |
| `/real-estate/saved-searches`| `RouteNames.realEstateSavedSearches`| `RealEstateSavedSearchesPage` | Push | Public |
| `/building-materials` | `RouteNames.buildingMaterials` | `BuildingMaterialsPage` | Push / Nav | Public |
| `/building-materials/category` | `RouteNames.buildingMaterialsCategoryDetail` | `BuildingMaterialsCategoryDetailPage` | Push | Public |
| `/building-materials/cart` | `RouteNames.buildingMaterialsCart` | `BuildingMaterialsCartPage` | Push | Public |
| `/building-materials/checkout` | `RouteNames.buildingMaterialsCheckout` | `BuildingMaterialsCheckoutPage` | Push | Public |
| `/building-materials/rfq/create` | `RouteNames.buildingMaterialsRfqCreate` | `RfqCreatePage` | Push | Public |
| `/home-services` | `RouteNames.homeServices` | `HomeServicesCatalogPage` | Push / Nav | Public |
| `/home-services/ac-service` | `RouteNames.acServiceDetail` | `AcServiceDetailPage` | Push | Public |
| `/home-services/booking-wizard` | `RouteNames.homeServicesBookingWizard` | `HomeServicesBookingWizardPage` | Push | Public |
| `/home-services/technician-tracking` | `RouteNames.homeServicesTechnicianTracking` | `TechnicianTrackingPage` | Push | Public |
| `/home-appliances` | `RouteNames.homeAppliances` | `HomeAppliancesCatalogPage` | Push / Nav | Public |
| `/home-appliances/cart` | `RouteNames.homeAppliancesCart` | `HomeAppliancesCartPage` | Push | Public |
| `/home-appliances/checkout` | `RouteNames.homeAppliancesCheckout` | `HomeAppliancesCheckoutPage` | Push | Public |
| `/cars` | `RouteNames.cars` | `CarsPage` | Push / Nav | Public |
| `/cars/detail` | `RouteNames.carDetail` | `CarDetailPage` | Push | Public |
| `/fashion` | `RouteNames.fashion` | `FashionCatalogPage` | Push / Nav | Public |
| `/fashion/cart` | `RouteNames.fashionCart` | `FashionCartPage` | Push | Public |
| `/notifications` | `RouteNames.notifications` | `NotificationsPage` | Push | Public |

---

## 3. Route Protection, Splash & Authentication Flow Reality

- **Splash Screen**: **NOT IMPLEMENTED**. The application boots synchronously from `main.dart` through `bootstrap.dart` into `AppRouter` without an animated splash or branded launch delay.
- **Onboarding Flow**: **NOT IMPLEMENTED**. There is no onboarding tutorial or welcome carousel for new users.
- **Authentication Screens**: **NOT IMPLEMENTED**. Although auth endpoints exist in `ApiEndpoints`, there are no UI screens for Login, Phone Verification, OTP input, or Registration.
- **Route Protection**: **PLACEHOLDER**. `SessionRouteGuard` ([route_guards.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/routing/route_guards.dart)) implements the `RouteGuard` contract, but its `evaluateRedirect()` method unconditionally returns `null`:
  ```dart
  class SessionRouteGuard implements RouteGuard {
    @override
    String? evaluateRedirect(BuildContext context, GoRouterState state) {
      // Unconditionally permits navigation to any route without session checks
      return null;
    }
  }
  ```
  Consequently, all screens in the application operate with full guest access.

---

## 4. Reverse-Engineered User Journey Diagrams

### 4.1 Application Launch & Global Shell Journey
```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Main as main.dart
    participant Bootstrap as bootstrap.dart
    participant AppRouter as AppRouter (GoRouter)
    participant Shell as GlobalNavigationScaffold
    participant Home as HomePage

    User->>Main: Launch Mobile App
    Main->>Bootstrap: bootstrap()
    Bootstrap->>Bootstrap: Init Storage & AppDependencies
    Bootstrap->>AppRouter: Create GoRouter (initialLocation: '/')
    AppRouter->>Shell: Build Shell Scaffold (IndexedStack)
    Shell->>Home: Render Tab 0 (HomePage)
    Home-->>User: Display Banners, Sector Grid & Popular Services
```

### 4.2 Real Estate Discovery & Interactive Map Journey
```mermaid
flowchart TD
    Start([User on HomePage]) --> ClickRE[Click Real Estate Sector Card]
    ClickRE --> NavRE[Navigate to '/real-estate']
    NavRE --> REPage[RealEstatePage: View Property Cards]
    
    REPage --> FilterTab{User Action}
    FilterTab -->|Select Category| SwitchTab[Filter by Villas / Apartments / Commercial]
    FilterTab -->|Click Map Icon| NavMap[Navigate to '/real-estate/map']
    FilterTab -->|Click Reels Tab| NavReels[Navigate to '/real-estate/reels']
    FilterTab -->|Click Property Card| NavDetail[Navigate to '/real-estate/detail']

    NavMap --> RenderOSM[Render OSM Tiles + Map Markers]
    RenderOSM --> TapMarker[Tap Price Marker -> Show Property Bottom Card]
    TapMarker --> NavDetail

    NavDetail --> ViewMedia[View Photo Gallery Carousel]
    ViewMedia --> CalcMortgage[Adjust Loan Calculator Sliders]
    CalcMortgage --> ContactBroker[Click Call or WhatsApp Button]
    ContactBroker --> End([External App Triggered / Interaction Logged])
```

### 4.3 Home Services: 6-Step Booking Wizard Journey
```mermaid
stateDiagram-v2
    [*] --> Catalog: User navigates to '/home-services'
    Catalog --> ServiceDetail: Select 'AC Service' ('/home-services/ac-service')
    ServiceDetail --> BookingWizard: Click 'احجز الآن' ('/home-services/booking-wizard')
    
    state BookingWizard {
        [*] --> Step1: Step 1 - Choose Sub-Services & Problem Type
        Step1 --> Step2: Next -> Step 2 - Select Appointment Date & Time Slot
        Step2 --> Step3: Next -> Step 3 - Enter Address, City & Apt Number
        Step3 --> Step4: Next -> Step 4 - Select Technician Tier (Engineer / Specialist)
        Step4 --> Step5: Next -> Step 5 - Review Order & Apply Promo Code
        Step5 --> Step6: Confirm Booking -> Step 6 - Order Receipt & Tracking Prompt
    }

    BookingWizard --> TrackingPage: Tap 'تتبع الفني' ('/home-services/technician-tracking')
    TrackingPage --> [*]: Real-time status: Confirmed -> Assigned -> En Route -> Arrived
```

### 4.4 Building Materials: Daily Factory Prices & RFQ Submission
```mermaid
sequenceDiagram
    autonumber
    actor Contractor as Contractor / Engineer
    participant BMPage as BuildingMaterialsPage
    participant DailyTicker as DailyPriceBanner
    participant RFQPage as RfqCreatePage
    participant ActivityRepo as UnifiedActivityRepository

    Contractor->>BMPage: Open '/building-materials'
    BMPage->>DailyTicker: Fetch Daily Quotes (Ezz Steel, Suez Cement)
    DailyTicker-->>Contractor: Display Live Prices per Metric Ton (EGP)
    Contractor->>BMPage: Click 'طلب تسعير مشروع (RFQ)'
    BMPage->>RFQPage: Open '/building-materials/rfq/create'
    Contractor->>RFQPage: Fill Project Details (Name, Governorate, Tonnage)
    Contractor->>RFQPage: Attach Required Delivery Schedule & Terms
    Contractor->>RFQPage: Submit RFQ Form
    RFQPage->>ActivityRepo: Append RFQ to User Activity Timeline
    RFQPage-->>Contractor: Display Success Dialog & Order Reference
```

### 4.5 Global Cross-Sector Search Journey
```mermaid
flowchart LR
    ExploreTab[Tap Explore Tab] --> RenderSearch[ExplorePage: Search Bar + Tags]
    RenderSearch --> TypeQuery[Type 'فيلا' or 'حديد 12 مم' or 'صيانة تكييف']
    TypeQuery --> FilterSector[Filter by Sector Chips or 'All']
    FilterSector --> Results[Unified Results List]
    Results --> ClickResult[Click Result Item]
    ClickResult --> RouteTarget[Navigate Directly to Item Detail Screen]
```
