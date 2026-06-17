//
//  RestaurantOperatingStatusPolicy.swift
//  Siksha
//
//  Created by Codex on 6/17/26.
//

import Foundation

struct RestaurantOperatingStatusPolicy {
    private let dayIndex: Int
    private let currentTimeString: String

    init(selectedDate: String, now: Date = Date()) {
        var koreanCalendar = Calendar(identifier: .gregorian)
        koreanCalendar.timeZone = TimeZone(identifier: "Asia/Seoul")!

        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.dateFormat = "yyyy-MM-dd"
        let selected = selectedDateFormatter.date(from: selectedDate) ?? Date()
        let weekday = koreanCalendar.component(.weekday, from: selected)

        if weekday == 7 {
            dayIndex = 1
        } else if weekday == 1 {
            dayIndex = 2
        } else {
            dayIndex = 0
        }

        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        timeFormatter.dateFormat = "HH:mm"
        currentTimeString = timeFormatter.string(from: now)
    }

    func isOpen(_ restaurant: RestaurantModel) -> Bool {
        guard restaurant.operatingHours.count > dayIndex else { return false }
        let hoursString = restaurant.operatingHours[dayIndex]
        guard !hoursString.isEmpty else { return false }

        let intervals = hoursString.components(separatedBy: "\n")

        for interval in intervals {
            let times = interval.components(separatedBy: " - ")
            guard times.count == 2 else {
                continue
            }

            let startTime = times[0]
            let endTime = times[1]

            if currentTimeString >= startTime && currentTimeString <= endTime {
                return true
            }

            if startTime > endTime && currentTimeString <= endTime {
                return true
            }
        }
        return false
    }
}
