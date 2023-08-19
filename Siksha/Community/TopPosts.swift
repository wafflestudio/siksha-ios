//
//  TopPosts.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import Foundation
import SwiftUI

struct TopPosts:View{
    var content:[CommunityPost]
    var body:some View{
        GeometryReader{proxy in
          
                TabView{
                    ForEach(content,id:\.title) { content in
                        TopPostCell(title: content.title, content: content.content, like: content.likeCount).padding(EdgeInsets(top: 10, leading: 23, bottom: 10, trailing: 22))
                        
                    }
                } .frame(width: proxy.size.width) .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
                
            
          
        }.frame(height:68)
    }
}
struct TopPosts_Preview:PreviewProvider{
    static var previews: some View{
        TopPosts(content: [
           CommunityPost(title: "post1", content: "content1", userLikes: true, likeCount: 2, replyCount: 3),
           CommunityPost(title: "post1", content: "content1", userLikes: true, likeCount: 2, replyCount: 3),
           CommunityPost(title: "post1", content: "content1", userLikes: true, likeCount: 2, replyCount: 3)
        ])
    }
}
