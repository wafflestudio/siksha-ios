//
//  AppVersion.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

struct AppVersion: Comparable, Sendable {
    let rawValue: String

    private let major: Int
    private let minor: Int
    private let patch: Int

    init?(rawValue: String) {
        let components = rawValue.split(separator: ".", omittingEmptySubsequences: false)
        guard components.count == 3,
            components.allSatisfy({ component in
                !component.isEmpty && component.allSatisfy { $0.isNumber }
            }),
            let major = Int(components[0]),
            let minor = Int(components[1]),
            let patch = Int(components[2]),
            major >= 0,
            minor >= 0,
            patch >= 0
        else {
            return nil
        }

        self.rawValue = rawValue
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        return lhs.patch < rhs.patch
    }

    static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}
