//
//  MenuPreferenceRemoteDataSource.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

import Alamofire
import Foundation

protocol MenuPreferenceRemoteDataSource {
    func likeMenu(menuId: Int) async throws -> MenuLikeStatusDTO
    func unlikeMenu(menuId: Int) async throws -> MenuLikeStatusDTO
}

final class MenuPreferenceRemoteDataSourceImpl: MenuPreferenceRemoteDataSource {
    func likeMenu(menuId: Int) async throws -> MenuLikeStatusDTO {
        try await AF
            .request(SikshaAPI.likeMenu(menuId: menuId))
            .validate()
            .serializingDecodable(MenuLikeStatusDTO.self, decoder: JSONDecoder())
            .value
    }

    func unlikeMenu(menuId: Int) async throws -> MenuLikeStatusDTO {
        try await AF
            .request(SikshaAPI.unlikeMenu(menuId: menuId))
            .validate()
            .serializingDecodable(MenuLikeStatusDTO.self, decoder: JSONDecoder())
            .value
    }
}
