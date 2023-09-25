//
//  CommunityViewModel.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/18.
//

import Foundation
import Combine

struct BoardInfo: Hashable {
    let id: Int
    let type: Int
    let name: String
    let isSelected: Bool
    
    init(id: Int, type: Int, name: String, isSelected: Bool) {
        self.id = id
        self.type = type
        self.name = name
        self.isSelected = isSelected
    }
    
    init(board: Board, isSelected: Bool) {
        self.id = board.id
        self.type = board.type
        self.name = board.name
        self.isSelected = isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

protocol CommunityViewModelType: ObservableObject {
    var boardsListPublisher: [BoardInfo] { get }
    
    func selectBoard(id: Int)
    
    func loadBasicInfos()
}

final class CommunityViewModel: CommunityViewModelType {
    private let communityRepository: CommunityRepositoryProtocol
    
    @Published private var boardsList: [Board] = []
    @Published private var selectedBoardId: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
}

extension CommunityViewModel {
    var boardsListPublisher: [BoardInfo] {
        let selectedId = self.selectedBoardId
        let boardList = self.boardsList
        
        return boardList
            .map { board in
                return BoardInfo(board: board, isSelected: board.id == selectedId)
            }
    }
}

extension CommunityViewModel {
    func loadBasicInfos() {
        self.loadBoards()
    }
    
    private func loadBoards() {
        self.communityRepository
            .loadBoardList()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: { [weak self] boards in
                self?.boardsList = boards
                self?.selectedBoardId = boards.first?.id ?? 0
            })
            .store(in: &cancellables)
    }
    
    func selectBoard(id: Int) {
        self.selectedBoardId = id
    }
}
