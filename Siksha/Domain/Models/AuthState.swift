//
//  AuthState.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

enum AuthState {
    case authenticated(AuthSession)
    case requiresLogin
}
