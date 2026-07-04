//
//  AuthRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

protocol AuthRepositoryProtocol {
    func login(with credential: LoginCredential) async throws -> AuthSession
    func loginForTest() async throws -> AuthSession
    func refreshAccessToken(_ accessToken: String) async throws -> AuthSession
    func loadSession() -> AuthSession?
    func saveSession(_ session: AuthSession)
    func clearSession()
}
