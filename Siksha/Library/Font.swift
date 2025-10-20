//
//  Font.swift
//  Siksha
//
//  Created by 박정헌 on 5/19/25.
//
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
