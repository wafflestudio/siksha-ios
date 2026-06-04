//
//  FestivalRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Foundation

protocol FestivalRepositoryProtocol {
    func fetchFestivalDates() async throws -> [Date]
}
