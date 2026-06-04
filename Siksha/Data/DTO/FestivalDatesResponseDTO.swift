//
//  FestivalDatesResponseDTO.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Foundation

struct FestivalDatesResponseDTO: Decodable {
    let festivalDates: [String]
}

extension FestivalDatesResponseDTO {
    func toDomain() -> [Date] {
        festivalDates.compactMap(Self.dateFormatter.date(from:))
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
