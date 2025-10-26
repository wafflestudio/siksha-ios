//
//  ImageView.swift
//  Siksha
//
//  Created by 박정헌 on 8/27/24.
//

import SwiftUI
import Kingfisher

struct ImageView<ViewModel>: View where ViewModel: CommunityPostViewModelType {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ViewModel
    @State var imageIndex: Int
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("Close")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundStyle(Color.iconWhiteIcon)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
        }
        .contentShape(Rectangle())
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0){
                ZStack {
                    HStack {
                        backButton
                        Spacer()
                    }
                    HStack {
                        Text("\(imageIndex + 1)/\(viewModel.postInfo.imageURLs!.count)")
                            .kerning(2.7)
                            .foregroundColor(.white)
                            .frame(alignment: .center)
                            .font(.custom("Inter-Bold", size: 16))
                    }
                }
                .padding(.top, 11)
                
                TabView(selection: $imageIndex) {
                    ForEach(viewModel.postInfo.imageURLs!.indices ,id: \.self) { index in
                        ZStack {
                            ZoomableScrollView {
                                KFImage(URL(string: viewModel.postInfo.imageURLs![index]))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                    }
                }
                .tabViewStyle(.page)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            
        }
        .background(Color.backgroundPrimary)
    }
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        scrollView.backgroundColor = UIColor(.backgroundPrimary)
        
        // create a UIHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        hostedView.backgroundColor = UIColor(.backgroundPrimary)
        scrollView.addSubview(hostedView)
        
        return scrollView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}
