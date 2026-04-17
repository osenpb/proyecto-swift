# Plan de Migración a Firebase - Proyecto Alertas de Robo

## Estado Actual

- **Firebase Auth**: ✓ Implementado (login/registro)
- **Firebase Firestore**: ✗ No implementado para reportes
- **Geolocalización**: ✗ No implementada

## Objetivo

Implementar almacenamiento de reportes en Firestore y detección de ubicación actual del usuario.

---

## 1. Modelo de Datos - Firestore

### Colección: `reportes`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | String | UUID único del reporte |
| `titulo` | String | Título del incidente |
| `descripcion` | String | Descripción detallada |
| `tipo` | String | "Robo", "Asalto", "Robo de vehículo" |
| `distrito` | String | Distrito del incidente |
| `latitud` | Double | Coordenada latitud |
| `longitud` | Double | Coordenada longitud |
| `fecha` | Timestamp | Fecha del incidente |
| `usuarioId` | String | UID del usuario que creó el reporte |

---

## 2. Modelo - reporte.swift (SIN MODIFICAR)

**El modelo existente NO se modifica.** Se mantiene con `coordenada: CLLocationCoordinate2D` como está actualmente.

```swift
// Este archivo permanece sin cambios
struct Reporte: Identifiable, Equatable {
    var id = UUID()
    var coordenada: CLLocationCoordinate2D
    var titulo: String = ""
    var descripcion: String = ""
    var tipo: String = "Robo"
    var distrito: String = "Lima"
    var fecha: Date = Date()
    var usuarioId: String?
}
```

---

## 3. ViewModel - ReporteViewModel.swift (NUEVO)

**Crear archivo:** `ViewModels/ReporteViewModel.swift`

Este ViewModel contendrá todos los atributos y métodos CRUD hacia Firebase.

### Propiedades @Published

```swift
@Published var reportes: [Reporte] = []        // Lista de todos los reportes
@Published var reportesFiltrados: [Reporte] = []  // Reportes filtrados por distrito
@Published var isLoading: Bool = false         // Estado de carga
@Published var errorMessage: String?           // Mensaje de error
```

### Estructura interna para Firestore

El ViewModel usará una estructura interna para mapear datos a Firestore (latitud/longitud separadas):

```swift
struct ReporteData {
    var id: String
    var titulo: String
    var descripcion: String
    var tipo: String
    var distrito: String
    var latitud: Double
    var longitud: Double
    var fecha: Timestamp
    var usuarioId: String?
}
```

### Métodos CRUD

```swift
// Convertir modelo Reporte a ReporteData para Firestore
private func toFirestoreData(_ reporte: Reporte) -> [String: Any]

// Convertir documento de Firestore a modelo Reporte
private func fromFirestoreData(_ data: [String: Any], id: String) -> Reporte

// CREATE - Crear nuevo reporte
func crearReporte(_ reporte: Reporte) async -> Bool

// READ - Obtener todos los reportes
func obtenerReportes() async

// READ - Obtener reportes por distrito
func obtenerReportesPorDistrito(_ distrito: String) async

// UPDATE - Actualizar reporte (opcional)
func actualizarReporte(_ reporte: Reporte) async -> Bool

// DELETE - Eliminar reporte (opcional)
func eliminarReporte(_ reporteId: String) async -> Bool
```

---

## 4. Geolocalización - LocationManager

**Implementar en:** `CrearReporteView.swift`

### Funcionalidad
- Detectar ubicación actual automáticamente al abrir la vista
- Mostrar botón para actualizar ubicación
- Solicitar permisos de ubicación al usuario

### LocationManager personalizado

El ViewModel incluirá un `LocationManager` para obtener la ubicación actual:

```swift
class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D?
    
    func requestLocation()
    func requestAuthorization()
}
```

### Permisos requeridos (Info.plist)
- `NSLocationWhenInUseUsageDescription`

---

## 5. Modificaciones en Vistas

### CrearReporteView.swift
- Usar `ReporteViewModel` como `@StateObject` o `@EnvironmentObject`
- En `onAppear`: solicitar permisos y obtener ubicación actual
- Al guardar, pasar el `usuarioId` desde `Auth.auth().currentUser?.uid`
- Llamar a `reporteViewModel.crearReporte()`

### DashboardView.swift
- Agregar `@StateObject reporteViewModel: ReporteViewModel`
- En `onAppear`: cargar reportes con `reporteViewModel.obtenerReportes()`
- Reemplazar `reportesDemo` con `reporteViewModel.reportes`

---

## 6. Archivos a Modificar/Crear

| Archivo | Acción | Descripción |
|---------|--------|--------------|
| `ViewModels/ReporteViewModel.swift` | Crear | ViewModel con atributos + CRUD completo + LocationManager |
| `Views/Reporte/CrearReporteView.swift` | Modificar | Agregar geolocalización y guardar en Firestore |
| `Views/Dashboard/DashboardView.swift` | Modificar | Cargar reportes desde ViewModel |
| `Views/Reporte/BuscarReportesView.swift` | Modificar | Usar reportes desde ViewModel |
| `Models/reporte.swift` | Sin cambios | Se mantiene como está |

---

## 7. Dependencias Requeridas

### Swift Package Manager
```swift
// Agregar FirebaseFirestore
FirebaseFirestore (latest)
```

### Info.plist
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para registrar la ubicación del incidente</string>
```

---

## 8. Flujo de Usuario

```
1. Usuario inicia sesión (Firebase Auth) ✓
2. Usuario toca botón "+" en Dashboard
3. Se abre CrearReporteView
4. App detecta ubicación actual automáticamente
5. Usuario completa formulario (título, descripción, tipo, etc.)
6. Usuario toca "Reportar"
7. ViewModel convierte Reporte a formato Firestore
8. ViewModel guarda en Firestore con usuarioId
9. Dashboard actualiza markers desde ViewModel.reportes
```

---

## 9. Consideraciones de Seguridad

- Solo usuarios autenticados pueden crear reportes
- El `usuarioId` se obtiene de `Auth.auth().currentUser?.uid`
- Validar que el usuario esté autenticado antes de guardar

---

## 10. Notas Adicionales

- El modelo `tipoReporte.swift` puede mantener los tipos predefinidos
- La geolocalización debe manejar casos de error (permiso denegado, ubicación no disponible)
- Considerar paginación si hay muchos reportes