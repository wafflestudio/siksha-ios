//
//  TopPosts.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import Foundation
import SwiftUI
struct Post{
  var  title:String
   var content:String
   var like:Int
}
struct TopPosts:View{
    var content:[Post]
    var body:some View{
        GeometryReader{proxy in
            ScrollView(.horizontal,showsIndicators: false){
                
                TabView{
                    ForEach(content,id:\.title) { content in
                        TopPostCell(title: content.title, content: content.content, like: content.like).padding(EdgeInsets(top: 10, leading: 23, bottom: 10, trailing: 22))
                        
                    }
                } .frame(width: proxy.size.width) .tabViewStyle(PageTabViewStyle())
                
            }
          
        }
    }
}
struct TopPosts_Preview:PreviewProvider{
    static var previews: some View{
        TopPosts(content: [
            Post(title: "제목1",content: "내용1",like: 3),
            Post(title: "제목2",content: "내용2",like: 3),
            Post(title: "제목3",content: "내용3",like: 3)
        ])
    }
}
