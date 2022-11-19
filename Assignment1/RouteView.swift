//
//  RouteView.swift
//  Assignment1
//
//  Created by Jovanka Milosevic on 2022-11-03.
//  Email: milosevj@sheridancollege.ca
//
//  Description: This is a struct to hold route view, in which we have two text fields for user to enter
//               start and destination, based on which route is calculated and displayed in the list.
//               Once a route is selected - clicked, the user will be transfered back to the main view -
//               content view that shows the map with the route they selected.


import SwiftUI
import CoreLocation
import MapKit

struct RouteView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var locationManager: LocationManager
    @Binding var annotations: [MKAnnotation]
    @Binding var start: String
    @Binding var destination: String
    @State var coordinates: [CLLocationCoordinate2D] = []
    @Binding var allRoutes: [MKRoute]
    @Binding var selectedRoute: MKRoute?
    @State var alertVisible = false
    
    var body: some View {
        NavigationView{
            VStack{
                HStack{
                    VStack{
                        HStack{
                            Text("From")
                            TextField("start", text: $start)
                        }
                        HStack{
                            Text("To")
                            TextField("destination", text: $destination)
                        }
                    }
                    .padding(2)
                    Button{
                        if start.isEmpty{
                            //find destination and set up annotations
                            forwardGeocoding(address: destination) { (location) in
                                guard let toLocation = location else{
                                    alertVisible = true //if there is no destination, show alert
                                    return
                                }
                                annotations.removeAll()
                                let pin1 = MKPointAnnotation()
                                pin1.coordinate = locationManager.location.coordinate
                                let pin2 = MKPointAnnotation()
                                pin2.coordinate = toLocation.coordinate
                                pin2.title = destination
                                pin2.subtitle = destination.description
                                annotations.append(pin1)
                                annotations.append(pin2)
                                print("Annotation 0: \(self.annotations[0].coordinate)")
                                route(fromLocation: locationManager.location, toLocation: toLocation)
                            }
                            //get name of the start location (current location) if it is not entered
                            reverseGeocoding(location: locationManager.location, completion: {(location) in
                                if let startLocation = location {
                                    start = startLocation.name ?? "Sheridan College Trafalgar"
                                }
                            })
                        } else{
                                //find source and set up annotations
                                forwardGeocoding(address: start){ (location) in
                                    guard let fromLocation = location else {
                                        alertVisible = true
                                        return
                                    }
                                    annotations.removeAll()
                                    let pin1 = MKPointAnnotation()
                                    pin1.coordinate = fromLocation.coordinate
                                    pin1.title = start
                                    pin1.subtitle = start.description
                                    annotations.append(pin1)
                                    //find destination
                                    forwardGeocoding(address: destination){ (location) in
                                        guard let toLocation = location else {
                                            alertVisible = true //if there is no destination, show alert
                                            return
                                        }
                                        let pin2 = MKPointAnnotation()
                                        pin2.coordinate = toLocation.coordinate
                                        pin2.title = destination
                                        pin2.subtitle = destination.description
                                        annotations.append(pin2)
                                        route(fromLocation: fromLocation, toLocation: toLocation)
                                    }
                                }
                            }
                    } label: {
                        Text("Route")
                    }
                }
                .alert("Please, check if locations are entered/correct.", isPresented: $alertVisible){
                    Button("OK", role: .cancel){}
                }
                .padding()
                VStack{
                    List(allRoutes, id:\.self, selection: $selectedRoute) {route in
                        let routeName = route.name
                        let routeTime = convertTravelTime(inputTime: route.expectedTravelTime)
                        let routeDistance = convertDistance(inputDistance: route.distance)
                        let routeInfo = "via \(routeName): \(routeDistance), \(routeTime)"
                        NavigationLink(routeInfo, destination: {
                            ContentView(annotations: annotations, start: start, destination: destination, allRoutes: allRoutes, selectedRoute: selectedRoute) //go to Content view and pass the data
                        }).onTapGesture {
                            self.selectedRoute = route
                            locationManager.userTracking = false
                            dismiss()
                        }
                    }.environment(\.editMode, .constant(.active))
                }
                .padding(2)
            }
        }
    }
    
    //calculate route from start and destination locations
    func route(fromLocation: CLLocation, toLocation: CLLocation){
        let fromPlace = MKPlacemark(coordinate: fromLocation.coordinate)
        let toPlace = MKPlacemark(coordinate: toLocation.coordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: fromPlace)
        request.destination = MKMapItem(placemark: toPlace)
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
      
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: {
            (response, error) in
            if let err = error {
                print("[ERROR]" + err.localizedDescription)
                return
            }

            if let routes = response?.routes {
                self.allRoutes = routes
                dump(routes) //debug
                print("Routes first \(allRoutes[0].name)")
            } else {
                alertVisible = true //if getting routes not successful, show alert
            }
        })
    }
}

// convert address String to CLLocation
func forwardGeocoding(address: String,
                      completion: @escaping((CLLocation?) -> Void))
{
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
        if let error = error
        {
            print(error.localizedDescription)
            completion(nil) // pass nil location if failed
        }
        else
        {
            // pass the first location to the closure
            completion(placemarks?[0].location)
        }
    })
}

// convert CLLocation to address string
func reverseGeocoding(location: CLLocation,
                      completion: @escaping((CLPlacemark?) -> Void))
{
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
        if let error = error
        {
            print(error.localizedDescription)
            completion(nil) // pass null placemark
        }
        else
        {
            // pass the first placemark
                completion(placemarks?[0])
        }
    })
}

//convert time in seconds as TimeInterval we get from the route object
func convertTravelTime(inputTime: TimeInterval) -> String {
    let time = Int(inputTime)
    let seconds = time % 60
    let minutes = time / 60 % 60
    let hours = time / 3600
    let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    return timeString
}

//convert distance in meters we get from the route object
func convertDistance(inputDistance: CLLocationDistance) -> String{
    let distance = Double(inputDistance)
    let kilometers = distance / 1000
    let distanceString = String(format: "%.1f", kilometers)
    return distanceString
}

// The preview is not used, as we use simulator for displaying and testing map.
//If neaded, default values for parameters can be added to the preview, so it will display the proper map.
//struct RouteView_Previews: PreviewProvider {
//    static var previews: some View {
//        RouteView()
//    }
//}
