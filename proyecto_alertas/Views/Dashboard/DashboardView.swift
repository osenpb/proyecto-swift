import SwiftUI
import MapKit
import CoreLocation

struct DashboardView: View {
    @Binding var isAuthenticated: Bool
    @StateObject private var reporteViewModel = ReporteViewModel()
    @State private var showCrearReporte: Bool = false
    @State private var showBuscarReportes: Bool = false
    @State private var selectedCoordinate: CLLocationCoordinate2D
    @State private var selectedDistrito: String = "Lima"
    @State private var selectedAddress: String = ""

    init(isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
        self._selectedCoordinate = State(initialValue: CLLocationCoordinate2D(latitude: -12.0264, longitude: -77.0444))
    }

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: reporteViewModel.ubicacionDefault,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    var body: some View {
        ZStack {
            MapReader { proxy in
                ZStack {
                    Map(position: .constant(.region(region))) {
                        ForEach(reporteViewModel.reportes) { reporte in
                            Annotation("", coordinate: reporte.coordenada) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    
                    Color.clear
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 4)
                                .sequenced(before: DragGesture(minimumDistance: 0))
                                .onEnded { value in
                                    switch value {
                                    case .second(true, let drag):
                                        if let location = drag?.location,
                                           let coordinate = proxy.convert(location, from: .local) {
                                            selectedCoordinate = coordinate
                                            showCrearReporte = true
                                        }
                                    default:
                                        break
                                    }
                                }
                        )
                }
            }
            .ignoresSafeArea()

            if reporteViewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
            }

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    VStack(spacing: 16) {
                        Button {
                            showBuscarReportes = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }

                        Button {
                            selectedCoordinate = reporteViewModel.ubicacionDefault
                            showCrearReporte = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .fullScreenCover(isPresented: $showCrearReporte) {
            CrearReporteView(
                isPresented: $showCrearReporte,
                initialCoordinate: selectedCoordinate,
                initialDistrito: selectedDistrito,
                initialAddress: selectedAddress
            )
            .onDisappear {
                Task {
                    await reporteViewModel.obtenerReportes()
                }
            }
        }
        .sheet(isPresented: $showBuscarReportes) {
            BuscarReportesView(
                isPresented: $showBuscarReportes
                //reportes: reporteViewModel.reportes
            )
        }
        .onAppear {
            Task {
                await reporteViewModel.obtenerReportes()
            }
        }
    }
}

#Preview {
    DashboardView(isAuthenticated: .constant(true))
}
