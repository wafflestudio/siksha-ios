//
//  MyLikedMenuViewModel.swift
//  Siksha
//
//  Created by 박정헌 on 9/18/25.
//

import Foundation
import Combine

class MyLikedMenuViewModel: ObservableObject{
    private let myLikedMenuRepository: MyLikedMenuRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var error: AppError?
    @Published  var myLikedRestaurants: [MyLikedRestaurant] = []
    
    init(myLikedMenuRepository: MyLikedMenuRepositoryProtocol) {
        self.myLikedMenuRepository = myLikedMenuRepository
        loadMyLikedMenu()
    }
 
    func loadMyLikedMenu(){
        myLikedMenuRepository.getMyLikedMenu()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { [weak self] restaurants in
                self?.myLikedRestaurants = restaurants.restaurants
            })
            .store(in: &cancellables)

    }
    func unlikeMenu(menuId: Int){
        myLikedMenuRepository.unlikeMenu(menuId: menuId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    self?.removeMenu(menuId: menuId)
                case .failure(let error):
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)

    }
    private func removeMenu(menuId: Int){
        for (i,_) in myLikedRestaurants.enumerated(){
            myLikedRestaurants[i].menus.removeAll(where: {
                menu in
                menu.id == menuId
            })
        }
        myLikedRestaurants.removeAll(where: {
            restaurant in
            restaurant.menus.isEmpty
        })
    }
}
