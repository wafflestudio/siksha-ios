//
//  URLSessionOrderedImageDataLoader.swift
//  Siksha
//

import Foundation

protocol ImageDataTransporting: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: ImageDataTransporting {}

struct URLSessionOrderedImageDataLoader: OrderedImageDataLoading {
    private let transport: ImageDataTransporting

    init(transport: ImageDataTransporting = URLSession.shared) {
        self.transport = transport
    }

    func loadImageData(from urls: [URL]) async throws -> [Data] {
        try await withThrowingTaskGroup(of: (Int, Data).self) { group in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    let (data, response) = try await transport.data(from: url)
                    try Task.checkCancellation()

                    guard let response = response as? HTTPURLResponse,
                        (200..<300).contains(response.statusCode)
                    else {
                        throw OrderedImageDataLoadingError.invalidResponse
                    }

                    return (index, data)
                }
            }

            var loadedData = [Data?](repeating: nil, count: urls.count)
            for try await (index, data) in group {
                loadedData[index] = data
            }

            guard loadedData.allSatisfy({ $0 != nil }) else {
                throw OrderedImageDataLoadingError.invalidResponse
            }
            return try loadedData.map { data in
                guard let data else {
                    throw OrderedImageDataLoadingError.invalidResponse
                }
                return data
            }
        }
    }
}
