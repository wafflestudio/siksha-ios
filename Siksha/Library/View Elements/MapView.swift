//
//  MapView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/03/10.
//

import SwiftUI
import NMapsMap

struct MapView: UIViewRepresentable {
    private let coordinate: NMGLatLng

    init(coordinate: NMGLatLng) {
        self.coordinate = coordinate
    }
    
    func makeUIView(context: Context) -> NMFMapView {
        NMFMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 250))
    }
    
    func updateUIView(_ view: NMFMapView, context: Context) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: coordinate)
        view.moveCamera(cameraUpdate)
        let marker = NMFMarker(position: coordinate)
        marker.mapView = view        
    }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(coordinate: NMGLatLng(lat: 37.5670135, lng: 126.9783740))
    }
}
