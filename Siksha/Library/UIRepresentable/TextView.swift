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
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        
        view.isScrollEnabled = true
        view.isEditable = true
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor(named: "AppBackgroundColor")
        view.layer.cornerRadius = 10
        view.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        view.font = .systemFont(ofSize: 14)
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if self.text.count > 0 {
            uiView.text = self.text
            uiView.textColor = .black
        } else {
            uiView.text = self.placeHolder
            uiView.textColor = .lightGray
        }
        
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var parent: TextView
        
        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }
        
        func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            if self.parent.placeHolder != "" {
                self.parent.placeHolder = ""
            }
            textView.textColor = .black
            
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
            if textView.text.count > 0 {
                self.parent.placeHolder = ""
            }
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
            return updatedText.count <= 500
        }
    }
}
