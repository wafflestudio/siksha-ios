//
//  CommunitySubmitPostViewModel.swift
//  Siksha
//
//  Created by 박정헌 on 2023/12/02.
//

import Foundation
import Combine
import UIKit

protocol CommunitySubmitPostViewModelType:ObservableObject{
    var content:String{get set}
    var title:String{get set}
    var isAnonymous:Bool{get set}
    var images:[UIImage]{get set}
    var isSubmitted:Bool{get set}
    var isErrorAlert:Bool{get set}
    func submitPost()
    
}
class CommunitySubmitPostViewModel:CommunitySubmitPostViewModelType{
    private let communityRepository: CommunityRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var boardId:Int
    @Published var content = ""
    @Published var title = ""
    @Published var isAnonymous = false
    @Published var images:[UIImage] = []
    @Published var isSubmitted = false
    @Published var isErrorAlert = false
    init(boardId:Int,communityRepository: CommunityRepositoryProtocol) {
        self.boardId = boardId
        self.communityRepository = communityRepository
        
    }
    
    func submitPost(){
        communityRepository.submitPost(boardId: boardId, title: title, content: content, images: images.map{image in image.pngData()!}).sink(receiveCompletion: {[weak self]error in print(error)
            self?.isErrorAlert = true
        }, receiveValue: { [weak self] response in
            self?.isSubmitted = true
            
        }).store(in: &cancellables)
        
    }
    
    
}

