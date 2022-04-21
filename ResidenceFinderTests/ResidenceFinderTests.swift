//
//  ResidenceFinderTests.swift
//  ResidenceFinderTests
//
//  Created by Jason Yoon on 2022-03-20.
//

import XCTest
@testable import ResidenceFinder

class ResidenceFinderTests: XCTestCase {
    
    var sviewModel : SearchView_ViewModel!
    
    override func setUp(){
        super.setUp()
        sviewModel = SearchView_ViewModel()
    }
    
    override func tearDown() {
        sviewModel = nil
        super.tearDown()
    }
    
    func test_check_for_nil() throws {
        let testLocation1 = Location(address: "", bathrooms: 2, bedrooms: 3, country: "Canada", currency: "CAD", daysOnZillow: -1, longitude: 1.1, latitude: -1.1, price: 0, zpid: "123", propertyType: "Condos")
        
        let testLocation2 = Location(address: "", bathrooms: 2, bedrooms: 3, country: "Canada", currency: "CAD", daysOnZillow: -1, longitude: nil, latitude: -1.1, price: 0, zpid: "123", propertyType: "Condos")
        
        XCTAssertEqual(sviewModel.checkForNil(loc: testLocation1), false)
        XCTAssertEqual(sviewModel.checkForNil(loc: testLocation2), true)
    }
    
    func test_matches_Input() throws {
        XCTAssertEqual(sviewModel.matchesInput(cityName: "Vancouver", input: "Van"), true)
        XCTAssertEqual(sviewModel.matchesInput(cityName: "North Vancouver", input: "N"), true)
        XCTAssertEqual(sviewModel.matchesInput(cityName: "North Vancouver", input: "Burnaby"), false)
    }
}
