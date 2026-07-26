//
//  OrderedImageDataLoading.swift
//  Siksha
//

import Foundation

protocol OrderedImageDataLoading: Sendable {
    func loadImageData(from urls: [URL]) async throws -> [Data]
}

enum OrderedImageDataLoadingError: Error {
    case invalidResponse
}
