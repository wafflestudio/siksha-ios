//
//  FestivalRemoteDataSource.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Foundation
import Alamofire

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
