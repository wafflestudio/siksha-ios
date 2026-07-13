//
//  RemoteImage.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/31.
//

import SwiftUI

protocol RemoteImageDataLoading {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: RemoteImageDataLoading {}

@MainActor
final class RemoteImageLoader: ObservableObject {
    enum Phase {
        case idle
        case loading
        case success(UIImage)
        case failed
    }

    @Published private(set) var phase: Phase = .idle

    private let dataLoader: RemoteImageDataLoading
    private var representedURL: URL?

    init(dataLoader: RemoteImageDataLoading = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    func load(url urlString: String, cache: ImageCache) async {
        guard let url = URL(string: urlString) else {
            representedURL = nil
            phase = .failed
            return
        }

        representedURL = url

        if let cachedImage = cache[url] {
            phase = .success(cachedImage)
            return
        }

        phase = .loading

        do {
            let (data, response) = try await dataLoader.data(from: url)
            try Task.checkCancellation()
            guard representedURL == url else { return }

            if let response = response as? HTTPURLResponse,
               !(200..<300).contains(response.statusCode) {
                phase = .failed
                return
            }

            guard let image = UIImage(data: data) else {
                phase = .failed
                return
            }

            cache[url] = image
            phase = .success(image)
        } catch is CancellationError {
            return
        } catch {
            guard representedURL == url else { return }
            phase = .failed
        }
    }
}

struct RemoteImage: View {
    private struct RequestID: Hashable {
        let url: String
        let cacheIdentifier: ObjectIdentifier
    }

    @Environment(\.imageCache) private var imageCache
    @StateObject private var imageLoader = RemoteImageLoader()

    private let url: String

    init(url: String) {
        self.url = url
    }

    var body: some View {
        Group {
            switch imageLoader.phase {
            case .idle, .loading:
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFill()
            case .failed:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .task(id: requestID) {
            await imageLoader.load(url: url, cache: imageCache)
        }
    }

    private var requestID: RequestID {
        RequestID(
            url: url,
            cacheIdentifier: ObjectIdentifier(imageCache)
        )
    }
}
