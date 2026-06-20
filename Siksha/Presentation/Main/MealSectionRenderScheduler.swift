//
//  MealSectionRenderScheduler.swift
//  Siksha
//
//  Created by Codex on 6/21/26.
//

import Combine
import Foundation

enum MealSectionRenderTiming {
    case immediate
    case debounced
}

protocol MealSectionRenderScheduling: AnyObject {
    var mealSectionsPublisher: AnyPublisher<[MealSectionDisplayModel], Never> { get }

    func render(input: MealSectionDisplayModelBuilder.Input, timing: MealSectionRenderTiming)
    func clear()
}

final class MealSectionRenderScheduler: MealSectionRenderScheduling {
    private enum Request {
        case render(input: MealSectionDisplayModelBuilder.Input, timing: MealSectionRenderTiming)
        case clear
    }

    private let builder: MealSectionDisplayModelBuilder
    private let renderQueue: DispatchQueue
    private let debounceInterval: RunLoop.SchedulerTimeType.Stride
    private let requestSubject = PassthroughSubject<Request, Never>()

    lazy var mealSectionsPublisher: AnyPublisher<[MealSectionDisplayModel], Never> = {
        requestSubject
            .map { [weak self] request -> AnyPublisher<[MealSectionDisplayModel], Never> in
                self?.publisher(for: request) ?? Empty().eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }()

    init(
        builder: MealSectionDisplayModelBuilder = MealSectionDisplayModelBuilder(),
        renderQueue: DispatchQueue = DispatchQueue(
            label: "com.wafflestudio.siksha.menu.render",
            qos: .userInitiated
        ),
        debounceInterval: RunLoop.SchedulerTimeType.Stride = .milliseconds(100)
    ) {
        self.builder = builder
        self.renderQueue = renderQueue
        self.debounceInterval = debounceInterval
    }

    func render(input: MealSectionDisplayModelBuilder.Input, timing: MealSectionRenderTiming) {
        requestSubject.send(.render(input: input, timing: timing))
    }

    func clear() {
        requestSubject.send(.clear)
    }

    private func publisher(for request: Request) -> AnyPublisher<[MealSectionDisplayModel], Never> {
        switch request {
        case .clear:
            return Just([])
                .eraseToAnyPublisher()
        case .render(let input, .immediate):
            return buildPublisher(input: input)
        case .render(let input, .debounced):
            return Just(input)
                .delay(for: debounceInterval, scheduler: RunLoop.main)
                .receive(on: renderQueue)
                .map { [builder] input in builder.build(input: input) }
                .eraseToAnyPublisher()
        }
    }

    private func buildPublisher(
        input: MealSectionDisplayModelBuilder.Input
    ) -> AnyPublisher<[MealSectionDisplayModel], Never> {
        Just(input)
            .receive(on: renderQueue)
            .map { [builder] input in builder.build(input: input) }
            .eraseToAnyPublisher()
    }
}
