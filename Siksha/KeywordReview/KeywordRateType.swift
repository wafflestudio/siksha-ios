//
//  KeywordRateType.swift
//  Siksha
//
//  Created by Jihyeon on 10/7/25.
//

import Foundation

enum KeywordRateType {
    case taste
    case price
    case yang
    
    var imageString: String {
        switch self {
        case .taste:
            return "KeywordTaste"
        case .price:
            return "KeywordMoney"
        case .yang:
            return "KeywordYang"
        }
    }
    
    var description: String {
        switch self {
        case .taste:
            return "또 먹고 싶어요"
        case .price:
            return "가성비 좋아요"
        case .yang:
            return "알찬 편이에요"
        }
    }
    
    var tempCnt: Int {
        switch self {
        case .taste:
            22
        case .price:
            10
        case .yang:
            17
        }
    }
    
    var title: String {
        switch self {
        case .taste:
            return "맛"
        case .price:
            return "가격"
        case .yang:
            return "음식 구성"
        }
    }
    
    var selects: [String] {
        switch self {
        case .taste:
            ["또 먹고 싶어요", "생각보다 맛있어요", "무난해요", "아쉬운 맛이에요", "별로에요"]
        case .price:
            ["혜자스러워요", "가성비 좋아요", "합리적이에요", "약간 비싸요", "너무 비싸요"]
        case .yang:
            ["조화로워요", "알찬 편이에요", "기본적이에요", "다소 단조로워요", "너무 빈약해요"]
        }
    }
}
