//
//  CheckFestivalSwitchVisibilityUseCase.swift
//  Siksha
//
//  Created by Codex on 7/1/26.
//

import Foundation

protocol CheckFestivalSwitchVisibilityUseCase {
    func execute(
        selectedDate: Date,
        festivalDates: [Date],
        isFeatureAvailable: Bool
    ) -> Bool
}

final class DefaultCheckFestivalSwitchVisibilityUseCase: CheckFestivalSwitchVisibilityUseCase {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func execute(
        selectedDate: Date,
        festivalDates: [Date],
        isFeatureAvailable: Bool
    ) -> Bool {
        guard isFeatureAvailable else {
            return false
        }

        return festivalDates.contains { festivalDate in
            calendar.isDate(festivalDate, inSameDayAs: selectedDate)
        }
    }
}
