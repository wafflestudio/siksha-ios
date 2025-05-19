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

enum MenuStatus {
    case loading
    case failed
    case showCached
    case succeeded
    case idle
    case needRerender // use when the user removes restaurants from favorite view
}

enum InitialPostsStatus {
    case loading
    case idle
}

enum NetworkStatus {
    case loading
    case failed
    case succeeded
    case idle
}

enum ReviewErrorCode: Int {
    case noNetwork = 0
    case authenticationFailed = 422
    case signatureVerifyFailed = 401
    case multipleReview = 403
    case invalidId = 404
    
    var message: String {
        switch self {
        case .noNetwork:
            return "네트워크 연결이 불안정합니다."
        case .authenticationFailed:
            return "인증 오류입니다. 다시 로그인 해주세요."
        case .signatureVerifyFailed:
            return "로그인 상태가 만료되었습니다. 다시 로그인 해주세요."
        case .multipleReview:
            return "한 메뉴에 여러 번 평가할 수 없습니다."
        case .invalidId:
            return "유효하지 않은 메뉴 아이디입니다. 다시 시도해주세요."
        }
    }
}
enum FontType{
    enum FontWeight: String{
        case Light = "NanumSquareOTFL"
        case Regular = "NanumSquareOTFR"
        case Bold = "NanumSquareOTFB"
        case ExtraBold = "NanumSquareOTFEB"
    }
    case text11(weight:FontWeight)
    case text12(weight:FontWeight)
    case text13(weight:FontWeight)
    case text14(weight:FontWeight)
    case text15(weight:FontWeight)
    case text16(weight:FontWeight)
    case text18(weight:FontWeight)
    case text20(weight:FontWeight)
    case text24(weight:FontWeight)
    case text28(weight:FontWeight)
    case text32(weight:FontWeight)
    var fontSize:Int{
        switch self{
        case .text11:
            return 11
        case .text12:
            return 12
        case .text13:
            return 13
        case .text14:
            return 14
        case .text15:
            return 15
        case .text16:
            return 16
        case .text18:
            return 18
        case .text20:
            return 20
        case .text24:
            return 24
        case .text28:
            return 28
        case .text32:
            return 32
        }
    }
    var lineHeight:Int{
        switch self{
        case .text14:
            return 150
        case .text15:
            return 150
        default:
            return 140
        }
    }
    var fontName:String{
        switch self{
        case .text11(let weight):
            return weight.rawValue
        case .text12(let weight):
            return weight.rawValue
        case .text13(let weight):
            return weight.rawValue
        case .text14(let weight):
            return weight.rawValue
        case .text15(let weight):
            return weight.rawValue
        case .text16(let weight):
            return weight.rawValue
        case .text18(let weight):
            return weight.rawValue
        case .text20(let weight):
            return weight.rawValue
        case .text24(let weight):
            return weight.rawValue
        case .text28(let weight):
            return weight.rawValue
        case .text32(let weight):
            return weight.rawValue
        }
    }
}
