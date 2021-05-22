//
//  WebViewController.swift
//  WikiSearch
//
//  Created by saif ahmed on 14/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
protocol WebViewControllerProtocol {
    var backButtonTapped : Observable<Void> { get }
    var urlToLoad : BehaviorRelay<String?> { get }
}
class WebViewController: UIViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var webView: WKWebView!
    var viewModel : WebViewModel?
    var urlToLoad = BehaviorRelay<String?>(value : nil)
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        viewModel?.setupBindings(with: self)
        webView.navigationDelegate = self
        // Do any additional setup after loading the view.
    }
    func setupBindings() {
        urlToLoad
            .unwrap()
            .subscribe(onNext : {[weak self] urlString in
                guard let url = URL(string: urlString) else { return }
                let urlRequest = URLRequest(url: url)
                self?.spinner.startAnimating()
                self?.webView.load(urlRequest)
                
            })
            .disposed(by: disposeBag)
        
        
    }
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
    }
    
    
    
}
extension WebViewController : WebViewControllerProtocol {
    
    
    var backButtonTapped: Observable<Void> {
        return backButton.rx.tap.asObservable()
    }
    
    
}
extension WebViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
    }
}
