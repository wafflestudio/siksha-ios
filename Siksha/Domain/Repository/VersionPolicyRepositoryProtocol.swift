//
//  VersionPolicyRepositoryProtocol.swift
//  Siksha
//

protocol VersionPolicyRepositoryProtocol {
    func fetchMinimumSupportedVersion() async throws -> AppVersion
}
