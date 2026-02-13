//
//  MenuMapper.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

enum MenuMapper {
    static func toModel(_ dto: MenuDTO) -> MenuModel {
        MenuModel(
            id: dto.id,
            code: dto.code,
            nameKr: dto.nameKr,
            nameEn: dto.nameEn,
            price: dto.price,
            score: dto.score,
            reviewCount: dto.reviewCnt,
            isLiked: dto.isLiked,
            likeCount: dto.likeCnt,
            imageURLStrings: dto.etc
        )
    }
}
