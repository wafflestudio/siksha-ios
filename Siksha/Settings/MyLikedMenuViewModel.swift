//
//  MyLikedMenuViewModel.swift
//  Siksha
//
//  Created by 박정헌 on 9/18/25.
//

import Foundation
import Combine
import SwiftUI

class MyLikedMenuViewModel: ObservableObject{
    private let myLikedMenuRepository: MyLikedMenuRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var error: AppError?
    @Published var isAlarmEnabled = UserDefaults.standard.bool(forKey: "isAlarmEnabled")
    @Published  var myLikedRestaurants: [MyLikedRestaurant] = []
    @Published var alarmTime:AlarmTime = .DAILY
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
    private func isLikedMenu(menuId:Int)->Bool{
        for (i,_) in myLikedRestaurants.enumerated(){
            for (j,_) in myLikedRestaurants[i].menus.enumerated(){
                if myLikedRestaurants[i].menus[j].id == menuId{
                    return myLikedRestaurants[i].menus[j].isLiked
                }
            }
        }
        return false
    }
    private func toggleMenuLike(menuId:Int){
        for (i,_) in myLikedRestaurants.enumerated(){
            for (j,_) in myLikedRestaurants[i].menus.enumerated(){
                if myLikedRestaurants[i].menus[j].id == menuId{
                    myLikedRestaurants[i].menus[j].isLiked.toggle()
                }
            }
        }
    }
    private func toggleMenuAlarm(menuId:Int){
        for (i,_) in myLikedRestaurants.enumerated(){
            for (j,_) in myLikedRestaurants[i].menus.enumerated(){
                if myLikedRestaurants[i].menus[j].id == menuId{
                    myLikedRestaurants[i].menus[j].alarm.toggle()
                }
            }
        }
    }
    private func unlikeMenu(menuId: Int){
        myLikedMenuRepository.unlikeMenu(menuId: menuId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    self?.toggleMenuLike(menuId: menuId)
                case .failure(let error):
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)

    }
    private func likeMenu(menuId: Int){
        myLikedMenuRepository.likeMenu(menuId: menuId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    self?.toggleMenuLike(menuId: menuId)
                case .failure(let error):
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)

    }
    func toggleMenu(menuId: Int){
        if isLikedMenu(menuId: menuId){
            unlikeMenu(menuId: menuId)
        }
        else{
            likeMenu(menuId: menuId)
        }
    }
    private func removeMenu(menuId: Int){
        for (i,_) in myLikedRestaurants.enumerated(){
            for (j,_) in myLikedRestaurants[i].menus.enumerated(){
                if myLikedRestaurants[i].menus[j].id == menuId{
                    myLikedRestaurants[i].menus[j].isLiked = false
                }
            }
        }
      
    }
    func unLikedMenuCleanup(){
        for (i,_) in myLikedRestaurants.enumerated(){
            myLikedRestaurants[i].menus.removeAll(where: {
                menu in
                !menu.isLiked
            })
        }
        myLikedRestaurants.removeAll(where: {
            restaurant in
            restaurant.menus.isEmpty
        })
    }
    private func isAlarmOn(menuId:Int)->Bool{
        for (i,_) in myLikedRestaurants.enumerated(){
            for (j,_) in myLikedRestaurants[i].menus.enumerated(){
                if myLikedRestaurants[i].menus[j].id == menuId{
                    return myLikedRestaurants[i].menus[j].alarm
                }
            }
        }
        return false
    }
    private func turnOnAlarm(menuId:Int){
        myLikedMenuRepository.onAlarm(menuId: menuId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    self?.toggleMenuAlarm(menuId:menuId)
                case .failure(let error):
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)

    }
    private func turnOffAlarm(menuId:Int){
        myLikedMenuRepository.offAlarm(menuId: menuId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    self?.toggleMenuAlarm(menuId:menuId)
                case .failure(let error):
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)

    }
    func toggleAlarm(menuId:Int){
        if isAlarmOn(menuId: menuId){
            turnOffAlarm(menuId: menuId)
        }
        else{
            turnOnAlarm(menuId: menuId)
        }
    }
    private func enableAlarm(){
        UserDefaults.standard.set(true, forKey: "isAlarmEnabled")
        withAnimation(.easeOut(duration: 0.3)) {
            self.isAlarmEnabled = true
        }
    }
    private func disableAlarm(){
        myLikedMenuRepository.offAlarmAll()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    UserDefaults.standard.set(false,forKey: "isAlarmEnabled")
                    withAnimation(.easeOut(duration: 0.3)) {
                        self?.isAlarmEnabled = false
                    }
                case .failure(let error):
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)

    }
    func toggleAlarmEnabled(){
        
        if isAlarmEnabled{
            disableAlarm()
        }
        else{
            enableAlarm()
        }
    }
    func toggleAlarmTime(){
        let next_alarm_time =   alarmTime == AlarmTime.EVERY_MEAL ? AlarmTime.DAILY : AlarmTime.EVERY_MEAL
        myLikedMenuRepository.postAlarmTime(type: next_alarm_time )
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    self?.alarmTime = next_alarm_time
 
                case .failure(let error):
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)

    }
}
