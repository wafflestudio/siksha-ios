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
    private let LAT_ERROR = 0.002129
    private let LNG_ERROR = -0.004098
    //임시 픽스. 나중에 고칠 것
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
        let cameraFixCoordinate = NMGLatLng(lat: coordinate.lat + LAT_ERROR, lng: coordinate.lng + LNG_ERROR)
        let cameraUpdate = NMFCameraUpdate(position: NMFCameraPosition(cameraFixCoordinate, zoom: 15))
        view.moveCamera(cameraUpdate)
        
        let marker = NMFMarker(position: coordinate,iconImage: NMFOverlayImage(image: getMarkerImage()))
        marker.mapView = view
    }
    @MainActor func getMarkerImage() -> UIImage{
        let renderer = ImageRenderer(content:MapMarker(name: markerText)                .environment(\.colorScheme,colorScheme)
)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage!
    }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(coordinate: NMGLatLng(lat: 37.5670135, lng: 126.9783740), markerText: "HIHI")
    }
}
