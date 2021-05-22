//
//  WikiSearchFlowCoordinator.swift
//  WikiSearch
//
//  Created by saif ahmed on 14/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import Foundation
import UIKit
class WikiSearchFlowCoordinator : WikiSearchFlowCoordinating {
    func gotoWebView(with url: String) {
        let webController = WebViewFlowCoordinator.prepareView(with: url)
        webController.modalPresentationStyle = .overFullScreen
        presenter?.present(webController, animated: true)
    }
    
    weak var presenter : UIViewController?
    static func prepareWikiSearchView() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard   let viewController = storyboard.instantiateInitialViewController(), let searchController = viewController as? ViewController else {
            fatalError("can not load view controller")
        }
        let flowCoordinator = WikiSearchFlowCoordinator()
        let viewModel = WikiSearchViewModel(flowCoordinator : flowCoordinator)
        searchController.viewModel = viewModel
        flowCoordinator.presenter = searchController
        return searchController
    }
}
