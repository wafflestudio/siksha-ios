//
//  CommunityReplyBar.swift
//  Siksha
//
//  Created by 김령교 on 8/27/23.
//

import SwiftUI

struct CommunityReplyBar: View {
    @State var commentText: String = ""
    @State var isAnonymous: Bool = UserDefaults.standard.bool(forKey: "isAnonymous")
    var onCommentSubmit: (String, Bool) -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.backgroundPrimary)
                .frame(height: 52)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray50)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .overlay(
                    HStack(spacing: 0) {
                        //                        anonymousButton
                        //                            .padding(EdgeInsets(top: 11.5, leading: 12, bottom: 7.5, trailing: 8))
                        TextField(
                            "댓글을 입력하세요.",
                            text: $commentText,
                            prompt: Text("댓글을 입력하세요.").foregroundColor(.gray500)
                        )
                        .customFont(font: .text13(weight: .Bold))
                        .padding(.top, 3)
                        Button(action: {
                            if commentText != "" {
                                onCommentSubmit(commentText, isAnonymous)
                                commentText = ""
                            }
                        }) {
                            Text("올리기")
                                .padding(EdgeInsets(top: 4.5, leading: 10, bottom: 4.5, trailing: 10))
                                .customFont(font: .text13(weight: .Bold))
                                .foregroundColor(.backgroundPrimary)
                                .background(Color.orange500)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .padding(6.5)
                        }
                    }
                )
                .padding(.horizontal, 8.5)
        }
    }

    var anonymousButton: some View {
        Toggle(isOn: $isAnonymous) {
            Text("익명")
        }
        .toggleStyle(CustomCheckboxStyle())
        .onChange(of: isAnonymous) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: "isAnonymous")
        }
    }
    struct CustomCheckboxStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 5) {
                if configuration.isOn {
                    Image("CheckboxTicked")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(Color.orange500)
                } else {
                    Image("Checkbox")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(Color.gray600)
                }

                configuration.label
                    .customFont(font: .text12(weight: .ExtraBold))
                    .foregroundColor(configuration.isOn ? .orange500 : .gray600)
            }
            .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
            .contentShape(Rectangle())
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

struct CommunityReplyBar_Previews: PreviewProvider {
    static var previews: some View {
        CommunityReplyBar(onCommentSubmit: { commentText, isAnonymous in
            print("Comment submitted: \(commentText)\nisAnonymous: \(isAnonymous)")
        })
    }
}
