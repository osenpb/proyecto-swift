import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

final class ReporteViewModel: ObservableObject {
    @Published var reportes: [Reporte] = []
    @Published var reportesFiltrados: [Reporte] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let ubicacionDefault = CLLocationCoordinate2D(latitude: -12.0264, longitude: -77.0444)

    private let db = Firestore.firestore()

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

    private func toFirestoreData(_ reporte: Reporte) -> [String: Any] {
        return [
            "id": reporte.id.uuidString,
            "titulo": reporte.titulo,
            "descripcion": reporte.descripcion,
            "tipo": reporte.tipo,
            "distrito": reporte.distrito,
            "latitud": reporte.coordenada.latitude,
            "longitud": reporte.coordenada.longitude,
            "fecha": Timestamp(date: reporte.fecha),
            "usuarioId": reporte.usuarioId ?? ""
        ]
    }

    private func fromFirestoreData(_ data: [String: Any], id: String) -> Reporte {
        let latitud = data["latitud"] as? Double ?? 0.0
        let longitud = data["longitud"] as? Double ?? 0.0
        let timestamp = data["fecha"] as? Timestamp

        return Reporte(
            id: UUID(uuidString: id) ?? UUID(),
            coordenada: CLLocationCoordinate2D(latitude: latitud, longitude: longitud),
            titulo: data["titulo"] as? String ?? "",
            descripcion: data["descripcion"] as? String ?? "",
            tipo: data["tipo"] as? String ?? "Robo",
            distrito: data["distrito"] as? String ?? "Lima",
            fecha: timestamp?.dateValue() ?? Date(),
            usuarioId: data["usuarioId"] as? String
        )
    }

    func crearReporte(_ reporte: Reporte) async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Debes iniciar sesión para crear un reporte"
            return false
        }

        isLoading = true
        errorMessage = nil

        var reporteConUsuario = reporte
        reporteConUsuario.usuarioId = userId

        do {
            var data = toFirestoreData(reporteConUsuario)
            data["usuarioId"] = userId

            try await db.collection("reportes").addDocument(data: data)
            await MainActor.run {
                self.reportes.append(reporteConUsuario)
                self.isLoading = false
            }
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Error al crear reporte: \(error.localizedDescription)"
                self.isLoading = false
            }
            return false
        }
    }

    func obtenerReportes() async {
        isLoading = true
        errorMessage = nil

        do {
            let snapshot = try await db.collection("reportes").getDocuments()
            var reportesList: [Reporte] = []

            for document in snapshot.documents {
                let data = document.data()
                if let id = data["id"] as? String {
                    let reporte = fromFirestoreData(data, id: id)
                    reportesList.append(reporte)
                }
            }

            await MainActor.run {
                self.reportes = reportesList
                self.reportesFiltrados = reportesList
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error al obtener reportes: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    func obtenerReportesPorDistrito(_ distrito: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let snapshot = try await db.collection("reportes")
                .whereField("distrito", isEqualTo: distrito)
                .getDocuments()

            var reportesList: [Reporte] = []

            for document in snapshot.documents {
                let data = document.data()
                if let id = data["id"] as? String {
                    let reporte = fromFirestoreData(data, id: id)
                    reportesList.append(reporte)
                }
            }

            await MainActor.run {
                self.reportesFiltrados = reportesList
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error al buscar reportes: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    func actualizarReporte(_ reporte: Reporte) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let snapshot = try await db.collection("reportes")
                .whereField("id", isEqualTo: reporte.id.uuidString)
                .getDocuments()

            guard let document = snapshot.documents.first else {
                errorMessage = "Reporte no encontrado"
                isLoading = false
                return false
            }

            try await document.reference.updateData(toFirestoreData(reporte))

            if let index = reportes.firstIndex(where: { $0.id == reporte.id }) {
                await MainActor.run {
                    self.reportes[index] = reporte
                    self.isLoading = false
                }
            }
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Error al actualizar: \(error.localizedDescription)"
                self.isLoading = false
            }
            return false
        }
    }

    func eliminarReporte(_ reporteId: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let snapshot = try await db.collection("reportes")
                .whereField("id", isEqualTo: reporteId)
                .getDocuments()

            guard let document = snapshot.documents.first else {
                errorMessage = "Reporte no encontrado"
                isLoading = false
                return false
            }

            try await document.reference.delete()

            await MainActor.run {
                self.reportes.removeAll { $0.id.uuidString == reporteId }
                self.reportesFiltrados.removeAll { $0.id.uuidString == reporteId }
                self.isLoading = false
            }
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Error al eliminar: \(error.localizedDescription)"
                self.isLoading = false
            }
            return false
        }
    }
}