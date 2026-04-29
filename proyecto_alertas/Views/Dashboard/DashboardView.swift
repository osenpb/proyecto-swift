import SwiftUI
import MapKit
import CoreLocation
import FirebaseAuth

struct DashboardView: View {
    @Binding var isAuthenticated: Bool
    @StateObject private var reporteViewModel = ReporteViewModel()
    @State private var showCrearReporte: Bool = false
    @State private var showBuscarReportes: Bool = false
    @State private var showCerrarSesion: Bool = false
    @State private var selectedCoordinate: CLLocationCoordinate2D
    @State private var selectedDistrito: String = "Lima"
    @State private var selectedAddress: String = ""
    @State private var mapPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -12.0264, longitude: -77.0444),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    @State private var mapProxy: MapProxy?
    @State private var pinOffset: CGSize = .zero
    @State private var isDraggingPin: Bool = false

    init(isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
        self._selectedCoordinate = State(initialValue: CLLocationCoordinate2D(latitude: -12.0264, longitude: -77.0444))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MapReader { proxy in
                    Map(position: $mapPosition) {
                        ForEach(reporteViewModel.reportes) { reporte in
                            Annotation("", coordinate: reporte.coordenada) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .onAppear {
                        self.mapProxy = proxy
                    }
                }
                
                VStack {
                    HStack {
                        Button {
                            showCerrarSesion = true
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color(hex: "2D2D44").opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .padding(.leading, 16)
                        .padding(.top, 60)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                
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
                                if let proxy = mapProxy {
                                    let centerPoint = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                    if let coordinate = proxy.convert(centerPoint, from: .local) {
                                        selectedCoordinate = coordinate
                                    }
                                }
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
                
                pinButton(geometry: geometry)
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
            )
        }
        .sheet(isPresented: $showCerrarSesion) {
            ZStack {
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("¿Cerrar sesión?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Text("Se cerrará tu sesión actual.")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 16) {
                        Button {
                            showCerrarSesion = false
                        } label: {
                            Text("Cancelar")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "2D2D44"))
                                .cornerRadius(12)
                        }
                        
                        Button {
                            do {
                                try Auth.auth().signOut()
                                showCerrarSesion = false
                                isAuthenticated = false
                            } catch {
                                print("Error al cerrar sesión: \(error.localizedDescription)")
                            }
                        } label: {
                            Text("Cerrar sesión")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(32)
            }
            .presentationDetents([.height(280)])
        }
        .onAppear {
            Task {
                await reporteViewModel.obtenerReportes()
            }
        }
    }
    
    private func pinButton(geometry: GeometryProxy) -> some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.red, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            
            Image(systemName: "location.fill")
                .font(.system(size: 18))
                .foregroundStyle(.red)
        }
        .offset(pinOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDraggingPin = true
                    pinOffset = value.translation
                }
                .onEnded { value in
                    isDraggingPin = false
                    
                    let baseX: CGFloat = 32
                    let baseY = geometry.size.height - 80
                    let dropPoint = CGPoint(x: baseX + pinOffset.width, y: baseY + pinOffset.height)
                    
                    if let proxy = mapProxy,
                       let coordinate = proxy.convert(dropPoint, from: .local) {
                        selectedCoordinate = coordinate
                        showCrearReporte = true
                    }
                    
                    withAnimation(.spring(response: 0.3)) {
                        pinOffset = .zero
                    }
                }
        )
        .position(
            x: 32,
            y: geometry.size.height - 80
        )
        .opacity(isDraggingPin ? 1.0 : 0.6)
        .scaleEffect(isDraggingPin ? 1.15 : 1.0)
        .animation(.spring(response: 0.3), value: isDraggingPin)
    }
}

#Preview {
    DashboardView(isAuthenticated: .constant(true))
}