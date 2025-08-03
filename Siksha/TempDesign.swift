//
//  TempDesign.swift
//  Siksha
//
//  Created by 이지현 on 8/1/25.
//

// TODO: 이 파일 지울 것!

//import Foundation
//import SwiftUI
//
//struct LineHeightModifier: ViewModifier {
//    let lineHeight: CGFloat
//    let font: UIFont
//    func body(content: Content) -> some View {
//        content
//            .font(Font(font))
//            .lineSpacing(lineHeight - font.lineHeight)
//            .padding(.vertical, (lineHeight - font.lineHeight) / 2)
//    }
//}
//
////"NanumSquareOTFL"
////"NanumSquareOTFEB"
////"NanumSquareOTFB"
////"NanumSquareOTFR"
//
//extension Font {
//    
//    enum Sans: String {
//        case light = "NanumSquareOTFL"
//        case regular = "NanumSquareOTFR"
//        case bold = "NanumSquareOTFB"
//        case extraBold = "NanumSquareOTFEB"
//    }
//}

import SwiftUI
struct CustomFont:ViewModifier{
    var font:FontType
    func body(content: Content)-> some View{
        let lineheight = UIFont(name: font.fontName, size: CGFloat(font.fontSize))?.lineHeight ?? 0
        let padding = Float(lineheight) * ((Float(font.lineHeight) - 100) / 100) / 2
        return content
            .font(.custom(font.fontName, size: CGFloat(font.fontSize)))
            .padding(.vertical, CGFloat(padding))
            .lineSpacing(CGFloat(padding * 2))
    }
}
extension View{
    func customFont(font: FontType) -> some View{
        return self.modifier(CustomFont(font: font))
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
