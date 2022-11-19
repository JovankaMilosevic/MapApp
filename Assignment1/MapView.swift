//
//  MapView.swift
//  Assignment1
//
//  Created by Jovanka Milosevic on 2022-11-02.
//  Email: milosevj@sheridancollege.ca
//
//  Description: This is struct to host MKMapView. It is used to create and update map view.
//               Also, here we are setting how the map will look and draw the polyline overlay.
//

import SwiftUI
import MapKit
import CoreLocation

// wrapper to host MKMapView in SwiftUI
struct MapView: UIViewRepresentable
{
    // properties
    @ObservedObject var locationManager: LocationManager
    var annotations: [MKAnnotation]
    var spanKm = 1.0
    let mapType: MKMapType
    var selectedRoute: MKRoute?
    

    // return instance of UIView
    func makeUIView(context: Context) -> MKMapView
    {
        let mapView = MKMapView()
        //configure the map
        mapView.showsUserLocation = true
        mapView.mapType = mapType
        mapView.showsScale = false
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: [.school, .university, .publicTransport])
        
        let scale = MKScaleView(mapView: mapView)
        scale.scaleVisibility = .visible
        scale.frame.origin = CGPoint(x: 220, y: 30)
        scale.tintColor = .blue
        mapView.addSubview(scale)
        
        let compassBtn = MKCompassButton(mapView: mapView)
        compassBtn.frame.origin = CGPoint(x: 30, y: 20)
        compassBtn.compassVisibility = .visible
        mapView.addSubview(compassBtn)
        
        //set delegate (to draw a path)
        mapView.delegate = context.coordinator

        return mapView
    }
    
    // update UIView
    func updateUIView(_ uiView: MKMapView, context: Context)
    {
        print("updateUIView")
        print("Route in MapView: \(String(describing: selectedRoute?.name))")
        for annotation in annotations {
            print("Annotation MapView: \(String(describing: annotation.coordinate))")
        }
        updateMap(uiView)
    }

    // create coordinator
    func makeCoordinator() -> MapViewCoordinator
    {
        return MapViewCoordinator(self)
    }

    func updateMap(_ uiView: MKMapView)
    {
        uiView.mapType = mapType
        // display the current user location if userTracking is on
        if locationManager.userTracking
        {
            let coord = locationManager.location.coordinate
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            let span = MKCoordinateSpan(latitudeDelta: spanKm/111.11, longitudeDelta: spanKm/111.11)
            let region = MKCoordinateRegion(center: center, span: span)
            uiView.mapType = mapType
            uiView.setRegion(region, animated: true)
        }
        // display the pin annotations if exists
        else
        {
            uiView.removeAnnotations(uiView.annotations) //remove prev for annotation in annotations
            for annotation in annotations
            {
                uiView.addAnnotation(annotation)
                print("Annotation MapView for loop update \(String(describing: annotation.title))")
            }
            
            if let route = selectedRoute {
                let overlays = uiView.overlays
                uiView.removeOverlays(overlays)
                uiView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
                uiView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20), animated: true)
            }
        }
    }
}


// coordinator (delegate) to communicate with SwiftUI
class MapViewCoordinator: NSObject, MKMapViewDelegate
{
    // properties
    let mapView: MapView

    init(_ mapView: MapView) {
        self.mapView = mapView
    }
    
    // delegates for MKMapViewDelegate
    // It is used to draw polyline overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        //TODO: add for polyline overlay
        if let polyline = overlay as? MKPolyline
        {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay:overlay)
    }
}

