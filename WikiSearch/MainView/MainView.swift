//
//  MainView.swift
//  WikiSearch
//
//  Created by saif ahmed on 14/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt
enum CurrentSearchStatus {
    case noResults
    // when search text is not empty and the results are empty
    case searchTextEmpty
    // when text in search bar is empty
    case someResults
    // if the number of items in any one of the sections is not zero
    
    var constraintPriority : UILayoutPriority {
        switch self {
        case .noResults,.someResults : return .required
        case .searchTextEmpty : return .defaultLow
        }
    }
    var alphaForPlaceholderView : CGFloat {
        switch self {
        case .noResults : return 1
        default : return 0
        }
    }
    
    var alphaForBackgroundImage : CGFloat {
        switch self {
        case .searchTextEmpty : return 1
        default : return 0
        }
    }
}
protocol TableViewDataSourceProtocol {
    var numOfSections : Int { get }
    func numOfItems(in section : Int) -> Int
    func item(for indexPath : IndexPath) -> TableViewCellDataSourceProtocol?
    var reload : BehaviorRelay<CurrentSearchStatus> { get }
    
}
class MainView: UIView {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var bakgroundImageView: UIImageView!
    @IBOutlet var noResultsView: PlaceholderView!
    
    @IBOutlet var searchBarTopConstraint: NSLayoutConstraint!
    var dataSourceRelay = BehaviorRelay<TableViewDataSourceProtocol?>(value: nil)
    var disposeBag = DisposeBag()
    
    /* var loadMoreResults = PublishSubject<Void>()
     TODO :- Fetch more results when tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) for last row is called
     */
    
    
    var searchBarTextChanged : Observable<String?> {
        return searchBar.rx.text.asObservable().debounce(RxTimeInterval.milliseconds(600), scheduler: MainScheduler.asyncInstance)
    }
    var indexPathSelected: Observable<IndexPath> {
        return tableView.rx.itemSelected.asObservable()
    }
    
    var animateSpinner = PublishSubject<Bool>()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    func  commonInit() {
        addXib()
        setupBindings()
        setupTableViewDataSourceAndDelegate()
        searchBar.delegate = self
        addTapgesture()
    }
    func addTapgesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGesture.cancelsTouchesInView = false
    addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        endEditing(true)
    }
    func setupTableViewDataSourceAndDelegate() {
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
    }
    
    func setupBindings() {
        dataSourceRelay
            .unwrap()
            .flatMapLatest{$0.reload}
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext : {[weak self] searchStatus in
                UIView.animate(withDuration: 1.0) {
                    self?.searchBarTopConstraint.priority = searchStatus.constraintPriority
                    self?.bakgroundImageView.alpha = searchStatus.alphaForBackgroundImage
                    self?.layoutIfNeeded()
                }
            }).disposed(by : disposeBag)
        
        dataSourceRelay
            .unwrap()
            .flatMapLatest{$0.reload}
            .map{$0.alphaForPlaceholderView}
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: noResultsView.rx.animateHide)
            .disposed(by: disposeBag)
        
        dataSourceRelay
            .unwrap()
            .flatMapLatest{$0.reload}
            .map{_ in return }
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: tableView.rx.reload)
            .disposed(by: disposeBag)
        
        
        
        animateSpinner
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
    }
}

extension MainView : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceRelay.value?.numOfSections ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceRelay.value?.numOfItems(in: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        
        guard let data = dataSourceRelay.value?.item(for: indexPath), let wikiCell = cell as? TableViewcell else { return cell}
        
        wikiCell.updateCell(with: data, at: indexPath)
        
        return wikiCell
    }
    
    
}
extension MainView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
extension MainView : UISearchBarDelegate {
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

