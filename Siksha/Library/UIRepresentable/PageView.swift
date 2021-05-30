//
//  PageViewController.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI

struct PageView<Content: View>: UIViewControllerRepresentable {
    var pages: [Content]
    @Binding var currentPage: Int
    @Binding var needReload: Bool
    
    init(currentPage: Binding<Int>, needReload: Binding<Bool>, _ pages: [Content]){
        self.pages = pages
        self._currentPage = currentPage
        self._needReload = needReload
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, pages: pages)
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        
        return pageViewController
    }
    
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        guard !pages.isEmpty else {
            return
        }
        
        if needReload {
            context.coordinator.controllers = pages.map({ UIHostingController(rootView: $0) })
            self.needReload = false
        }
        
        var direction: UIPageViewController.NavigationDirection = .forward
        var animated: Bool = false
        
        if let previousViewController = pageViewController.viewControllers?.first,
           let previousPage = context.coordinator.controllers.firstIndex(of: previousViewController) {
            direction = (currentPage >= previousPage) ? .forward : .reverse
            animated = (currentPage != previousPage)
        }
        
        let currentViewController = context.coordinator.controllers[currentPage]
        pageViewController.setViewControllers([currentViewController], direction: direction, animated: animated)
    }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageView
        var controllers: [UIViewController]
        
        init(_ pageView: PageView, pages: [Content]) {
            self.parent = pageView
            self.controllers = pages.map({ UIHostingController(rootView: $0) })
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return nil
            }
            return controllers[index - 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == controllers.count {
                return nil
            }
            return controllers[index + 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
               let visibleViewController = pageViewController.viewControllers?.first,
               let index = controllers.firstIndex(of: visibleViewController) {
                parent.currentPage = index
            }
        }
    }
}
