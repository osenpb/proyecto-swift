import SwiftUI
import MapKit

struct DashboardView: View {
    @Binding var isAuthenticated: Bool
    @State private var showCrearReporte: Bool = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: reportesDemo) { reporte in
                MapMarker(coordinate: reporte.coordenada, tint: .red)
            }
            .ignoresSafeArea()

            VStack {
                Spacer()

                HStack {
                    Spacer()

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
                    .padding(.trailing, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .fullScreenCover(isPresented: $showCrearReporte) {
            CrearReporteView(isPresented: $showCrearReporte)
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