//
//  ReviewCell.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/06.
//

import SwiftUI

struct ReviewCell: View {
    private let formatter = DateFormatter()
    var review: Review
    
    init(_ review: Review) {
        self.review = review
        formatter.dateFormat = "yyyy년 M월 d일"
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(review.comment)
                    .font(.custom("NanumSquareOTFR", size: 12))
                    .foregroundColor(.init(white: 79/255))
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(EdgeInsets(top: 12, leading: 18, bottom: 20, trailing: 18))
            
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatter.string(from: review.createdAt))
                        .font(.custom("NanumSquareOTFR", size: 10))
                        .foregroundColor(.init(white: 185/255))
                        .multilineTextAlignment(.leading)
                    
                    RatingStar(.constant(review.score), size: 13)
                }
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 10))
        }
        .background(
            Color.init("AppBackgroundColor")
                .cornerRadius(10)
        )
    }
}

struct ReviewCell_Previews: PreviewProvider {
    static var previews: some View {
        let jsonData = """
        {
            "id": 0,
            "menu_id": 0,
            "user_id": 0,
            "score": 4,
            "comment": "strings",
            "etc": {},
            "created_at": "2021-03-05T18:05:50Z",
            "updated_at": "2021-03-05T18:05:50Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let review = try! decoder.decode(Review.self, from: jsonData)
        return ReviewCell(review)
    }
}
