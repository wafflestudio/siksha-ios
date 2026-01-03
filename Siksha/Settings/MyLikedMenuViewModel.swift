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
    @Published var noAlarmPermission = false
    @Published var isAlarmEnabled = UserDefaults.standard.bool(forKey: "isAlarmEnabled")
    @Published  var myLikedRestaurants: [MyLikedRestaurant] = []
    @Published var alarmTime:AlarmTime = .DAILY
    private var init_error = 0
    init(myLikedMenuRepository: MyLikedMenuRepositoryProtocol) {
        self.myLikedMenuRepository = myLikedMenuRepository
    }
    func failedAlarm(){
        print("errorALARM")
        error = AppError.unknownError("알람 오류가 발생했습니다.")
    }
    func getAlarmTime(){
        myLikedMenuRepository.getAlarmTime()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: {[weak self] response in
                self?.alarmTime = AlarmTime(rawValue: response.alarmType)!
                
            })
            .store(in: &cancellables)
    }
    func loadMyLikedMenu(){
        myLikedMenuRepository.getMyLikedMenu()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    if self?.init_error == 0{ //  알람 화면에서 뒤로 갈 때 알람 떠서 잘 안 돌아가지는 문제 해결용
                        self?.error = ErrorHelper.categorize(error)
                    }
                    self?.init_error += 1
                }
            }, receiveValue: { [weak self] restaurants in
                self?.myLikedRestaurants = restaurants.restaurants
                self?.init_error = 0
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
                    self?.error = nil
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
    private func enableAllAlarm(){
        for (i,_) in myLikedRestaurants.enumerated(){
            for (j,_) in myLikedRestaurants[i].menus.enumerated(){
                     myLikedRestaurants[i].menus[j].alarm = true
                
            }
        }
    }
    private func disableAllAlarm(){
        for (i,_) in myLikedRestaurants.enumerated(){
            for (j,_) in myLikedRestaurants[i].menus.enumerated(){
                     myLikedRestaurants[i].menus[j].alarm = false
                
            }
        }
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
     func enableAlarm(){
        
        myLikedMenuRepository.onAlarmAll()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    UserDefaults.standard.set(true,forKey: "isAlarmEnabled")

                    withAnimation(.easeOut(duration: 0.3)) {
                        self?.isAlarmEnabled = true
                        self?.enableAllAlarm()

                    }
                case .failure(let error):
                    print("ERROR")
                    print(error)
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)

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
                        self?.disableAllAlarm()
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
            AppDelegate.alarmViewModel = self
            AppDelegate.requestNotificationPermission()
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
