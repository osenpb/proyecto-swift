//
//  MapView.swift
//  proyecto_alertas
//
//  Created by XCODE on 29/03/26.
//

import SwiftUI
import MapKit


struct MapView: View {
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        let reportes = [
            Reporte(coordenada: CLLocationCoordinate2D(latitude: -12.05, longitude: -77.03))
        ]
        
        var body: some View {
            Map(coordinateRegion: $region, annotationItems: reportes) { reporte in
                MapMarker(coordinate: reporte.coordenada, tint: .red)
            }
            .ignoresSafeArea()
        }
}
