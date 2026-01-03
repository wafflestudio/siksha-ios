//
//  AlarmViewModel.swift
//  Siksha
//
//  Created by 박정헌 on 10/31/25.
//

import Foundation
import Combine
class AlarmViewModel:ObservableObject{
    @Published var isAlarmOn = true
    private var cancellables = Set<AnyCancellable>()
    private var repository:AuthRepositoryProtocol = DomainManager.shared.domain.authRepository
    private func turnOnAlarm(){
        let token = UserDefaults.standard.string(forKey: "fcmToken")
        guard let token = token else { return }
        print("FCM:",token)
        DomainManager.shared.domain.authRepository.postUserDevice(fcmToken: token)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                    print("Token Registration fail")
                 
                }
            }, receiveValue: { [weak self] in
                print("Token Registration success")
                self?.isAlarmOn = true
            })
            .store(in: &cancellables)
    }
    private func turnOffAlarm(){
        let token = UserDefaults.standard.string(forKey: "fcmToken")
        guard let token = token else { return }
        print("FCM:",token)
        DomainManager.shared.domain.authRepository.deleteUserDevice(fcmToken: token)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                    print("Token Delete fail")

                }
            }, receiveValue: { [weak self] in
                print("Token Delete success")
                    self?.isAlarmOn = false
                
            })
            .store(in: &cancellables)

    }
    func toggleAlarm(){
        if isAlarmOn{
            turnOffAlarm()
        }
        else{
            turnOnAlarm()
        }
    }
    
}
