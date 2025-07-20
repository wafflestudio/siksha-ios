//
//  Mixpanel+Extensions.swift
//  Siksha
//
//  Created by 이지현 on 7/20/25.
//

import Foundation
import Mixpanel

extension Mixpanel {
    typealias propertyKey = MixpanelKey.PropertyKey
    
    static func trackFilterModalOpened(
        entryPoint: MixpanelKey.EntryPoint,
        pageName: MixpanelKey.PageName
    ) {
        Mixpanel
            .mainInstance()
            .track(
                event: MixpanelKey.Event.filterModalOpened,
                properties: [
                    propertyKey.entryPoint: entryPoint,
                    propertyKey.pageName:  pageName
                ]
            )
    }
    
    static func trackFilterToggled(
        filterType: MixpanelKey.FilterOption,
        filterValue: Bool,
        pageName: MixpanelKey.PageName
    ) {
        Mixpanel
            .mainInstance()
            .track(
                event: MixpanelKey.Event.filterToggled,
                properties: [
                    propertyKey.filterType: filterType,
                    propertyKey.filterValue: filterValue,
                    propertyKey.pageName: pageName
                ]
            )
    }
    
    static func trackFilterReset(
        entryPoint: MixpanelKey.EntryPoint,
        pageName: MixpanelKey.PageName
    ) {
        Mixpanel
            .mainInstance()
            .track(
                event: MixpanelKey.Event.filterReset,
                properties: [
                    propertyKey.entryPoint: entryPoint,
                    propertyKey.pageName:  pageName
                ]
            )
    }
    
    static func trackFilterModalApplied(
        entryPoint: MixpanelKey.EntryPoint,
        appliedFilterOptions: [String: Any],
        pageName: MixpanelKey.PageName
    ) {
        Mixpanel
            .mainInstance()
            .track(
                event: MixpanelKey.Event.filterModalApplied,
                properties: [
                    propertyKey.entryPoint: entryPoint,
                    propertyKey.appliedFilterOptions: appliedFilterOptions,
                    propertyKey.pageName: pageName
                ]
            )
    }
}
