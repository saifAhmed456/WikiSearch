//
//  ViewController.swift
//  WikiSearch
//
//  Created by saif ahmed on 14/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt
protocol ViewControllerProtocol {
    var dataSource : BehaviorRelay<TableViewDataSourceProtocol?> { get }
    var indexPathSelected : Observable<IndexPath> { get }
    var searchBarText : Observable<String?> { get }
    var animateSpinner : PublishSubject<Bool> { get }
}
class ViewController: UIViewController {
    
    @IBOutlet var mainView: MainView!
    var viewModel : WikiSearchViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.setupBindings(with: self)
        // Do any additional setup after loading the view.
    }
    
    
}

extension ViewController : ViewControllerProtocol {
    var animateSpinner: PublishSubject<Bool> {
        return mainView.animateSpinner
    }
    
    var dataSource: BehaviorRelay<TableViewDataSourceProtocol?> {
        return mainView.dataSourceRelay
    }
    
    var indexPathSelected: Observable<IndexPath> {
        return mainView.indexPathSelected
    }
    
    var searchBarText: Observable<String?> {
        return mainView.searchBarTextChanged
    }
    
    
}
