//
//  WikiNetworking.swift
//  WikiSearch
//
//  Created by saif ahmed on 14/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import Foundation
import Foundation
import RxSwift
import Moya
import RxCocoa
class WikiNetworking {
    private var provider: MoyaProvider<WikiEndpoint>?
    private let disposeBag = DisposeBag()
    
    public func request(_ endpoint: WikiEndpoint, manager: Session = MoyaProvider<WikiEndpoint>.defaultAlamofireSession()) -> Single<Response> {
        
        let endpointClosure = { (target: TargetType) -> Endpoint in
            
            let url = target.baseURL.appendingPathComponent(target.path)
            let sampleResponse: Endpoint.SampleResponseClosure = { return .networkResponse(200, target.sampleData) }
            let headers = target.headers ?? [String: String]()
            
            let endpoint = Endpoint(url: url.absoluteString,
                                    sampleResponseClosure: sampleResponse,
                                    method: target.method,
                                    task: target.task,
                                    httpHeaderFields: headers)
            print(try? endpoint.urlRequest())
            
            return endpoint
        }
        
        let endpointProvider = MoyaProvider<WikiEndpoint>(endpointClosure: endpointClosure, session: manager)
        provider = endpointProvider
        
        return endpointProvider.rx.request(endpoint)
            .do(onSuccess : {response in
                print(response)
            },onError: { error in
                print(error)
            })
    }
    
}
