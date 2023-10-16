//
//  FeatureFlag.swift
//  Siksha
//
//  Created by 한상현 on 2023/10/16.
//

final class FeatureFlag {
    static let shared = FeatureFlag()
    
    private var flagDict: [Feature: Bool]
    
    init() {
        self.flagDict = Feature.allCases.reduce(into: [Feature: Bool]()) { flags, feature in
            flags[feature] = false
        }
    }
    
    enum Feature: String, CaseIterable {
        case community
    }
    
    func enable(feature: Feature) {
        self.flagDict[feature] = true
    }
    
    func isEnabled(feature: Feature) -> Bool {
        return self.flagDict[feature] ?? false
    }
}
