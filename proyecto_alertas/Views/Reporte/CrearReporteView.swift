import SwiftUI
import MapKit
import CoreLocation

struct CrearReporteView: View {
    @Binding var isPresented: Bool
    var initialCoordinate: CLLocationCoordinate2D?
    var initialDistrito: String = "Lima"
    var initialAddress: String = ""

    @State private var titulo: String = ""
    @State private var descripcion: String = ""
    @State private var selectedTipo: String = "Robo"
    @State private var selectedDate: Date = Date()
    @State private var coordinate: CLLocationCoordinate2D
    @State private var selectedDistrito: String
    @State private var address: String
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -12.0264, longitude: -77.0444),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var isSaving: Bool = false
    @State private var isLoadingDistrito: Bool = false

    private let geocoder = CLGeocoder()

    private let tipos = ["Robo", "Asalto", "Robo de vehículo"]
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

    init(isPresented: Binding<Bool>, initialCoordinate: CLLocationCoordinate2D? = nil, initialDistrito: String = "Lima", initialAddress: String = "") {
        self._isPresented = isPresented
        self.initialCoordinate = initialCoordinate
        self._selectedDistrito = State(initialValue: initialDistrito)
        self._address = State(initialValue: initialAddress)

        let coord = initialCoordinate ?? CLLocationCoordinate2D(latitude: -12.0264, longitude: -77.0444)
        self._coordinate = State(initialValue: coord)
        self._region = State(initialValue: MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    private func obtenerDistritoDesdeCoordenada(_ coordinate: CLLocationCoordinate2D) async {
        await MainActor.run {
            isLoadingDistrito = true
        }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)

            guard let placemark = placemarks.first else {
                await MainActor.run {
                    isLoadingDistrito = false
                }
                return
            }

            let districtName = placemark.subLocality ?? placemark.locality ?? ""

            if districtName.isEmpty {
                await MainActor.run {
                    isLoadingDistrito = false
                }
                return
            }

            let matchedDistrito = distritos.first { $0.lowercased() == districtName.lowercased() }

            await MainActor.run {
                if let match = matchedDistrito {
                    selectedDistrito = match
                }
                isLoadingDistrito = false
            }
        } catch {
            await MainActor.run {
                isLoadingDistrito = false
            }
        }
    }

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

                            if !address.isEmpty {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundStyle(.orange)
                                    Text(address)
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(hex: "2D2D44"))
                                .cornerRadius(8)
                            }

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
                                Task {
                                    await obtenerDistritoDesdeCoordenada(context.region.center)
                                }
                            }

                            Text("Toca el mapa para mover el pin")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Distrito")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                if isLoadingDistrito {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                        .scaleEffect(0.8)
                                }
                            }

                            Picker("Distrito", selection: $selectedDistrito) {
                                ForEach(distritos, id: \.self) { distrito in
                                    Text(distrito).tag(distrito)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            .padding()
                            .background(Color(hex: "2D2D44"))
                            .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo de incidente")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Picker("Tipo", selection: $selectedTipo) {
                                ForEach(tipos, id: \.self) { tipo in
                                    Text(tipo).tag(tipo)
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
                                await guardarReporte()
                            }
                        } label: {
                            PrimaryButton(title: "Reportar", isLoading: isSaving)
                        }
                        .disabled(titulo.isEmpty || isSaving)
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
        .task {
            await obtenerDistritoDesdeCoordenada(coordinate)
        }
    }

    private func guardarReporte() async {
        isSaving = true

        let reporte = Reporte(
            id: UUID(),
            coordenada: coordinate,
            titulo: titulo,
            descripcion: descripcion,
            tipo: selectedTipo,
            distrito: selectedDistrito,
            fecha: selectedDate,
            usuarioId: nil
        )

        let viewModel = ReporteViewModel()
        let success = await viewModel.crearReporte(reporte)

        isSaving = false

        if success {
            isPresented = false
        } else {
            print("Error al guardar: \(viewModel.errorMessage ?? "Error desconocido")")
        }
    }
}

#Preview {
    CrearReporteView(isPresented: .constant(true))
}