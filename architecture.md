# Arquitectura del Proyecto - Alertas de Robo

## Descripción
Aplicación iOS (SwiftUI) para reportar y visualizar casos de robo en tu zona.

## Arquitectura Recomendada: MVVM

**Por qué MVVM:** SwiftUI es nativamente MVVM con `@StateObject`, `@Published`. Firebase + Maps requieren manejo de estado async = perfecto para ViewModels.

## Pantallas

1. **Login** - Autenticación de usuarios
2. **Registro** - Crear nueva cuenta
3. **Crear Reporte** - Formulario con mapa para reportar robos y visualizar casos recientes
4. **Buscar Reporte** - Lista/búsqueda de reportes existentes

## Estructura del Proyecto

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
├── DashboardView        # Pantalla principal con mapa
├── ReporteDetailSheet   # Modal - ver detalles al tocar marker
├── CrearReporteSheet    # Modal - formulario crear reporte (fullScreenCover)
└── FloatingActionButton # Botón flotante (+) en el mapa
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