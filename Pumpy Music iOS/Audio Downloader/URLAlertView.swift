import SwiftUI
import AVFoundation

extension AudioDownloadView {
    
    func urlAddAudio() {
        let alert = UIAlertController(title: "Enter audio URL", message: "Enter URL containing audio file. \n USER MUST OWN OR HAVE THE OWNER'S PERMISSION BEFORE DOWNLOADING", preferredStyle: .alert)
        alert.addTextField() { textField in
            textField.placeholder = "Enter URL"
            self.addURLTextField = textField
        }
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            if let text = self.addURLTextField.text {
                adViewModel.addAudio(text) { (error) in
                    showAlert(error)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        showAlert(alert)
    }
    
    func showAlert(_ alert: UIAlertController) {
        if let controller = topMostViewController() {
            controller.present(alert, animated: true)
        }
    }
    
    func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter {$0.activationState == .foregroundActive}
            .compactMap {$0 as? UIWindowScene}
            .first?.windows.filter {$0.isKeyWindow}.first
    }
    
    func topMostViewController() -> UIViewController? {
        guard let rootController = keyWindow()?.rootViewController else {
            return nil
        }
        return topMostViewController(for: rootController)
    }
    
    func topMostViewController(for controller: UIViewController) -> UIViewController {
        if let presentedController = controller.presentedViewController {
            return topMostViewController(for: presentedController)
        } else if let navigationController = controller as? UINavigationController {
            guard let topController = navigationController.topViewController else {
                return navigationController
            }
            return topMostViewController(for: topController)
        } else if let tabController = controller as? UITabBarController {
            guard let topController = tabController.selectedViewController else {
                return tabController
            }
            return topMostViewController(for: topController)
        }
        return controller
    }
    
}
