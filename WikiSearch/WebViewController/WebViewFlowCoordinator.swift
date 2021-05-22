//
//  WebViewFlowCoordinator.swift
//  WikiSearch
//
//  Created by saif ahmed on 14/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import Foundation
import UIKit
class WebViewFlowCoordinator : WebViewFlowCoordinating {
    func dismissViewController() {
        presenter?.dismiss(animated: true)
    }
    
    weak var presenter : UIViewController?
    static func prepareView(with url : String) -> UIViewController {
        let storyboard = UIStoryboard(name: "WebViewStoryboard", bundle: nil)
        guard   let viewController = storyboard.instantiateInitialViewController() , let webController = viewController as? WebViewController else {
            fatalError("can not load view controller")
        }
        let flowCoordinator = WebViewFlowCoordinator()
        let viewModel = WebViewModel(flowCoordinator: flowCoordinator)
        webController.viewModel = viewModel
        flowCoordinator.presenter = webController
        webController.urlToLoad.accept(url)
        return webController
    }
}
