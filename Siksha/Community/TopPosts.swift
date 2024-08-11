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
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var counter = 0
    @State private var select = 0
    var body:some View{
        let appendedInfos = infos + [infos[0]]
        let flippingAngle = Angle(degrees: 0)
        GeometryReader { proxy in
            TabView(selection: $select) {
                ForEach(Array(zip(appendedInfos.indices, appendedInfos)), id: \.0) { index,info in
                    TopPostCell(title: info.title, content: info.content, like: info.likeCount)
    
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .rotationEffect(.degrees(-90))
                        .rotation3DEffect(flippingAngle, axis: (x: 1, y: 0, z: 0))
                        .gesture(DragGesture())


                    
                }

            }

                .background(Color.init(red:1,green:149/255,blue:34/255,opacity: 0.2))
                .cornerRadius(12)
            .frame(width: proxy.size.height, height: proxy.size.width)
            .rotation3DEffect(flippingAngle, axis: (x: 1, y: 0, z: 0))
            .rotationEffect(.degrees(90), anchor: .topLeading)
            .offset(x: proxy.size.width)

            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }  
        .frame(height:35)
        .onReceive(timer){ _ in
            if(select == appendedInfos.count - 1){
                select = 0
                withAnimation{
                    select = 1
                }
            }
            else{
                withAnimation{
                    select += 1
                }
            }
        }
        

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
                         imageURLs: nil,
                         isAnonymous: false,
                         isMine: false)
        })
    }
}
