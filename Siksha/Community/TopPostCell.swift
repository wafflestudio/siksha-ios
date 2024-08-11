//
//  TopPostCell.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import Foundation
import SwiftUI
struct TopPostCell:View{
    var post:PostInfo
    let needRefresh:Binding<Bool>
    var body:some View{
        NavigationLink(destination: CommunityPostView(viewModel: CommunityPostViewModel(communityRepository: DomainManager.shared.domain.communityRepository, postId: post.id), needPostViewRefresh:needRefresh)) {
            HStack(alignment: .center){
                Text(post.title)
                    .font(.custom("NanumSquareOTFBold", size: 12))
                    .foregroundColor(.black)
                    .lineLimit(1)
                Spacer().frame(width:15)
                Text(post.content)
                    .font(.custom("NanumSquareOTFRegular",size:12))
                    .foregroundColor(Color("ReviewHighColor"))
                    .lineLimit(1)
                Spacer()
                
                Image("like").padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                
                Text("\(post.likeCount)").foregroundColor(Color.init(red:1,green:149/255,blue:34/255))
                    .font(.custom("NanumSquareOTFRegular",size:8))
            }
            
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            
        }
    }
}
/*struct TopPostCell_Preview:PreviewProvider{
    static var previews:some View{
        TopPostCell(post: <#PostInfo#>, title: "제목", content: "본문 본문 본문", like: 3)
    }
}*/
