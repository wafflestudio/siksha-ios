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
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Image("LogoEllipse")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading) {
                    Text("ID \(String(review.userId))")
                        .font(.custom("NanumSquareOTFB", size: 12))
                        .foregroundColor(.black)
                    RatingStar(.constant(review.score), size: 11, spacing: 0.75)
                        .padding(.top, -6)
                }
                .padding(.leading, 7)
                
                Spacer()
                
                Text(review.createdAt.toLegibleString())
                    .font(.custom("NanumSquareOTFB", size: 12))
                    .foregroundColor(.init(white: 185/255))
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 2)
            }
            
            HStack(alignment: .top, spacing: 0) {
                Image("SpeechTail")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 13.5, height: 17)
                    .padding(.top, 7)
                    .zIndex(1)
                    .shadow(color: .init(white: 0, opacity: 0.08), radius: 1.5, x: -1.5)
                
                Text(review.comment ?? "")
                    .font(.custom("NanumSquareOTFR", size: 12))
                    .foregroundColor(.init(white: 79/255))
                    .padding(10)
                    .frame(maxWidth: .infinity, minHeight: 75, alignment: .topLeading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.white)
                            .shadow(color: .init(white: 0, opacity: 0.15), radius: 1.5)
                    )
            }
            .padding(EdgeInsets(top: 2, leading: 16, bottom: 0, trailing: 0))
            
            if showPictures && review.images != nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(review.images?["images"] ?? [], id: \.self) { image in
                            ThumbnailImage(image)
                        }
                    }
                }
                .padding(EdgeInsets(top: 6, leading: 30, bottom: 0, trailing: 2))
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
