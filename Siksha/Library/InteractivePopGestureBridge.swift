//
//  InteractivePopGestureBridge.swift
//  Siksha
//

import SwiftUI
import UIKit

@MainActor
final class InteractivePopGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    weak var navigationController: UINavigationController?

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (navigationController?.viewControllers.count ?? 0) > 1
    }
}

@MainActor
final class InteractivePopGestureBridgeController: UIViewController {
    private let popGestureDelegate = InteractivePopGestureDelegate()
    private weak var gestureRecognizer: UIGestureRecognizer?
    private weak var previousDelegate: (any UIGestureRecognizerDelegate)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        install()
    }

    func install() {
        guard let navigationController,
            let gestureRecognizer = navigationController.interactivePopGestureRecognizer
        else {
            return
        }

        if self.gestureRecognizer === gestureRecognizer,
            gestureRecognizer.delegate === popGestureDelegate
        {
            return
        }

        uninstall()
        guard !(gestureRecognizer.delegate is InteractivePopGestureDelegate) else {
            return
        }

        popGestureDelegate.navigationController = navigationController
        previousDelegate = gestureRecognizer.delegate
        self.gestureRecognizer = gestureRecognizer
        gestureRecognizer.delegate = popGestureDelegate
    }

    func uninstall() {
        guard let gestureRecognizer else { return }
        if gestureRecognizer.delegate === popGestureDelegate {
            gestureRecognizer.delegate = previousDelegate
        }
        self.gestureRecognizer = nil
        previousDelegate = nil
        popGestureDelegate.navigationController = nil
    }

    deinit {
        MainActor.assumeIsolated {
            uninstall()
        }
    }
}

@MainActor
struct InteractivePopGestureBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> InteractivePopGestureBridgeController {
        InteractivePopGestureBridgeController()
    }

    func updateUIViewController(_ controller: InteractivePopGestureBridgeController, context: Context) {
        controller.install()
    }

    static func dismantleUIViewController(
        _ controller: InteractivePopGestureBridgeController,
        coordinator: ()
    ) {
        controller.uninstall()
    }
}
