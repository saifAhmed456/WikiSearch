//
//  WikiSearchResponse.swift
//  WikiSearch
//
//  Created by saif ahmed on 14/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import Foundation
struct WikiSearchResponse : Decodable {
    var query : WikiSearchItemList?
}
struct WikiSearchItemList : Decodable {
    var pages : [WikiSearchItem]?

    }

struct WikiSearchItem : Decodable {
    var title : String?
    var thumbnail : ThumbnailImageInfo?
    var terms : WikiTitleDescription?
    var fullurl : String?
    var pageid : Int? // TO DO :- handle cases where pageID exceeds INT range
}
struct ThumbnailImageInfo : Decodable {
    var source : String?
    
}
struct WikiTitleDescription : Decodable {
    var description : [String]?
    
}

