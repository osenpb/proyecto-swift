import SwiftUI
import MapKit

struct BuscarReportesView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = ReporteViewModel()
    @State private var searchText: String = ""
    @State private var selectedDistrito: String? = nil

    private let distritos = [
        "Lima", "Ancón", "Ate", "Barranco", "Bellavista", "Breña", "Callao",
        "Carmen de la Legua Reynoso", "Chaclacayo", "Chorrillos", "Comas",
        "El Agustino", "Independencia", "Jesús María", "La Molina", "La Perla",
        "La Punta", "Lurigancho", "Lurín", "Magdalena del Mar", "Miraflores",
        "Pachacámac", "Pucusana", "Pueblo Libre", "Puente Piedra", "Punta Hermosa",
        "Punta Negra", "Rímac", "San Bartolo", "San Borja", "San Juan de Lurigancho",
        "San Juan de Miraflores", "San Luis", "San Martín de Porres", "San Miguel",
        "Santa Anita", "Santa María del Mar", "Santa Rosa", "Surco", "Surquillo",
        "San Isidro", "Villa El Salvador", "Villa María del Triunfo"
    ]

    var reportesFiltrados: [Reporte] {
        var result = viewModel.reportes

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

                    HStack {
                        Text("Distrito")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Spacer()

                        Picker("Distrito", selection: $selectedDistrito) {
                            Text("Todos").tag(nil as String?)
                            ForEach(distritos, id: \.self) { distrito in
                                Text(distrito).tag(distrito as String?)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.orange)
                    }
                    .padding()
                    .background(Color(hex: "2D2D44"))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            .scaleEffect(1.5)
                        Spacer()
                    } else if reportesFiltrados.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundStyle(.gray)
                            Text("No se encontraron reportes")
                                .font(.headline)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(reportesFiltrados) { reporte in
                                    ReporteCard(reporte: reporte)
                                }
                            }
                            .padding(.horizontal)
                        }
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
        .task {
            await viewModel.obtenerReportes()
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

                Text(!reporte.ubicacion.isEmpty ? reporte.ubicacion : reporte.distrito)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
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
