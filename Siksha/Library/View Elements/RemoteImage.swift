//
//  RemoteImage.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/31.
//

import SwiftUI

struct RemoteImage: View {
    
    private enum LoadState {
        case loading, success, failure
    }
    
    private class ImageLoader: ObservableObject {
        var data = Data()
        var state = LoadState.loading
        
        init(url: String) {
            guard let parsedURL = URL(string: url) else { fatalError("Invalid URL: \(url)") }
            
            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    self.state = .failure
                }
                
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
            .resume()
        }
    }
    
    @ObservedObject private var imageLoader: ImageLoader
    var loading: Image
    var failure: Image
    
    init(url: String, loading: Image = Image(systemName: ""), failure: Image = Image(systemName: "")) {
        _imageLoader = ObservedObject(wrappedValue: ImageLoader(url: url))
        self.loading = loading
        self.failure = failure
    }
    
    private func selectImage() -> Image {
        switch imageLoader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            if let image = UIImage(data: imageLoader.data) {
                return Image(uiImage: image)
            } else {
                return failure
            }
        }
    }
    
    var body: some View {
        selectImage()
            .resizable()
    }
}

//struct RemoteImage_Previews: PreviewProvider {
//    static var previews: some View {
//        RemoteImage()
//    }
//}
