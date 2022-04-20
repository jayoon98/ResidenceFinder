//
//  SearchView.swift
//  ResidenceFinder
//
//  Created by Jason Yoon on 2022-03-20.
//

import Foundation
import SwiftUI
import MapKit

struct SearchView : View {
    @StateObject private var viewModel = SearchView_ViewModel()
    @State private var showingDetail = false
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading){
                ZStack(alignment: .top) {
                    mapView
                    HStack(alignment: .top){
                        VStack(spacing: 3) {
                            TextField(
                                "Search by City",
                                text: $viewModel.textInput,
                                onEditingChanged: { start in
                                    viewModel.hideDropDown = false
                                    if(!start){
                                        viewModel.hideDropDown = true
                                        viewModel.searchTapped()
                                    }
                                }
                            )
                            .frame(width: 200, height: 44)
                            .padding(.horizontal, 15)
                            .background(.white)
                            .cornerRadius(5)
                            .opacity(0.95)
                            .shadow(radius: 5.5)
                            .padding(.top, geo.size.height*0.05)
                            
                            ScrollView{
                                ForEach(viewModel.greaterVanCities, id: \.self){ city in
                                    if(viewModel.matchesInput(currCity: city)){
                                        HStack(alignment: .center, spacing: 0){
                                            let cityNames = viewModel.dividedStr(currCity: city)
                                            
                                            Text("\(cityNames[0])")                                            .font(.title3)
                                                .foregroundColor(.orange)
                                            
                                            Text("\(cityNames[1])")
                                                .font(.title3)
                                                .foregroundColor(.gray)
                                            Spacer()
                                        }
                                        .padding(.top, 2)
                                        .onTapGesture(){
                                            viewModel.textInput = city.name
                                        }
                                    }
                                    
                                }
                                
                            }
                            .frame(width: 200, height: 35)
                            .padding(.top, 5)
                            .padding(.horizontal, 15)
                            .background(.white)
                            .cornerRadius(5)
                            .opacity(0.95)
                            .shadow(radius: 5.5)
                            .opacity((viewModel.hideDropDown || !viewModel.hasMatchingCity()) ? 0 : 1)
                            
                            Spacer()
                        }
                        
                        
                        ZStack {
                            
                            Image("filter")
                                .resizable()
                                .scaledToFit()
                                .frame(width:35, height: 35)
                        }
                        .frame(width:44, height: 44)
                        .background(.white)
                        .cornerRadius(10)
                        .opacity(0.95)
                        .shadow(radius: 5.5)
                        .onTapGesture(){
                            showingDetail = true
                        }
                        .sheet(isPresented: $showingDetail){
                            detailSearchView(viewModel: viewModel)
                        }
                        .padding(.top, geo.size.height*0.05)
                        
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height*3/7, alignment: .center)
                
                ScrollView{
                    ScrollViewReader { (proxy: ScrollViewProxy) in
                        LazyVStack(spacing: 10){
                            ForEach(Array(viewModel.responsedLocations.enumerated()), id: \.offset){ i, location in
                                if(!viewModel.checkForNil(loc: location)){
                                    HStack(spacing: 10) {
                                        
                                        let img = viewModel.getFromCache(zpid: location.zpid)
                                        if(img == nil){
                                            ProgressView()
                                                .frame(width: geo.size.width * 0.4, height: geo.size.height*2/7-30, alignment: .center)
                                                .clipped()
                                                .cornerRadius(10)
                                                .padding(.leading, 20)
                                                .shadow(radius: 10)
                                        }
                                        else {
                                            img
                                                .frame(width: geo.size.width * 0.4, height: geo.size.height*2/7-30, alignment: .center)
                                                .clipped()
                                                .cornerRadius(10)
                                                .padding(.leading, 20)
                                                .shadow(radius: 10)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("$\(location.price)")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .padding(.top, 15)
                                            
                                            HStack(alignment: .center, spacing: 0){
                                                Image("bed")
                                                    .imageIconWithinCell()
                                                
                                                Text("Beds: \(location.bedrooms!)")
                                                    .text_SearchView_cell_text()
                                                    .padding(.trailing, 10)
                                                
                                                Image("bath")
                                                    .imageIconWithinCell()
                                                
                                                Text("Bath: \(location.bathrooms!)")
                                                    .text_SearchView_cell_text()
                                            }
                                            if(location.livingArea != nil){
                                                HStack(alignment: .center, spacing: 0){
                                                    Image("size")
                                                        .imageIconWithinCell()
                                                    
                                                    
                                                    Text("\(location.livingArea!) \(location.lotAreaUnit!)")
                                                        .text_SearchView_cell_text()
                                                }
                                            }
                                            Text(location.address)
                                                .font(.body)
                                                .text_SearchView_cell_text()
                                            
                                            
                                            
                                            Spacer()
                                        }
                                        .padding(.leading, 10)
                                        
                                        Spacer()
                                        
                                    }
                                    .frame(width: geo.size.width, height: geo.size.height*2/7, alignment: .center)
                                    .id(i)
                                    .onTapGesture {
                                        viewModel.locationCellTapped(loc: location)
                                    }
                                    
                                    
                                    
                                    // Dotted line to separate each cell
                                    Line()
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                        .foregroundColor(.gray)
                                        .frame(height: 2)
                                }
                            }
                            if(viewModel.imgIsLoading){
                                HStack {
                                    ProgressView()
                                        .frame(width: geo.size.height*2/7-30, height: geo.size.height*2/7-30, alignment: .center)
                                        .clipped()
                                        .cornerRadius(10)
                                        .padding(.leading, 20)
                                        .shadow(radius: 10)
                                }
                                
                                Line()
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    .foregroundColor(.gray)
                                    .frame(height: 2)
                                
                                HStack {
                                    ProgressView()
                                        .frame(width: geo.size.height*2/7-30, height: geo.size.height*2/7-30, alignment: .center)
                                        .clipped()
                                        .cornerRadius(10)
                                        .padding(.leading, 20)
                                        .shadow(radius: 10)
                                }
                                
                                Line()
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    .foregroundColor(.gray)
                                    .frame(height: 2)
                                
                            }
                            else if(viewModel.responsedLocations.isEmpty){
                                HStack {
                                    Text("No result, please adjust the filter")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                }
                                .frame(width: geo.size.width, height: geo.size.height*4/7)
                            }
                        }
                        .onChange(of: viewModel.scrollTarget){ target in
                            if let target = target {
                                withAnimation {
                                    proxy.scrollTo(target, anchor: .center)
                                }
                            }
                            
                        }
                    }
                    
                }.frame(width: geo.size.width, height: geo.size.height*4/7, alignment: .center)
            }
            .navigationBarHidden(true)
            .onAppear(){
                // Setting the slider max value to fit the frame
                viewModel.option.sliderVal.max_Value = geo.size.width - 50
                viewModel.option.sliderVal.max_SliderValue = geo.size.width - 50
                print(viewModel.option.sliderVal.max_Value)
            }
            
        }
        
        
    }
    
    
    private var mapView : some View {
        Map(coordinateRegion: $viewModel.mapRegion, annotationItems: $viewModel.responsedLocations){ $location in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude ?? -4, longitude: location.longitude ?? -4)) {
                if(!viewModel.checkForNil(loc: location)){
                    
                    // Map Marker for each location
                    HStack{
                        /*Image(viewModel.mapMarker(loc: location))
                         .resizable()
                         .frame(width: 33, height: 33)*/
                        
                        Text(viewModel.shortenPrice(price: location.price))
                            .font(.body)
                            .fontWeight(.bold)
                            .frame(height: 33)
                            .padding(.horizontal, 8)
                            .foregroundColor(.white)
                        
                    }
                    .background(viewModel.mapMakerColor(loc: location))
                    .cornerRadius(16)
                    .onTapGesture(){
                        viewModel.scrollToLocation(loc: location)
                    }
                    .shadow(radius: 3)
                    
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    
    
    struct detailSearchView: View {
        let viewModel : SearchView_ViewModel
        @Environment(\.dismiss) private var dismiss
        
        var body : some View {
            GeometryReader { geo_detail in
                VStack(alignment: .leading){
                    Group {
                        HStack {
                            Button("Cancel"){
                                dismiss()
                            }
                            .padding(.top, 20)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("Filtered Search")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top, 20)
                            
                        }
                        
                        HStack(alignment: .center){
                            
                            Text("Bedrooms")
                                .text_detailedSearch_subHeader()
                            
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        HStack {
                            ForEach(viewModel.bedBathOptions, id: \.self){ option in
                                
                                Text(option)
                                    .text_detailedSearch_slider_price(geo_detail)
                                    .background((viewModel.option.bedroom.elementsEqual(option)) ? .blue : Color(uiColor: UIColor.lightGray))
                                    .cornerRadius(10)
                                    .padding(.trailing, 8)
                                    .onTapGesture(){
                                        viewModel.option.bedroom = option
                                    }
                            }
                        }
                        
                        HStack(alignment: .center){
                            
                            Text("Bathrooms")
                                .text_detailedSearch_subHeader()
                            
                            Spacer()
                        }
                        
                        HStack {
                            ForEach(viewModel.bedBathOptions, id: \.self){ option in
                                
                                Text(option)
                                    .text_detailedSearch_slider_price(geo_detail)
                                    .background((viewModel.option.bathroom.elementsEqual(option)) ? .blue : Color(uiColor: UIColor.lightGray))
                                    .cornerRadius(10)
                                    .padding(.trailing, 8)
                                    .onTapGesture(){
                                        viewModel.option.bathroom = option
                                    }
                            }
                        }
                        
                        HStack(alignment: .center){
                            
                            Text("Price Range")
                                .text_detailedSearch_subHeader()
                            
                            Spacer()
                        }
                    }
                    
                    HStack{
                        VStack {
                            HStack {
                                ZStack(alignment: .leading) {
                                    
                                    Text("\(viewModel.shortenPrice(price: viewModel.option.sliderVal.sliderValToPrice(viewModel.option.sliderVal.min_Value)))")
                                        .fontWeight(.bold)
                                        .offset(x: viewModel.option.sliderVal.min_Value - 18)
                                    
                                    
                                    
                                    Text("\(viewModel.shortenPrice(price: viewModel.option.sliderVal.sliderValToPrice(viewModel.option.sliderVal.max_Value)))")
                                        .fontWeight(.bold)
                                        .offset(x: viewModel.option.sliderVal.max_Value + 15)
                                }
                                
                                Spacer()
                                
                            }
                            
                            GeometryReader{ geo in
                                ZStack(alignment: .leading){
                                    
                                    Rectangle()
                                        .fill(Color.black.opacity(0.20))
                                        .frame(height: 10)
                                        .offset()
                                    
                                    Rectangle()
                                        .fill(Color.blue)
                                        .frame(width: viewModel.option.sliderVal.max_Value - viewModel.option.sliderVal.min_Value + 10, height: 10)
                                        .offset(x: viewModel.option.sliderVal.min_Value + 15)
                                    
                                    HStack{
                                        
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width:30, height: 30)
                                            .offset(x: viewModel.option.sliderVal.min_Value - 15)
                                            .shadow(radius: 5)
                                            .gesture(
                                                DragGesture()
                                                    .onChanged({ (value) in
                                                        if(value.location.x >= -15 && value.location.x < viewModel.option.sliderVal.max_Value - 30){
                                                            viewModel.option.sliderVal.min_Value = value.location.x + 15
                                                        }
                                                    })
                                            )
                                        
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width:30, height: 30)
                                            .offset(x: viewModel.option.sliderVal.max_Value - 15)
                                            .shadow(radius: 5)
                                            .gesture(
                                                DragGesture()
                                                    .onChanged({ (value) in
                                                        if(value.location.x <= geo.size.width - 35 && value.location.x > viewModel.option.sliderVal.min_Value + 30){
                                                            viewModel.option.sliderVal.max_Value = value.location.x - 15
                                                        }
                                                    })
                                            )
                                        
                                        
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .frame(height: 50)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    HStack{
                        Text("Residence Type")
                            .text_detailedSearch_subHeader()
                    }
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(Array(viewModel.option.houseType.enumerated()), id: \.offset){ i, type in
                                Text("\(type.name)")
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .padding(10)
                                    .foregroundColor(.white)
                                    .background(type.selected ? .blue : .gray)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        viewModel.option.houseType[i].selected = !type.selected
                                    }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack{
                        Spacer()
                        
                        Text("Apply Filter")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(20)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(10)
                            .onTapGesture {
                                dismiss()
                                viewModel.applyFilterTapped()
                            }
                            .padding(15)
                    }
                        
                    
                }
                .padding(.horizontal, 15)
            }
        }
    }
}

struct SearchView_Preview: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}


extension Text {
    func text_SearchView_cell_text() -> some View {
        self
            .foregroundColor(Color(uiColor: UIColor.darkGray))
    }
    
    func text_detailedSearch_subHeader() -> some View {
        self
            .fontWeight(.bold)
            .font(.headline)
            .foregroundColor(.black).padding(.top, 20)
    }
    
    func text_detailedSearch_slider_price(_ geo : GeometryProxy) -> some View {
        self
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: geo.size.width/5, height: 50)
        
    }
}

extension Image {
    func imageIconWithinCell() -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: 25, height: 23, alignment: .trailing)
            .padding(.trailing, 5)
    }
}


struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width*0.1, y: 0))
        path.addLine(to: CGPoint(x: rect.width*0.9, y: 0))
        return path
    }
}
