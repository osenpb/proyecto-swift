import CoreLocation
import Foundation

struct Reporte: Identifiable, Equatable {
    var id = UUID()
    var coordenada: CLLocationCoordinate2D
    var titulo: String = ""
    var descripcion: String = ""
    var tipo: TipoReporte = .robo
    var fecha: Date = Date()
    var usuarioId: String?

    static func == (lhs: Reporte, rhs: Reporte) -> Bool {
        lhs.id == rhs.id
    }
}