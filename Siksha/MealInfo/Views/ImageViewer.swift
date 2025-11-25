//
//  ImageViewer.swift
//  Siksha
//
//  Created by Jihyeon on 10/20/25.
//

import SwiftUI
import Kingfisher

struct ImageViewer: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Int
    private var imageURLs: [URL]
    private let showNumber: Bool
    
    init(imageURLs: [URL], initialIndex: Int = 0, showNumber: Bool = true) {
        self._selection = State(initialValue: max(0, min(imageURLs.count - 1, initialIndex)))
        self.imageURLs = imageURLs
        self.showNumber = showNumber
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            TabView(selection: $selection) {
                ForEach(Array(imageURLs.enumerated()), id: \.offset) { i, url in
                    ImageView(url: url)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image("Close")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.iconWhiteIcon)
                                .padding(.leading, 31)
                                .contentShape(Rectangle())
                        }
                        Spacer()
                    }
                    if showNumber {
                        Text("\(selection + 1) / \(imageURLs.count)")
                            .foregroundStyle(Color.iconWhiteIcon)
                            .customFont(font: .text16(weight: .ExtraBold))
                    }
                }
                Spacer()
            }
        }
    }
    
    struct ImageView: View {
        var url: URL
        
        var body: some View {
            KFImage(url)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ImageViewer(imageURLs: [
        URL(string: "https://images.unsplash.com/photo-1574158622682-e40e69881006?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1760")!,
        URL(string: "https://images.unsplash.com/photo-1574158622682-e40e69881006?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1760")!,
        URL(string: "https://images.unsplash.com/photo-1574158622682-e40e69881006?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1760")!,
    ])
}
