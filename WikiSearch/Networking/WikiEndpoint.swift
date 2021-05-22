//
//  WikiEndpoint.swift
//  WikiSearch
//
//  Created by saif ahmed on 14/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import Foundation
import Moya
enum WikiEndpoint  {
    
    case searchImages(text : String) // TO DO :- Need to add offset here and fetch results from that offset
    case fetchFullURL(pageID : Int)
    
    
}
extension WikiEndpoint : TargetType {
    var baseURL: URL {
        guard let url = URL(string: "https://en.wikipedia.org/w/api.php") else {
            fatalError("URL needs to be set")
        }
        return url
        
    }
    
    var path: String {
        switch self {
        case .searchImages, .fetchFullURL : return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchImages,.fetchFullURL : return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .searchImages(let text) :
            let params = WikiSearchImageParams(gpssearch: text)
            return .requestParameters(parameters: params.encodeToParameters(), encoding: URLEncoding())
    
        case .fetchFullURL(let pageID):
            let params = WikiFetchURLParams(pageids: pageID)
            return .requestParameters(parameters: params.encodeToParameters(), encoding: URLEncoding())
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}

struct WikiSearchImageParams {
    
    var action = "query"
    var format = "json"
    var prop = "pageimages|pageterms"
    var generator = "prefixsearch"
    var formatVersion = "2"
    var piprop = "thumbnail"
    var pithumbsize = "50"
    var pilimit = "18"
    var wbptterms = "description"
    var gpssearch : String
    var gpslimit = "18"
    var offset : Int?
    

    enum ParamKeys : String {
        case action
        case format
        case prop
        case generator
        case formatVersion = "formatversion"
        case piprop
        case pithumbsize
        case pilimit
        case wbptterms
        case gpssearch
        case gpslimit
        case offset = "gpsoffset"
        
        
    }
    func encodeToParameters() -> [String : Any] {
        let params = [ParamKeys.action.rawValue : action, ParamKeys.format.rawValue : format, ParamKeys.prop.rawValue : prop,ParamKeys.generator.rawValue : generator,
                      ParamKeys.formatVersion.rawValue : formatVersion,ParamKeys.piprop.rawValue : piprop,ParamKeys.pithumbsize.rawValue : pithumbsize,ParamKeys.pilimit.rawValue : pilimit,ParamKeys.wbptterms.rawValue : wbptterms,ParamKeys.gpssearch.rawValue : gpssearch,ParamKeys.gpslimit.rawValue : gpslimit]
//        if let offset = offset {
//            params[ParamKeys.offset.rawValue] = String(offset)
//
//        }
        // Need to set the offset when more results are required
        return params
    }
}



struct WikiFetchURLParams {
    var action = "query"
    var format = "json"
    var prop = "info"
    var pageids : Int
    var inprop = "url"
    var formatVersion = "2"
    
    enum ParamKeys : String {
        case action
        case format
        case prop
        case pageids
        case inprop
        case formatVersion = "formatversion"
    }
    func encodeToParameters() -> [String : String] {
        let params = [ParamKeys.action.rawValue : action, ParamKeys.format.rawValue : format, ParamKeys.prop.rawValue : prop,ParamKeys.pageids.rawValue : String(pageids),ParamKeys.inprop.rawValue : inprop ,ParamKeys.formatVersion.rawValue : formatVersion]
        return params
    }
}
