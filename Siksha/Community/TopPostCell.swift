//
//  TopPostCell.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import SwiftUI

struct TopPostCell: View{
    var post: PostInfo
    let needRefresh: Binding<Bool>
    
    var body: some View {
        NavigationLink {
            CommunityPostView(
                viewModel: CommunityPostViewModel(
                    communityRepository: DomainManager.shared.domain.communityRepository,
                    postId: post.id
                ),
                needPostViewRefresh:needRefresh
            )
        } label: {
            HStack(spacing: 0) {
                Text(post.title)
                    .customFont(font: .text13(weight: .Regular))
                    .foregroundColor(.blackColor)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image("like")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 11.5, height: 11)
                        .foregroundStyle(Color.orange500)
                    
                    Text("\(post.likeCount)")
                        .foregroundColor(Color.orange500)
                        .customFont(font: .text11(weight: .Bold))
                }
                .lineLimit(1)
            }
            .padding(EdgeInsets(top: 9, leading: 15, bottom: 8, trailing: 13))
            .background(Color.orangeTint)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .highPriorityGesture(DragGesture())
        }
        .highPriorityGesture(DragGesture())
    }
}
