import Foundation

enum TipoReporte: String, CaseIterable, Identifiable {
    case robo = "Robo"
    case intentoRobo = "Intento de Robo"
    case sospecha = "Actividad Sospechosa"
    case otro = "Otro"

    var id: String { rawValue }
}