//
//  MenuRemoteDataSource.swift
//  Siksha
//
//  Created by Jihyeon on 2/23/26.
//

import Foundation
import Alamofire

protocol MenuRemoteDataSource {
    func fetchDailyMenus(from start: String, to end: String) async throws -> DailyMenusResponseDTO
}

final class MenuRemoteDataSourceImpl: MenuRemoteDataSource {
    // string format example: "2026-02-23"
    func fetchDailyMenus(from start: String, to end: String) async throws -> DailyMenusResponseDTO {
        try await AF
            .request(SikshaAPI.getMenus(startDate: start, endDate: end, noMenuHide: false))
            .serializingDecodable(DailyMenusResponseDTO.self, decoder: NetworkDecoder.make())
            .value
    }
}
