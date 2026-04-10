# Arquitectura del Proyecto - Alertas de Robo

## Descripción
Aplicación iOS (SwiftUI) para reportar y visualizar casos de robo en tu zona.

## Arquitectura Recomendada: MVVM

**Por qué MVVM:** SwiftUI es nativamente MVVM con `@StateObject`, `@Published`. Firebase + Maps requieren manejo de estado async = perfecto para ViewModels.

## Flujo de Navegación Propuesto

```
LoginView → RegisterView
           ↓
      DashboardView (PANTALLA PRINCIPAL con mapa)
      ├── Toolbar: Botón "Buscar" → sheet modal para buscar reportes por distrito
      └── Toolbar: Botón "+" → sheet modal para crear nuevo reporte
          └── fullScreenCover para formulario completo de creación
```

## Pantallas

1. **Login** - Autenticación de usuarios
2. **Registro** - Crear nueva cuenta
3. **DashboardView (Principal)** - Mapa con markers de reportes recientes
   - Toolbar con botón "Buscar" → abre modal de búsqueda por distrito
   - Toolbar con botón "+" → abre modal de crear reporte
   - Marker toca → sheet con detalles del reporte
4. **Crear Reporte** - Modal (fullScreenCover) con formulario para reportar robos
5. **Buscar Reporte** - Modal (sheet) con lista/búsqueda de reportes por distrito

## Cambios Recientes
- Pantalla principal = Dashboard con mapa
- "Crear Reporte" se abre como modal desde el mapa
- "Buscar Reportes por Distrito" se abre como modal desde el mapa
- Navegación simple: solo mapa como pantalla principal post-login

```
proyecto_alertas/
├── proyecto_alertasApp.swift       # Entry point
├── ContentView.swift               # Root view + NavigationStack
├── Models/                         # Datos
│   ├── reporte.swift              # Modelo de reporte
│   └── tipoReporte.swift          # Tipos de reporte
├── ViewModels/                    # Lógica de negocio
│   ├── AuthViewModel.swift        # Login/Registro
│   └── MapViewModel.swift         # Mapa, reportes y ubicación
├── Views/                         # UI - SwiftUI
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   └── Dashboard/
│       └── DashboardView.swift    # Pantalla única con mapa
├── Services/                      # Integraciones externas
│   └── FirebaseService.swift     # Auth + Firestore
├── Utilities/                    # Helpers
│   └── Extensions.swift
└── Assets.xcassets/              # Recursos
```

## Flujo de Navegación (Opción C - Todo en el Mapa)

```
LoginView → RegisterView
           ↓
      DashboardView (pantalla principal con mapa)
      ├── Marker toca → sheet con detalles del reporte
      └── FAB (+) toca → sheet/modal para crear nuevo reporte
          └── fullScreenCover para formulario completo
```

## Componentes UI

```
├── DashboardView           # Pantalla principal con mapa
├── ReporteDetailSheet      # Modal - ver detalles al tocar marker
├── CrearReporteView        # Modal (fullScreenCover) - formulario crear reporte
├── BuscarReportesView      # Modal (sheet) - buscar reportes por distrito
├── FloatingActionButton   # Botón flotante (+) en el mapa
└── ToolbarButtons         # Botones en toolbar del mapa
```

## Dependencias
- Google Maps SDK (iOS)
- Firebase (Auth + Firestore)

## Data Binding (MVVM)

```
Views ←→ ViewModels (@Published) ←→ Services (Firebase)
```

- **Views**: Suscriben a `@StateObject` / `@ObservedObject`
- **ViewModels**: Publican cambios con `@Published`
- **Models**: Structs inmutables para datos
- **Services**: APIs externas (Firebase)