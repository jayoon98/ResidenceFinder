//
//  APICall.swift
//  ResidenceFinder
//
//  Created by Jason Yoon on 2022-03-24.
//

import Foundation
import SwiftUI

class APICall {
    var option : SearchOptions
    var cityName = "Vancouver"
    
    init(op : SearchOptions) {
        self.option = op
    }
    
    func setOptions(option : SearchOptions, selectedCity : City){
        if let cityName = selectedCity.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            self.cityName = cityName
        }
        self.option = option
    }
    
    func createURL() -> URL! {
        var houseTypeStr = ""
        var firstSelectedCity = true
        for type in option.houseType {
            if(type.selected) {
                if(firstSelectedCity){
                    firstSelectedCity = false
                    houseTypeStr = "&home_type=\(type.name)"
                }
                else {
                    houseTypeStr.append("%2C%20\(type.name)")
                }
            }
        }
        
        let minPrice = option.sliderVal.sliderValToPrice(option.sliderVal.min_Value)
        var minOption = ""
        if(!(minPrice == Int(option.sliderVal.price_max))){
            minOption = "&minPrice=\(minPrice)"
        }
        
        let maxPrice = option.sliderVal.sliderValToPrice(option.sliderVal.max_Value)
        var maxOption = ""
        if(!(maxPrice == Int(option.sliderVal.price_max))){
            maxOption = "&maxPrice=\(maxPrice)"
        }
        
        var bathOption = ""
        if(option.bathroom != "All"){
            if(option.bathroom.elementsEqual("3+")){
                bathOption = "&bathsMin=3"
            }
            else {
                bathOption = "&bathsMin=\(option.bathroom)&bathsMax=\(option.bathroom)"
            }
        }
        
        var bedOption = ""
        if(option.bedroom != "All"){
            if(option.bedroom.elementsEqual("3+")){
                bedOption = "&bedsMax=3"
            }
            else {
                bedOption = "&bedsMin=\(option.bedroom)&bedsMax=\(option.bedroom)"
            }
        }
        
        let strURL = "https://zillow-com1.p.rapidapi.com/propertyExtendedSearch?location=\(cityName)%2C%20bc\(houseTypeStr)\(minOption)\(maxOption)\(bathOption)\(bedOption)"
    
        print(strURL)
        guard let url = URL(string: strURL)
        else {
            print("Failed to convert to url with string: ")
            return nil
        }
        
        return url
    }
    
    func getProperty(completion: @escaping (SearchResult?) -> ()) {
        
        let headers = [
            "x-rapidapi-host": "zillow-com1.p.rapidapi.com",
            "x-rapidapi-key": "a3b73abe1fmshf45d4bed2d31439p125211jsn8f154e875973"
        ]
        
        guard let url = createURL()
        else {
            return print("Wrong URL")
        }
        
        let request = NSMutableURLRequest(url: url,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            do {

                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let data = data {
                        let responseJson = try JSONDecoder().decode(SearchResult.self, from: data)
                        
                        DispatchQueue.main.async {
                            completion(responseJson)
                        }
                    }
                }
            } catch let blockError {
                print(blockError)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }).resume()
    }
}
