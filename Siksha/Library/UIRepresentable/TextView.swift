//
//  TextView.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/08.
//

import Foundation
import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var placeHolder: String
    var maxCount: Int = 150
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, maxCount: self.maxCount)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        
        view.isScrollEnabled = true
        view.isEditable = true
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor(Color.gray50)
        view.layer.cornerRadius = 10
        view.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        view.font = .systemFont(ofSize: 14)
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if !self.text.isEmpty {
            uiView.text = self.text
            uiView.textColor = UIColor(Color.blackColor)
        }
        // 텍스트가 비어있고 포커스가 없으면 플레이스홀더 표시
        else if !uiView.isFirstResponder && !self.placeHolder.isEmpty {
            uiView.text = self.placeHolder
            uiView.textColor = UIColor(Color.textBubble)
        }
        // 텍스트가 비어있고 포커스가 있으면 빈 텍스트
        else if uiView.isFirstResponder {
            uiView.text = ""
            uiView.textColor = UIColor(Color.blackColor)
        }
        
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var parent: TextView
        let maxCount: Int
        
        init(_ uiTextView: TextView, maxCount: Int) {
            self.parent = uiTextView
            self.maxCount = maxCount
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
              /// 플레이스홀더 텍스트이면 지우기
              if textView.text == self.parent.placeHolder {
                  textView.text = ""
                  textView.textColor = UIColor(Color.blackColor)
              }
          }
          
          func textViewDidEndEditing(_ textView: UITextView) {
              /// 텍스트가 비어있으면 플레이스홀더 표시
              if textView.text.isEmpty {
                  textView.text = self.parent.placeHolder
                  textView.textColor = UIColor(Color.textBubble)
              }
          }
          
          func textViewDidChange(_ textView: UITextView) {
              /// 플레이스홀더가 아닌 경우에만 text 업데이트
              if textView.text != self.parent.placeHolder {
                  self.parent.text = textView.text
              }
          }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
            return updatedText.count <= self.maxCount
        }
    }
}
