//
//  AppVersionRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

protocol AppVersionRepositoryProtocol {
    func fetchLatestAppStoreVersion() async throws -> AppVersion
}
