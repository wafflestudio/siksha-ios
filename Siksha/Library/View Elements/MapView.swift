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
    private let markerText: String

    init(coordinate: NMGLatLng, markerText: String) {
        self.coordinate = coordinate
        self.markerText = markerText
    }
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-32, height: 250))
        mapView.allowsTilting = false
        
        return mapView
    }
    
    func updateUIView(_ view: NMFMapView, context: Context) {
        let cameraUpdate = NMFCameraUpdate(position: NMFCameraPosition(coordinate, zoom: 15))
        view.moveCamera(cameraUpdate)
        let marker = NMFMarker(position: coordinate, iconImage: .init(name: "mapMarker"))
        marker.captionText = markerText
        marker.captionColor = UIColor(named: "DefaultFontColor") ?? .black
        marker.captionAligns = [.top]
        marker.captionOffset = -18
        marker.mapView = view
    }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(coordinate: NMGLatLng(lat: 37.5670135, lng: 126.9783740), markerText: "HIHI")
    }
}
