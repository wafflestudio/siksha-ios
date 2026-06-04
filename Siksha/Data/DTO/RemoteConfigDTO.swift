//
//  RemoteConfigDTO.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Foundation

struct RemoteConfigDTO {
    let festivalFeatureEnabled: Bool
    let festivalAppIconEnabled: Bool
}

extension RemoteConfigDTO {
    func toDomain() -> RemoteConfigModel {
        RemoteConfigModel(
            festivalFeatureEnabled: festivalFeatureEnabled,
            festivalAppIconEnabled: festivalAppIconEnabled
        )
    }
}
