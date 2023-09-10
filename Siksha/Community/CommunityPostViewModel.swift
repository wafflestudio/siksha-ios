//
//  CommunityPostViewModel.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/08/06.
//

import Foundation

class CommunityPostViewModel: ObservableObject {
    @Published var post: CommunityPost
    
    let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy/MM/dd"
        return dateFormatter
    }()
    
    let postCreatedAtString: String
    
    init(post: CommunityPost) {
        self.post = post
        self.postCreatedAtString = formatter.string(from: post.createdAt)
    }
    
    func loadImages() {
        post.images.append("https://loremflickr.com/cache/resized/65535_52930196820_c6c6e53e9f_300_300_nofilter.jpg")
        post.images.append("https://loremflickr.com/cache/resized/65535_52680639403_c407b1edfa_300_300_nofilter.jpg")
        post.images.append("https://loremflickr.com/cache/resized/21_24614369_5a109b2178_300_300_nofilter.jpg")
    }
}
