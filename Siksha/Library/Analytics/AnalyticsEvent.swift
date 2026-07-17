//
//  AnalyticsEvent.swift
//  Siksha
//
//  Created by Jihyeon on 8/17/25.
//

import Mixpanel

enum AnalyticsEvent {
    case filterModalOpened(entryPoint: String, pageName: String)
    case filterModalApplied(entryPoint: String, applied: [String: Any], pageName: String)
    case filterReset(entryPoint: String, pageName: String)
    case instantFilterToggled(filter: FilterType, value: Bool, pageName: String)

    var name: String {
        switch self {
        case .filterModalOpened: return "filter_modal_opened"
        case .filterModalApplied: return "filter_modal_applied"
        case .filterReset: return "filter_reset"
        case .instantFilterToggled: return "instant_filter_toggled"
        }
    }

    var properties: Properties {
        switch self {
        case let .filterModalOpened(entryPoint, pageName):
            return [
                AnalyticsKey.entryPoint: entryPoint,
                AnalyticsKey.pageName: pageName,
            ]

        case let .filterModalApplied(entryPoint, applied, pageName):
            return [
                AnalyticsKey.entryPoint: entryPoint,
                AnalyticsKey.appliedFilterOptions: applied,
                AnalyticsKey.pageName: pageName,
            ]

        case let .filterReset(entryPoint, pageName):
            return [
                AnalyticsKey.entryPoint: entryPoint,
                AnalyticsKey.pageName: pageName,
            ]

        case let .instantFilterToggled(filter, value, pageName):
            return [
                AnalyticsKey.filterType: filter.rawValue,
                AnalyticsKey.filterValue: value,
                AnalyticsKey.pageName: pageName,
            ]
        }
    }
}
