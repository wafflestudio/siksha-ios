//
//  CommunityRepository.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Foundation
import Combine

protocol CommunityRepositoryProtocol {
    func loadBoardList() -> AnyPublisher<[Board], Error>
}
