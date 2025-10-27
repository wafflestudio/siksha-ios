//
//  MapView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/03/10.
//

import SwiftUI
import NMapsMap

struct MapView: UIViewRepresentable {
    @Environment(\.colorScheme) private var colorScheme
    private let coordinate: NMGLatLng
    private let markerText: String

    //임시 픽스. 나중에 고칠 것
    init(coordinate: NMGLatLng, markerText: String) {
        self.coordinate = coordinate
        self.markerText = markerText
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let nMapView: NMFNaverMapView = NMFNaverMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-32, height: 250))
        nMapView.mapView.allowsTilting = true
        nMapView.showZoomControls = false
        nMapView.showScaleBar = false
        nMapView.showCompass = false
        
        return nMapView
    }
    
    func updateUIView(_ view: NMFNaverMapView, context: Context) {
        let cameraFixCoordinate = NMGLatLng(lat: coordinate.lat, lng: coordinate.lng)
        let cameraUpdate = NMFCameraUpdate(position: NMFCameraPosition(cameraFixCoordinate, zoom: 15))
        
        view.mapView.moveCamera(cameraUpdate)
        
        let marker = NMFMarker(position: coordinate, iconImage: .init(name: "mapMarker"))
        marker.captionText = markerText
        marker.captionColor = UIColor(named: "DefaultFontColor") ?? .black
        marker.captionAligns = [.top]
        marker.captionOffset = -18
        marker.position = cameraFixCoordinate
        marker.mapView = view.mapView
    }

}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(coordinate: NMGLatLng(lat: 37.5670135, lng: 126.9783740), markerText: "HIHI")
    }
}
