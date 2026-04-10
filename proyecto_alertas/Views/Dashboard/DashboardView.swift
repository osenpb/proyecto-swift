import SwiftUI
import MapKit
import CoreLocation

struct DashboardView: View {
    @Binding var isAuthenticated: Bool
    @State private var showCrearReporte: Bool = false
    @State private var showBuscarReportes: Bool = false
    @State private var selectedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428)
    @State private var selectedDistrito: String = "Lima"
    @State private var selectedAddress: String = ""
    @State private var isLoadingLocation: Bool = false

    private let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        ZStack {
            Map(position: .constant(.region(region))) {
                ForEach(reportesDemo) { reporte in
                    Annotation("", coordinate: reporte.coordenada) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                }
            }
            .ignoresSafeArea()

            if isLoadingLocation {
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
        }
        .sheet(isPresented: $showBuscarReportes) {
            BuscarReportesView(isPresented: $showBuscarReportes)
        }
    }
}

private let reportesDemo: [Reporte] = [
    Reporte(coordenada: CLLocationCoordinate2D(latitude: -12.05, longitude: -77.03)),
    Reporte(coordenada: CLLocationCoordinate2D(latitude: -12.04, longitude: -77.05)),
    Reporte(coordenada: CLLocationCoordinate2D(latitude: -12.06, longitude: -77.04))
]

#Preview {
    DashboardView(isAuthenticated: .constant(true))
}