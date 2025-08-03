//
//  TopPosts.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import SwiftUI

// TODO: TopPost 제대로 작동 + 레이아웃

struct TopPosts: View {
    var infos: [PostInfo]
    let needRefresh: Binding<Bool>
    
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    private let flippingAngle = Angle(degrees: 0)
    @State private var counter = 0
    @State private var select = 0
    
    private var appendedInfos: [PostInfo] {
        infos.count > 0 ? infos + [infos[0]] : []
    }
    
    var body: some View {
        TabView(selection: $select) {
            ForEach(appendedInfos.enumerated(), id: \.offset) { index, info in
                TopPostCell(post: info, needRefresh: needRefresh)
                    .frame(width: .infinity, height: .infinity)
                    .padding(.horizontal, 20)
                    .rotationEffect(.degrees(-90))
                    .rotation3DEffect(flippingAngle, axis: (x: 1, y: 0, z: 0))
                    .gesture(DragGesture())
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onReceive(timer) { _ in
            if select == appendedInfos.count - 1 {
                select = 0
                withAnimation {
                    select = 1
                }
            } else {
                withAnimation {
                    select += 1
                }
            }
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
}

/*struct TopPosts_Preview:PreviewProvider{
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
}*/
