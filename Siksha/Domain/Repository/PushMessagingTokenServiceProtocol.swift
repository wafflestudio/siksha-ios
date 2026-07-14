//
//  PushMessagingTokenServiceProtocol.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

import Foundation

protocol PushMessagingTokenServiceProtocol {
    func setAPNSToken(_ token: Data)
    func fetchToken() async throws -> String
    func deleteToken() async throws
}
