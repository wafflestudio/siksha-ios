//
//  RemoteImage.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/31.
//

import SwiftUI
import Combine

struct RemoteImage: View {
    private class ImageLoader: ObservableObject {
        private static let imageProcessingQueue = DispatchQueue.global(qos: .userInteractive)
        
        @Published var image: UIImage?
        private let url: URL?
        private var cache: ImageCache?
        private var cancellable: AnyCancellable?
        
        private var isLoading = false
        
        init(url: String, cache: ImageCache? = nil) {
            self.url = URL(string: url)
            self.cache = cache
        }
        
        deinit {
            cancel()
        }
        
        func load() {
            guard !isLoading else { return }
            guard let url = url else { return }
            
            if let image = cache?[url] {
                self.image = image
                return
            }
            
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .subscribe(on: Self.imageProcessingQueue)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .handleEvents(receiveOutput: { [weak self] in self?.cache($0) })
                .receive(on: RunLoop.main)
                .assign(to: \.image, on: self)
        }
        
        func cancel() {
            cancellable?.cancel()
        }
        
        private func cache(_ image: UIImage?) {
            guard let url = url else { return }
            image.map { cache?[url] = $0 }
        }
    }
    
    @ObservedObject private var imageLoader: ImageLoader
    
    init(url: String) {
        _imageLoader = ObservedObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }
    
    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFill()
            } else {
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
            }
        }
        .onAppear {
            imageLoader.load()
        }
    }
}

//struct RemoteImage_Previews: PreviewProvider {
//    static var previews: some View {
//        RemoteImage()
//    }
//}
