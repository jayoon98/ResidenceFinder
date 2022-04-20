//
//  SearchView_viewModel.swift
//  ResidenceFinder
//
//  Created by Jason Yoon on 2022-03-20.
//

import Foundation
import MapKit
import SwiftUI
import UIKit

struct City : Hashable {
    var latitude : Double
    var longitutde : Double
    var name : String
}

struct SearchOptions {
    var bedroom = "All"
    var bathroom = "All"
    var cityName = "Vancouver"
    var houseType : [HouseTypeOption] = [
        HouseTypeOption("Condos"), HouseTypeOption("Houses"), HouseTypeOption("Townhomes")
    ]
    var sliderVal : SliderValue
}

struct HouseTypeOption : Hashable{
    var name : String
    var selected : Bool
    
    init(_ name : String){
        self.name = name
        selected = false
    }
}

struct SliderValue {
    var min_Value : CGFloat
    var max_Value : CGFloat
    var max_SliderValue : CGFloat = 1.0
    // constant max price
    let price_max : CGFloat = 5000000.0
    
    func sliderValToPrice(_ val : CGFloat) -> Int {
        return min(Int(price_max), Int(max(10000, Int(val * price_max / max_SliderValue))))
    }

}

final class SearchView_ViewModel: ObservableObject {
    @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    @Published var textInput = ""
    @Published var selectedLocation : Location? = nil
    @Published var responsedLocations = [Location]()
    @Published var scrollTarget: Int?
    @Published var hideDropDown = true
    @Published var option = SearchOptions(sliderVal: SliderValue(min_Value: 10, max_Value: 700))
    
    var imgIsLoading = false
    var api : APICall? = nil
    var selectedCity : City?
    var displayingCity : City?
    
    let bedBathOptions = ["All", "1", "2", "3+"]
    
    let greaterVanCities: [City] = [
        City(latitude: 49.2827, longitutde: -123.1207, name: "Vancouver"),
        City(latitude: 49.2488, longitutde: -122.9805, name: "Burnaby"),
        City(latitude: 49.1666, longitutde: -123.1336, name: "Richmond"),
        City(latitude: 49.3200, longitutde: -123.0724, name: "North Vancouver"),
        City(latitude: 49.2838, longitutde: -122.7932, name: "Coquitlam"),
        City(latitude: 49.1913, longitutde: -122.8490, name: "Surrey"),
        City(latitude: 49.0504, longitutde: -122.3045, name: "Abbotsford")
    ]
    
    var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100 // 100mb
        
        return cache
    }()
    
    init(){
        api = APICall(op: option)
        getAPICall()
        displayingCity = greaterVanCities[0]
        option.houseType[0].selected = true
    }
    
    func getAPICall(){
        imgIsLoading = true
        responsedLocations = []
        imageCache.removeAllObjects()
        // Cache all the images after the API Call
        api!.getProperty{(response) in
            if let response = response {
                self.responsedLocations = response.props
                for i in 0 ..< self.responsedLocations.count {
                    self.responsedLocations[i].scrollViewIndex = i
                }
                self.cacheAllTheImages()
            }
            else {
                self.responsedLocations = []
            }
            self.imgIsLoading = false
        }
    }
    
    func markerClicked( _ newLoc : Location){
        selectedLocation = newLoc
    }
    
    func shortenPrice( price : Int) -> String{
        var p = Double(price)
        
        if(p >= 1000000){
            p /= 1000000
            return String(round(Double(p) * 10) / 10.0) + "M"
        }
        
        else if(p >= 1000){
            p /= 1000
            return String(Int(p)) + "K"
        }
        
        return String(price)
    }
    
    func cacheImage(image: UIImage, zpid: String){
        //print("Image with zpid: \(zpid) was cached")
        imageCache.setObject(image, forKey: zpid as NSString)
    }
    
    func checkForNil(loc: Location) -> Bool{
        return (loc.longitude == nil || loc.latitude == nil || loc.bathrooms == nil || loc.bedrooms == nil)
    }
    
    func cacheAllTheImages(){
        for location in responsedLocations {
            if let imgsrc = location.imgSrc {
                guard let imageURL = URL(string: imgsrc) else {
                    print("Wrong URL")
                    return
                }
                
                DispatchQueue.global().async { [weak self] in
                        
                    var i = 1
                    if let data = try? Data(contentsOf: imageURL) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self!.cacheImage(image: image, zpid: location.zpid)
                                // This code is for refreshing the view as it is not automatically refreshing once it is downloaded.
                                if(i == 1){
                                    self!.textInput = ""
                                    i = 0
                                }
                            }
                        }
                    }
                    else {
                        print("Failed to fetch data from the url")
                    }
                }
            }
            else {
                print("nil url found in location")
            }
        }
        
    }
    
    func getFromCache(zpid: String) -> Image? {
        if let uiImage = imageCache.object(forKey: zpid as NSString){
            let img = Image(uiImage: uiImage)
            return img
        }
        //print("Failed to find a UIImage with zpid: \(zpid)")
        return nil
    }
    
    func mapMarker(loc : Location) -> String {
        return (selectedLocation != nil && loc == selectedLocation!) ? "mapMarker_Blue-60" : "mapMarker_Red-60"
    }
    
    func mapMakerColor(loc: Location) -> Color {
        return (selectedLocation != nil && loc == selectedLocation!) ? Color(red: 1, green: 0.4078, blue: 0.3294) : Color(red: 0.2784, green: 0.5098, blue: 1)
    }
    
    func setScrollViewIndex(i : Int){
        responsedLocations[i].scrollViewIndex = i
    }
    
    func scrollToLocation( loc: Location) {
        markerClicked(loc)
        scrollTarget = loc.scrollViewIndex
    }
    
    func locationCellTapped(loc : Location){
        selectedLocation = loc
        mapRegion =  MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: loc.latitude!, longitude: loc.longitude!), span: mapRegion.span)
    }
    
    func searchTapped() {
        if let currCity = selectedCity {
            
            displayingCity = currCity
            api!.setOptions(option: option, selectedCity: selectedCity!)
            getAPICall()
            mapRegion =  MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: currCity.latitude, longitude: currCity.longitutde), span: mapRegion.span)
        }
    }
    
    func applyFilterTapped() {
        selectedCity = displayingCity
        searchTapped()
    }
    
    func matchesInput(currCity : City) -> Bool {
        if(indexOfMatchedStr(currCity: currCity) != 0){
            return true
        }
        return false
    }
    
    func hasMatchingCity() -> Bool{
        for city in greaterVanCities {
            if(matchesInput(currCity: city)){
                selectedCity = city
                return true
            }
        }
        selectedCity = nil
        return false
    }
    
    // returns the index of matching string
    func indexOfMatchedStr(currCity: City) -> Int {
        if(currCity.name.count < textInput.count || textInput.count == 0){
            return 0
        }
        let aryStr = Array(currCity.name)
        for (i,char) in textInput.enumerated() {
            if(aryStr[i] != char){
                return i
            }
        }
        
        return textInput.count
    }
    
    func dividedStr(currCity: City) -> [String] {
        
        var ary = ["", ""]
        let name = currCity.name
        let i = indexOfMatchedStr(currCity: currCity)
        
        let start = name.index(name.startIndex, offsetBy: i)
        
        let firstRange = name.startIndex..<start
        ary[0] = String(name[firstRange])
        
        let secondRange = start..<name.endIndex
        ary[1] = String(name[secondRange])
        
        return ary
    }
}
