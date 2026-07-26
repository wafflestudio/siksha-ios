//
//  DeviceTokenOperationGate.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

import Foundation

final class DeviceTokenOperationGate: Sendable {
    private let state = State()

    func withExclusiveAccess<T>(
        _ operation: () async throws -> T
    ) async throws -> T {
        let waiterID = UUID()
        let state = state

        try await withTaskCancellationHandler {
            try await state.acquire(id: waiterID)
        } onCancel: {
            Task {
                await state.cancelWaiter(id: waiterID)
            }
        }

        do {
            try Task.checkCancellation()
        } catch {
            await state.release()
            throw error
        }

        do {
            let result = try await operation()
            await state.release()
            return result
        } catch {
            await state.release()
            throw error
        }
    }
}

private extension DeviceTokenOperationGate {
    actor State {
        private struct Waiter {
            let id: UUID
            let continuation: CheckedContinuation<Void, Error>
        }

        private var isLocked = false
        private var waiters: [Waiter] = []

        func acquire(id: UUID) async throws {
            try Task.checkCancellation()

            guard isLocked else {
                isLocked = true
                return
            }

            try await withCheckedThrowingContinuation { continuation in
                waiters.append(Waiter(id: id, continuation: continuation))
            }
        }

        func cancelWaiter(id: UUID) {
            guard let index = waiters.firstIndex(where: { $0.id == id }) else {
                return
            }

            let waiter = waiters.remove(at: index)
            waiter.continuation.resume(throwing: CancellationError())
        }

        func release() {
            guard !waiters.isEmpty else {
                isLocked = false
                return
            }

            waiters.removeFirst().continuation.resume()
        }
    }
}
