
//
//  AppState.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/02.
//
import Foundation
import SwiftyJSON
import Realm
import RealmSwift
import Combine

public class AppState: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showSheet: Bool = false
    @Published var restaurantToShow: Restaurant? = nil
    @Published var mealToReview: Meal? = nil
    
    @Published var ratingEnabled: Bool = true
    
    var modalHeight: CGFloat {
        if restaurantToShow != nil {
            return 400
        } else if mealToReview != nil {
            return 320
        } else {
            return 0
        }
    }

    init(){
        $restaurantToShow
            .filter { $0 != nil }
            .sink { [weak self] restaurant in
                guard let self = self else { return }
                self.showSheet = true
            }
            .store(in: &cancellables)
        
        $mealToReview
            .filter { $0 != nil }
            .sink { [weak self] restaurant in
                guard let self = self else { return }
                self.showSheet = true
            }
            .store(in: &cancellables)
        
        $showSheet
            .filter { !$0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.restaurantToShow = nil
                self.mealToReview = nil
            }
            .store(in: &cancellables)
    }
}
