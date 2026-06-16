//
//  ObserveRemoteConfigUseCase.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Foundation

protocol ObserveRemoteConfigUseCase {
    func execute() -> AsyncStream<RemoteConfigModel>
}

final class DefaultObserveRemoteConfigUseCase: ObserveRemoteConfigUseCase {
    private let repository: RemoteConfigRepositoryProtocol

    init(repository: RemoteConfigRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AsyncStream<RemoteConfigModel> {
        repository.observeRemoteConfigUpdates()
    }
}
