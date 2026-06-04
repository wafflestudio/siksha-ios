//
//  RemoteConfigRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Foundation

protocol RemoteConfigRepositoryProtocol {
    func fetchRemoteConfig() async throws -> RemoteConfigModel
}
