//
//  LoginCredential.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

struct LoginCredential {
    let provider: LoginProvider
    let token: String
    let appleUserIdentifier: String?

    init(
        provider: LoginProvider,
        token: String,
        appleUserIdentifier: String? = nil
    ) {
        self.provider = provider
        self.token = token
        self.appleUserIdentifier = appleUserIdentifier
    }
}
