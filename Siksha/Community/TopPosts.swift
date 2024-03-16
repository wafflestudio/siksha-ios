//
//  TopPosts.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import Foundation
import SwiftUI

struct TopPosts:View{
    var infos: [PostInfo]
    
    var body:some View{
        GeometryReader { proxy in
            TabView {
                ForEach(infos, id:\.title) { info in
                    TopPostCell(title: info.title, content: info.content, like: info.likeCount)
                        .padding(EdgeInsets(top: 10, leading: 23, bottom: 10, trailing: 22))
                    
                }
            }
            .frame(width: proxy.size.width)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }.frame(height:68)
    }
}
struct TopPosts_Preview:PreviewProvider{
    static var previews: some View{
        TopPosts(infos: (1..<5).map {
            return PostInfo(title: "name\($0)",
                         content: "content\($0)",
                         isLiked: $0 % 2 == 0,
                         likeCount: $0,
                         commentCount: $0,
                         imageURL: "",
                         isAnonymous: false,
                         isMine: false)
        })
    }
}
