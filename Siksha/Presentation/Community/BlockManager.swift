//
//  BlockManager.swift
//  Siksha
//

import Foundation

@MainActor
final class BlockManager {
    private let nicknamesKey = "blockedNicknames"
    private let postIdsKey = "blockedPostIds"
    private let commentIdsKey = "blockedCommentIds"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Nickname-based blocking (non-anonymous users)

    func blockNickname(_ nickname: String) {
        var current = Set(userDefaults.stringArray(forKey: nicknamesKey) ?? [])
        current.insert(nickname)
        userDefaults.set(Array(current), forKey: nicknamesKey)
    }

    func blockedNicknames() -> Set<String> {
        return Set(userDefaults.stringArray(forKey: nicknamesKey) ?? [])
    }

    // MARK: - Post ID-based blocking (anonymous posts)

    func blockPost(id: Int) {
        var current = blockedPostIds()
        current.insert(id)
        userDefaults.set(Array(current), forKey: postIdsKey)
    }

    func blockedPostIds() -> Set<Int> {
        return Set((userDefaults.array(forKey: postIdsKey) as? [Int]) ?? [])
    }

    // MARK: - Comment ID-based blocking (anonymous comments)

    func blockComment(id: Int) {
        var current = blockedCommentIds()
        current.insert(id)
        userDefaults.set(Array(current), forKey: commentIdsKey)
    }

    func blockedCommentIds() -> Set<Int> {
        return Set((userDefaults.array(forKey: commentIdsKey) as? [Int]) ?? [])
    }
}
