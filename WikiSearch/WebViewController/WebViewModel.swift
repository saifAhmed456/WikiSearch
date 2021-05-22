//
//  WebViewModel.swift
//  WikiSearch
//
//  Created by saif ahmed on 14/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
protocol  WebViewFlowCoordinating  {
    func dismissViewController()
}
class WebViewModel {
    var flowCoordinator : WebViewFlowCoordinating
    var urlToLoad = BehaviorRelay<String?>(value : nil)
    var disposeBag = DisposeBag()
    var backButtonTapped = PublishSubject<Void>()
    init(flowCoordinator : WebViewFlowCoordinating) {
        self.flowCoordinator = flowCoordinator
        setupBindings()
    }
    func setupBindings() {
        
        backButtonTapped
            .subscribe(onNext : {[weak self]() in
                self?.flowCoordinator.dismissViewController()
            }).disposed(by: disposeBag)
    }
    func setupBindings(with view : WebViewControllerProtocol) {
        urlToLoad
            .bind(to: view.urlToLoad)
            .disposed(by : disposeBag)
        view.backButtonTapped
            .bind(to: backButtonTapped)
            .disposed(by: disposeBag)
    }
}
