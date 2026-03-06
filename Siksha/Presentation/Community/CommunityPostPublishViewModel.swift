//
//  CommunitySubmitPostViewModel.swift
//  Siksha
//
//  Created by 박정헌 on 2023/12/02.
//

import Foundation
import Combine
import UIKit

protocol CommunityPostPublishViewType:ObservableObject{
    var content:String{get set}
    var title:String{get set}
    var isAnonymous:Bool{get set}
    var images:[UIImage]{get set}
    var isSubmitted:Bool{get set}
    var isErrorAlert:Bool{get set}
    var boardId: Int { get }
    var postInfo: PostInfo? {get set}
    func submitPost()
    
}
class CommunityPostPublishViewModel:CommunityPostPublishViewType{
    var postInfo: PostInfo?
    private let communityRepository: CommunityRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    @Published var boardId:Int
    @Published var boardsList: [Board] = []
    @Published var content = ""
    @Published var title = ""
    @Published var isAnonymous: Bool {
        didSet {
            UserDefaults.standard.set(isAnonymous, forKey: "isAnonymous")
        }
    }
    @Published var images:[UIImage] = []
    @Published var isSubmitted = false
    @Published var isErrorAlert = false
    init(boardId:Int,communityRepository: CommunityRepositoryProtocol, postInfo: PostInfo? = nil) {
        self.boardId = boardId
        self.communityRepository = communityRepository
        self.isAnonymous = UserDefaults.standard.bool(forKey: "isAnonymous")
        
        loadBoardInfo()
        
        if let info = postInfo {
            self.postInfo = info
            self.title = info.title
            self.content = info.content
            self.isAnonymous = info.isAnonymous
            if let imageURLs = info.imageURLs {
                downloadImages(from: imageURLs) { loadedImages in
                    self.images = loadedImages
                }
            }
        }
    }
    
    func submitPost() {
        if let info = postInfo { //edit
            print("info.id")
            print(info.id)
            print(images.count)
            communityRepository.editPost(postId: info.id, boardId: boardId, title: title, content: content, images: images.map{image in image.pngData()!}, anonymous: isAnonymous).sink(receiveCompletion: {[weak self]error in print(error)
                self?.isErrorAlert = true
            }, receiveValue: { [weak self] response in
                self?.isSubmitted = true
                
            }).store(in: &cancellables)
        } else { //submit
            print("submit new")
            communityRepository.submitPost(boardId: boardId, title: title, content: content, images: images.map{image in image.pngData()!}, anonymous: isAnonymous).sink(receiveCompletion: {[weak self]error in print(error)
                self?.isErrorAlert = true
            }, receiveValue: { [weak self] response in
                self?.isSubmitted = true
                
            }).store(in: &cancellables)
        }
    }
    
    private func loadBoardInfo(){
        self.communityRepository.loadBoardList()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion:{
                error in
                print(error)
            },receiveValue: {[weak self] boards in
                self?.boardsList = boards
            })
            .store(in: &cancellables)
    }


    
    func downloadImages(from urls: [String], completion: @escaping ([UIImage]) -> Void) {
        let group = DispatchGroup()
        var images = [UIImage]()
        
        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            group.enter()
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { group.leave() }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        images.append(image)
                    }
                } else {
                    print("Error loading image from url: \(urlString), \(error?.localizedDescription ?? "Unknown error")")
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            completion(images)
        }
    }
    
    func removeImage(_ image: UIImage) {
        self.images.removeAll(where: { $0 == image })
        print(self.images.count)
    }


    
}

