//
//  Enums.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import Foundation
import SwiftUI

enum TypeSelection: Int {
    case breakfast = 0
    case lunch = 1
    case dinner = 2
}

struct TypeInfo: Identifiable {
    var id: Int
    var type: TypeSelection
    var icon: String
    var height: CGFloat
    var width: CGFloat
    var name: String
    
    init(type: TypeSelection) {
        self.id = type.rawValue
        self.type = type

        switch(type){
        case .breakfast:
            self.icon = "Breakfast"
            self.width = 20
            self.height = 12
            self.name = "아침"
        case .lunch:
            self.icon = "Lunch"
            self.width = 20
            self.height = 20
            self.name = "점심"
        case .dinner:
            self.icon = "Dinner"
            self.width = 14
            self.height = 14
            self.name = "저녁"
        }
    }
}

enum NetworkStatus {
    case loading
    case failed
    case succeeded
    case idle
}

enum ReviewErrorCode: Int {
    case noNetwork = 1
    case authenticationFailed = 422
    case multipleReview = 403
    case invalidId = 404
    
    var message: String {
        switch self {
        case .noNetwork:
            return "네트워크 연결이 불안정합니다."
        case .authenticationFailed:
            return "인증 오류입니다. 다시 로그인 해주세요."
        case .multipleReview:
            return "한 메뉴에 여러 번 평가할 수 없습니다."
        case .invalidId:
            return "유효하지 않은 메뉴 아이디입니다. 다시 시도해주세요."
        }
    }
}
