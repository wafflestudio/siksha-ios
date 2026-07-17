//
//  FestivalRemoteDataSource.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Alamofire
import Foundation

protocol FestivalRemoteDataSource {
    func fetchFestivalDates() async throws -> FestivalDatesResponseDTO
}

final class FestivalRemoteDataSourceImpl: FestivalRemoteDataSource {
    func fetchFestivalDates() async throws -> FestivalDatesResponseDTO {
        try await AF
            .request(SikshaAPI.getFestivalDates)
            .validate()
            .serializingDecodable(FestivalDatesResponseDTO.self, decoder: NetworkDecoder.make())
            .value
    }
}
