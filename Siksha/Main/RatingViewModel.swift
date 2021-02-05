//
//  RatingViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import Foundation
import Combine

class RatingViewModel: ObservableObject {
    var scoreToRate: Double = 0
    
    func submitReview() {
        print("submit")
    }
}
