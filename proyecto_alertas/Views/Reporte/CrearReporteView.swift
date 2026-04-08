import SwiftUI
import MapKit

struct CrearReporteView: View {
    @Binding var isPresented: Bool
    @State private var titulo: String = ""
    @State private var descripcion: String = ""
    @State private var selectedTipo: TipoReporte = .robo
    @State private var selectedDate: Date = Date()
    @State private var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var isSaving: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ubicación del incidente")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text("Mantén presionado en el mapa para marcar la ubicación")
                                .font(.caption)
                                .foregroundStyle(.gray)

                            Map(position: .constant(.region(region))) {
                                Annotation("", coordinate: coordinate) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundStyle(.orange)
                                }
                            }
                            .frame(height: 200)
                            .cornerRadius(12)
                            .onMapCameraChange(frequency: .onEnd) { context in
                                self.coordinate = context.region.center
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo de incidente")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Picker("Tipo", selection: $selectedTipo) {
                                ForEach(TipoReporte.allCases, id: \.self) { tipo in
                                    Text(tipo.rawValue).tag(tipo)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Título")
                                .font(.headline)
                                .foregroundStyle(.white)

                            CustomTextField(
                                placeholder: "Ej: Robo en la calle principal",
                                text: $titulo,
                                icon: "textformat"
                            )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción")
                                .font(.headline)
                                .foregroundStyle(.white)

                            TextEditor(text: $descripcion)
                                .frame(height: 100)
                                .scrollContentBackground(.hidden)
                                .padding()
                                .background(Color(hex: "2D2D44"))
                                .cornerRadius(12)
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha del incidente")
                                .font(.headline)
                                .foregroundStyle(.white)

                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }

                        Button {
                            Task {
                                isSaving = true
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                isSaving = false
                                isPresented = false
                            }
                        } label: {
                            PrimaryButton(title: "Reportar", isLoading: isSaving)
                        }
                        .disabled(titulo.isEmpty)
                        .opacity(titulo.isEmpty ? 0.6 : 1)
                    }
                    .padding()
                }
            }
            .navigationTitle("Nuevo Reporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
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

#Preview {
    CrearReporteView(isPresented: .constant(true))
}