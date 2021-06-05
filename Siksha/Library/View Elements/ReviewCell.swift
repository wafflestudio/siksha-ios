//
//  ReviewCell.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/06.
//

import SwiftUI

struct ReviewCell: View {
    private let formatter = DateFormatter()
    private var review: Review
    private var showPictures: Bool
    
    init(_ review: Review, _ showPictures: Bool) {
        self.review = review
        self.showPictures = showPictures
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
            
            ZStack(alignment: .top) {
                Image("SpeechBubble")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 331, height: 90)
                
                Text(review.comment ?? "")
                    .font(.custom("NanumSquareOTFR", size: 12))
                    .foregroundColor(.init(white: 79/255))
                    .frame(width: 303, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 13)
                
            }
            .frame(width: 331, height: 90)
            
            if showPictures && review.images != nil {
                ScrollView (.horizontal) {
                    HStack {
                        ForEach(review.images?["images"] ?? [], id: \.self) { image in
                            ClickableImage(image)
                        }
                    }
                }
                .frame(width: 314)
                .padding(.leading, 16)
            }
            
        }
        .padding([.leading, .trailing], 16)
        
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
            "comment": "150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자150자15",
            "etc": {},
            "created_at": "2021-03-05T18:05:50Z",
            "updated_at": "2021-03-05T18:05:50Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let review = try! decoder.decode(Review.self, from: jsonData)
        return Group {
            ReviewCell(review, true)
//                .previewDevice(PreviewDevice(rawValue: "iPhone11"))
        }
    }
}
