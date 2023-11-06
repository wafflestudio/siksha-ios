//
//  RepositoryProtocol.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Foundation
import Combine

protocol RepositoryProtocol: CommunityRepositoryProtocol {

}

protocol CommunityRepositoryProtocol {
    func loadBoardList() -> AnyPublisher<[Board], Error>
    func loadPostsPage(boardId: Int, page: Int, perPage: Int) -> AnyPublisher<PostsPage, Error>
}
