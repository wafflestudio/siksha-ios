//
//  BlockManager.swift
//  Siksha
//

import Foundation

final class BlockManager {
    static let shared = BlockManager()

    private let nicknamesKey = "blockedNicknames"
    private let postIdsKey = "blockedPostIds"
    private let commentIdsKey = "blockedCommentIds"

    private init() {}

    // MARK: - Nickname-based blocking (non-anonymous users)

    func blockNickname(_ nickname: String) {
        var current = Set(UserDefaults.standard.stringArray(forKey: nicknamesKey) ?? [])
        current.insert(nickname)
        UserDefaults.standard.set(Array(current), forKey: nicknamesKey)
    }

    func blockedNicknames() -> Set<String> {
        return Set(UserDefaults.standard.stringArray(forKey: nicknamesKey) ?? [])
    }

    // MARK: - Post ID-based blocking (anonymous posts)

    func blockPost(id: Int) {
        var current = blockedPostIds()
        current.insert(id)
        UserDefaults.standard.set(Array(current), forKey: postIdsKey)
    }

    func blockedPostIds() -> Set<Int> {
        return Set((UserDefaults.standard.array(forKey: postIdsKey) as? [Int]) ?? [])
    }

    // MARK: - Comment ID-based blocking (anonymous comments)

    func blockComment(id: Int) {
        var current = blockedCommentIds()
        current.insert(id)
        UserDefaults.standard.set(Array(current), forKey: commentIdsKey)
    }

    func blockedCommentIds() -> Set<Int> {
        return Set((UserDefaults.standard.array(forKey: commentIdsKey) as? [Int]) ?? [])
    }
}
