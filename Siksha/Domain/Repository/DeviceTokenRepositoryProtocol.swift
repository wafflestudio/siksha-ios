//
//  DeviceTokenRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

protocol DeviceTokenRepositoryProtocol {
    func registerDevice(fcmToken: String) async throws
    func unregisterDevice(fcmToken: String) async throws
    func loadDeviceToken() -> String?
    func saveDeviceToken(_ token: String)
    func isDeviceTokenRegistered() -> Bool
    func setDeviceTokenRegistered(_ isRegistered: Bool)
    func clearDeviceToken()
}
