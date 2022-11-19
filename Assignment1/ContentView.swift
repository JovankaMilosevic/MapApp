//
//  ContentView.swift
//  Assignment1
//
//  Created by Jovanka Milosevic on 2022-11-02.
//  Email: milosevj@sheridancollege.ca
//
//  Description: This is ContentView that hold main map view. It displays the map with current location
//  route. Additionaly, it has a compas and scale displayed at the top of the map, and a map type picker
//  at the bottom.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State var annotations: [MKAnnotation] = []
    @State var start: String = ""
    @State var destination: String = ""
    @State var allRoutes: [MKRoute] = []
    @State var selectedRoute: MKRoute? = MKRoute()
    @State private var mapType: MKMapType = .satellite
    
    
    var body: some View {
        NavigationView{
            ZStack{
                MapView(locationManager: locationManager, annotations: annotations, mapType: mapType, selectedRoute: selectedRoute)
                
                VStack{
                    Spacer()
                    Picker("", selection: $mapType){
                        Text("Standard").tag(MKMapType.standard)
                        Text("Satellite").tag(MKMapType.satellite)
                        Text("Hybrid").tag(MKMapType.hybrid)
                    }
                    .onAppear{
                        for annotation in annotations {
                            print("Annotation in ConstentView \(annotation.coordinate)")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(.gray)
                    .offset(y: -40)
                    .font(.largeTitle)
                }
            }
            .navigationTitle("Jo's Navigator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItemGroup( placement: .navigationBarTrailing)
                {
                    NavigationLink(destination: RouteView(locationManager: locationManager, annotations: $annotations, start: $start, destination: $destination, allRoutes: $allRoutes, selectedRoute: $selectedRoute)){
                        Text("Route")
                    } //go to RouteView
                }
            }
        }
    }
}

//The preview is not used, as we use simulator for displaying and testing map.
//If neaded, it can be used
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
