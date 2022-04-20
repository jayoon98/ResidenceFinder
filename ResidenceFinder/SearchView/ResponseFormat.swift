//
//  ResponseFormat.swift
//  ResidenceFinder
//
//  Created by Jason Yoon on 2022-03-20.
//

import Foundation

struct SearchResult : Decodable {
    var props : [Location]
    var resultsPerPage : Int?
    var totalResultCount : Int?
    var totalPages : Int?
}

struct Location : Decodable, Equatable {
    var address : String
    var bathrooms : Int?
    var bedrooms :Int?
    var country : String
    var currency :String
    var daysOnZillow : Int
    //var hasImage : Bool?
    var imgSrc : String?
    var listingDateTime : Int?
    var livingArea : Int?
    var lotAreaUnit: String?
    var longitude : Double?
    var latitude : Double?
    var price : Int
    var zpid : String
    var propertyType : String
    var scrollViewIndex : Int?

    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.zpid == rhs.zpid
    }
}

extension Location: Identifiable {
    var id: Int { return Int(zpid)!}
}
