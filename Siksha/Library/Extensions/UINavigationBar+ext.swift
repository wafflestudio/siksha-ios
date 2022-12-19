//
//  UINavigationBar+ext.swift
//  Siksha
//
//  Created by 한상현 on 2022/12/20.
//

import UIKit

extension UINavigationBar {
    static func changeBackgroundColor(color: UIColor) {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.backgroundColor = color

        Self.appearance().standardAppearance = coloredAppearance
        Self.appearance().compactAppearance = coloredAppearance
        Self.appearance().scrollEdgeAppearance = coloredAppearance
    }
}
