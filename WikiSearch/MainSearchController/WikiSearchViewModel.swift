//
//  WikiSearchViewModel.swift
//  WikiSearch
//
//  Created by saif ahmed on 14/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

protocol WikiSearchFlowCoordinating {
    func gotoWebView(with url : String)
}
struct TableViewCellData : TableViewCellDataSourceProtocol {
   
    var imageURL: URL?
    
    var primaryDescription: String?
    
    var secondaryDescription: String?
    
    init(searchItem : WikiSearchItem?) {
        primaryDescription = searchItem?.title
        secondaryDescription = searchItem?.terms?.description?.first
        if let urlString = searchItem?.thumbnail?.source {
            imageURL = URL(string: urlString)
        }
        
    }
}

class WikiSearchViewModel {
    var networking = WikiNetworking()
    var disposeBag = DisposeBag()
    var searchTextRelay = BehaviorRelay<String?>(value: nil)
    var reload = BehaviorRelay<CurrentSearchStatus>(value : .searchTextEmpty)
    var searchItemsRelay = BehaviorRelay<[WikiSearchItem]?>(value: nil)
    var indexPathSelected = PublishSubject<IndexPath>()
    var animateSpinner = PublishSubject<Bool>()
    var flowCoordinator : WikiSearchFlowCoordinating
    init(flowCoordinator : WikiSearchFlowCoordinating) {
        self.flowCoordinator = flowCoordinator
        setupBindings()
    }
    func setupBindings() {
        searchTextRelay
            .unwrap()
            .distinctUntilChanged()
            .flatMapLatest {[weak self] text -> Observable<[WikiSearchItem]?> in
                self?.animateSpinner.onNext(!text.isEmpty)
                guard let `self` = self, !text.isEmpty else { return Observable.of(nil) }
                let searchEndpoint = WikiEndpoint.searchImages(text: text)
                return self.networking.request(searchEndpoint)
                    .do(onDispose: {[weak self] () in
                        self?.animateSpinner.onNext(false)
                        
                    })
                    .map(WikiSearchResponse.self)
                    .map{$0.query?.pages ?? []}
                    .asObservable()
        }
        .bind(to: searchItemsRelay)
        .disposed(by: disposeBag)
        
        indexPathSelected.withLatestFrom(searchItemsRelay,resultSelector: {(indexpath,searchList) -> Int? in
            guard indexpath.row < (searchList?.count ?? 0) else { return nil}
            return searchList?[indexpath.row].pageid
        })
            .unwrap()
            .flatMapLatest({[weak self] (pageID) -> Observable<String?> in
                guard let `self` = self else { return .empty() }
                self.animateSpinner.onNext(true)
                let fetchFullURLEndpoint = WikiEndpoint.fetchFullURL(pageID: pageID)
                return self.networking.request(fetchFullURLEndpoint)
                    .do(onDispose: {[weak self] () in
                        self?.animateSpinner.onNext(false)
                        
                    })
                    .map(WikiSearchResponse.self)
                    .map { (searchResponse) -> String? in
                        return  searchResponse.query?.pages?.first?.fullurl
                }.asObservable()
            })
            .unwrap()
            .subscribe(onNext : {[weak self] urlString in
                self?.flowCoordinator.gotoWebView(with: urlString)
            }).disposed(by : disposeBag)
        
        searchItemsRelay
            .map {[weak self] (itemsList) -> CurrentSearchStatus in
                return self?.searchStatus(for: itemsList) ?? .searchTextEmpty
        }.bind(to: reload)
            .disposed(by: disposeBag)
        
        
    }
    func searchStatus(for searchResultList : [WikiSearchItem]?) -> CurrentSearchStatus {
        guard searchResultList != nil else { return .searchTextEmpty }
        return searchResultList!.isEmpty ? .noResults : .someResults
    }
    func setupBindings(with view : ViewControllerProtocol) {
        view.dataSource.accept(self)
        
        view.indexPathSelected
            .bind(to: indexPathSelected)
            .disposed(by: disposeBag)
        
        view.searchBarText
            .bind(to: searchTextRelay)
            .disposed(by: disposeBag)
        
        animateSpinner
            .bind(to: view.animateSpinner)
            .disposed(by : disposeBag)
        
    }
}
extension WikiSearchViewModel : TableViewDataSourceProtocol {
    var numOfSections: Int {
        return 1
    }
    
    func numOfItems(in section: Int) -> Int {
        return searchItemsRelay.value?.count ?? 0
    }
    
    func item(for indexPath: IndexPath) -> TableViewCellDataSourceProtocol? {
        guard indexPath.row < (searchItemsRelay.value?.count ?? 0) else { return nil }
        return TableViewCellData(searchItem: searchItemsRelay.value?[indexPath.row])
    }
    
    
    
}
