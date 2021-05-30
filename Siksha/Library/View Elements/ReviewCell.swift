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
                Image("LogoEllipse")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading) {
                    Text("ID \(String(review.userId))")
                        .font(.custom("NanumSquareOTF", size: 12))
                        .foregroundColor(.black)
                    RatingStar(.constant(review.score), size: 13)
                        .padding(.top, -6)
                }
                .padding(.leading, 7)
                
                Spacer()
                
                Text(formatter.string(from: review.createdAt))
                    .font(.custom("NanumSquareOTFR", size: 12))
                    .foregroundColor(.init(white: 185/255))
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 16)
            }
            
            ZStack {
                Image("SpeechBubble")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 331, height: 70)
                
                HStack {
                    Text(review.comment ?? "")
                        .font(.custom("NanumSquareOTFR", size: 12))
                        .foregroundColor(.init(white: 79/255))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.top, -23)
                .padding(.leading, 23)
                .frame(height: 70)
                
            }
            .padding(.trailing, 16)
            
            if review.images != nil {
                ScrollView (.horizontal) {
                    HStack {
//                        ForEach(review.images, id: \.self) { image in
//                            Image(uiImage: image)
//                                .resizable()
//                                .renderingMode(.original)
//                                .frame(width: 80, height: 80)
//                                .cornerRadius(8)
//                        }
                    }
                }
            }
            
        }
        .padding(.leading, 16)
        
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
