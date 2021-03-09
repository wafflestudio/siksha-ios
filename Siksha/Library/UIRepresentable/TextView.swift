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
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = self.text
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        @Binding var text: String
        
        init(_ uiTextView: TextView) {
            self._text = uiTextView.$text
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.text = textView.text
        }
    }
}
