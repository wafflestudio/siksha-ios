//
//  PageView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI

struct PageView<Content: View>: View {
    var viewControllers: [UIHostingController<Content>]
    @Binding var currentPage: Int
    init(currentPage: Binding<Int>, _ views: [Content]) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
        self._currentPage = currentPage
    }

    var body: some View {
        PageViewController(controllers: viewControllers, currentPage: $currentPage)
    }
}
