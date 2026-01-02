//
//  Double+roundedToHalf.swift
//  Siksha
//
//  Created by Jihyeon on 10/8/25.
//

import Foundation

extension Double {
    /// 가장 가까운 0.5 단위로 값을 반올림합니다.
    func roundedToHalf() -> Double {
        return (self * 2.0).rounded() / 2.0
    }
}
