import SwiftUI
import MapKit

struct BuscarReportesView: View {
    @Binding var isPresented: Bool
    @State private var searchText: String = ""
    @State private var selectedDistrito: String? = nil
    @State private var reportes: [Reporte] = [
        Reporte(coordenada: CLLocationCoordinate2D(latitude: -12.05, longitude: -77.03), titulo: "Robo en tienda", descripcion: "Robo a mano armada en tienda de conveniencia", tipo: "Robo", distrito: "Miraflores"),
        Reporte(coordenada: CLLocationCoordinate2D(latitude: -12.04, longitude: -77.05), titulo: "Asalto en calle", descripcion: "Asalto a transeúnte", tipo: "Asalto", distrito: "Lima"),
        Reporte(coordenada: CLLocationCoordinate2D(latitude: -12.06, longitude: -77.04), titulo: "Robo de vehículo", descripcion: "Auto robado en estacionamiento", tipo: "Robo de vehículo", distrito: "Surco"),
        Reporte(coordenada: CLLocationCoordinate2D(latitude: -12.03, longitude: -77.06), titulo: "Intento de robo", descripcion: "Intentaron robarme en el metro", tipo: "Robo", distrito: "Cercado")
    ]

    private let distritos = ["Lima", "Cercado", "Miraflores", "San Juan de Lurigancho", "Callao", "Surco", "Barranco"]

    var reportesFiltrados: [Reporte] {
        var result = reportes

        if let distrito = selectedDistrito {
            result = result.filter { $0.distrito == distrito }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.titulo.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)

                        TextField("Buscar reportes...", text: $searchText)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(Color(hex: "2D2D44"))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(distritos, id: \.self) { distrito in
                                Button {
                                    if selectedDistrito == distrito {
                                        selectedDistrito = nil
                                    } else {
                                        selectedDistrito = distrito
                                    }
                                } label: {
                                    Text(distrito)
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedDistrito == distrito ? Color.orange : Color(hex: "2D2D44"))
                                        .foregroundStyle(.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(reportesFiltrados) { reporte in
                                ReporteCard(reporte: reporte)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("Buscar Reportes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        isPresented = false
                    }
                    .foregroundStyle(.orange)
                }
            }
            .toolbarBackground(Color(hex: "1A1A2E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct ReporteCard: View {
    let reporte: Reporte

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: tipoIcon(for: reporte.tipo))
                    .foregroundStyle(.orange)

                Text(reporte.titulo)
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                tipoBadge(reporte.tipo)
            }

            Text(reporte.descripcion)
                .font(.subheadline)
                .foregroundStyle(.gray)
                .lineLimit(2)

            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundStyle(.gray)

                Text("Hace 2 horas")
                    .font(.caption)
                    .foregroundStyle(.gray)

                Spacer()

                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundStyle(.gray)

                Text(reporte.distrito)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding()
        .background(Color(hex: "2D2D44"))
        .cornerRadius(12)
    }

    private func tipoIcon(for tipo: String) -> String {
        switch tipo {
        case "Asalto": return "person.fill.questionmark"
        case "Robo de vehículo": return "car.fill"
        default: return "exclamationmark.triangle.fill"
        }
    }

    private func tipoBadge(_ tipo: String) -> some View {
        Text(tipo)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.orange.opacity(0.2))
            .foregroundStyle(.orange)
            .cornerRadius(8)
    }
}

#Preview {
    BuscarReportesView(isPresented: .constant(true))
}
