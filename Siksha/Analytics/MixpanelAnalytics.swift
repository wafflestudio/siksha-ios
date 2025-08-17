//
//  MixpanelAnalytics.swift
//  Siksha
//
//  Created by Jihyeon on 8/17/25.
//

import Mixpanel

protocol AnalyticsService {
    func track(_ event: AnalyticsEvent)
}

final class MixpanelAnalytics: AnalyticsService {
    func track(_ event: AnalyticsEvent) {
        Mixpanel.mainInstance().track(event: event.name, properties: event.properties)
    }
}
