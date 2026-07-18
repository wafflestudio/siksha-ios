//
//  RemoteConfigRepositoryImplTests.swift
//  SikshaTests
//
//  Created by Codex on 7/19/26.
//

import XCTest

@testable import Siksha

final class RemoteConfigRepositoryImplTests: XCTestCase {
    func testFetchMapsRemoteConfigDTO() async throws {
        let dataSource = RemoteConfigDataSourceStub(
            fetchResult: .success(
                RemoteConfigDTO(
                    festivalFeatureEnabled: true,
                    festivalAppIconEnabled: false
                )
            )
        )
        let repository = RemoteConfigRepositoryImpl(dataSource: dataSource)

        let config = try await repository.fetchRemoteConfig()

        XCTAssertTrue(config.festivalFeatureEnabled)
        XCTAssertFalse(config.festivalAppIconEnabled)
    }

    func testFetchPropagatesDataSourceError() async {
        let dataSource = RemoteConfigDataSourceStub(
            fetchResult: .failure(RemoteConfigTestError.fetch)
        )
        let repository = RemoteConfigRepositoryImpl(dataSource: dataSource)

        do {
            _ = try await repository.fetchRemoteConfig()
            XCTFail("Expected fetch failure")
        } catch let error as RemoteConfigTestError {
            XCTAssertEqual(error, .fetch)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testObserveMapsUpdatesInOrderAndPreservesDuplicates() async {
        let dataSource = RemoteConfigDataSourceStub()
        let repository = RemoteConfigRepositoryImpl(dataSource: dataSource)
        let updates = repository.observeRemoteConfigUpdates()
        let collector = Task {
            var values: [RemoteConfigModel] = []

            for await value in updates {
                values.append(value)
            }

            return values
        }

        await dataSource.waitForObservation()
        await dataSource.yield(
            RemoteConfigDTO(
                festivalFeatureEnabled: true,
                festivalAppIconEnabled: false
            )
        )
        await dataSource.yield(
            RemoteConfigDTO(
                festivalFeatureEnabled: true,
                festivalAppIconEnabled: false
            )
        )
        await dataSource.yield(
            RemoteConfigDTO(
                festivalFeatureEnabled: false,
                festivalAppIconEnabled: true
            )
        )
        await dataSource.finish()

        let values = await collector.value

        XCTAssertEqual(values.count, 3)
        XCTAssertTrue(values[0].festivalFeatureEnabled)
        XCTAssertFalse(values[0].festivalAppIconEnabled)
        XCTAssertTrue(values[1].festivalFeatureEnabled)
        XCTAssertFalse(values[1].festivalAppIconEnabled)
        XCTAssertFalse(values[2].festivalFeatureEnabled)
        XCTAssertTrue(values[2].festivalAppIconEnabled)
    }

    func testCancellingObservationTerminatesUpstreamStream() async {
        let dataSource = RemoteConfigDataSourceStub()
        let repository = RemoteConfigRepositoryImpl(dataSource: dataSource)
        let updates = repository.observeRemoteConfigUpdates()
        let collector = Task {
            for await _ in updates {}
        }

        await dataSource.waitForObservation()
        collector.cancel()
        await collector.value
        await dataSource.waitForTermination()

        let didTerminate = await dataSource.didTerminate
        XCTAssertTrue(didTerminate)
    }
}

private enum RemoteConfigTestError: Error, Equatable {
    case fetch
}

private actor RemoteConfigDataSourceStub: RemoteConfigDataSource {
    private let fetchResult: Result<RemoteConfigDTO, Error>
    private var continuation: AsyncStream<RemoteConfigDTO>.Continuation?
    private var observationWaiters: [CheckedContinuation<Void, Never>] = []
    private var terminationWaiters: [CheckedContinuation<Void, Never>] = []
    private(set) var didTerminate = false

    init(
        fetchResult: Result<RemoteConfigDTO, Error> = .success(
            RemoteConfigDTO(
                festivalFeatureEnabled: false,
                festivalAppIconEnabled: false
            )
        )
    ) {
        self.fetchResult = fetchResult
    }

    func fetchRemoteConfig() async throws -> RemoteConfigDTO {
        try fetchResult.get()
    }

    func observeRemoteConfigUpdates() async -> AsyncStream<RemoteConfigDTO> {
        let (stream, continuation) = AsyncStream<RemoteConfigDTO>.makeStream()
        self.continuation = continuation
        continuation.onTermination = { [weak self] _ in
            Task {
                await self?.recordTermination()
            }
        }

        let waiters = observationWaiters
        observationWaiters.removeAll()
        waiters.forEach { $0.resume() }
        return stream
    }

    func waitForObservation() async {
        guard continuation == nil else {
            return
        }

        await withCheckedContinuation { observationWaiters.append($0) }
    }

    func yield(_ value: RemoteConfigDTO) {
        continuation?.yield(value)
    }

    func finish() {
        continuation?.finish()
    }

    func waitForTermination() async {
        guard !didTerminate else {
            return
        }

        await withCheckedContinuation { terminationWaiters.append($0) }
    }

    private func recordTermination() {
        continuation = nil
        didTerminate = true

        let waiters = terminationWaiters
        terminationWaiters.removeAll()
        waiters.forEach { $0.resume() }
    }
}
