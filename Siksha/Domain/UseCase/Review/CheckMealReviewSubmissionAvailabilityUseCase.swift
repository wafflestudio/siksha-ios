//
//  CheckMealReviewSubmissionAvailabilityUseCase.swift
//  Siksha
//
//  Created by Codex on 7/1/26.
//

import Foundation

protocol CheckMealReviewSubmissionAvailabilityUseCase {
    func execute(
        selectedDate: Date,
        currentDate: Date
    ) -> Bool
}

final class DefaultCheckMealReviewSubmissionAvailabilityUseCase: CheckMealReviewSubmissionAvailabilityUseCase {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func execute(
        selectedDate: Date,
        currentDate: Date
    ) -> Bool {
        calendar.isDate(selectedDate, inSameDayAs: currentDate)
    }
}
