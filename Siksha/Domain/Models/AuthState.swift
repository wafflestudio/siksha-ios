//
//  AuthState.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

enum AuthState: Sendable {
    case authenticated(AuthSession)
    case requiresLogin
}
