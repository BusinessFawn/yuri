//
//  FirstViewController.swift
//  yuri
//
//  Created by John Konderla on 5/20/17.
//  Copyright © 2017 John Konderla. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Foundation

class FirstViewController: UIViewController {
    
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    let baseURL = "http://dev.4tay.xyz:8080/yuri/api/location"
    
    
    var locationArray: Array<Any> = []
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    // Update the map once the user has made their selection.
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        // Clear the map.
        mapView.clear()
        
        // Add a marker to the map.
        if selectedPlace != nil {
            let marker = GMSMarker(position: (self.selectedPlace?.coordinate)!)
            marker.title = selectedPlace?.name
            marker.snippet = selectedPlace?.formattedAddress
            marker.map = mapView
        }
        
        //listLikelyPlaces()
    }
    
    @IBAction func sendLocation(_ sender: Any) {
        
        //print(locationManager.location ?? defaultLocation)
        
        //print(locationManager.location?.coordinate ?? defaultLocation)
        let lat = locationManager.location?.coordinate.latitude
        print(lat ?? "no lat")
        let lng = locationManager.location?.coordinate.longitude
        print(lng ?? "no lng")
        //let dtime = locationManager.location?.timestamp
        
        
        let post = (baseURL + "?lng="+(lng?.description)!+"&lat="+(lat?.description)!+"&id=12&checkinID=120")
        print(post)
        let postURL = URL(string: post)
        
        var request:URLRequest = URLRequest(url:postURL!)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with:request) { (data, response, error) in
            if error != nil {
                print("error:",error.debugDescription)
            } else {
                //print("response:",response.)
            }
        }.resume()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        let mapInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        mapView.padding = mapInsets
        
        
        

        
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
        
        let urlString = "http://dev.4tay.xyz:8080/yuri/api/location?range=.01&lng=-78.650543&lat=35.780899"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error ?? "random other error....")
            } else {
                var locationArray = [[String: Any]]()
                
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let locations = json["locations"] as? [[String: Any]] {
                        for location in locations {
                            var locationDict: [String: Any] = [:]
                            if let lat = location["lat"] as? Float {
                                locationDict["lat"] = lat
                            }
                            if let lng = location["lng"] as? Float {
                                locationDict["lng"] = lng
                            }
                            if let id = location["checkinID"] as? Int {
                                locationDict["checkinID"] = id
                            }
                            
                            locationArray.append(locationDict)
                        }
                    }
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                self.updateMapWithLocations(array: locationArray)
            }
            
            }.resume()
    }
    
    func updateMapWithLocations(array: [[String: Any]]) {
        DispatchQueue.main.async {
            self.mapView.addSubview(self.makeSendLocation(text: "👍"))
            for local in array {
                if let lat = local["lat"] as? Float{
                    let lng = local["lng"] as? Float ?? 12.00
                    let id = local["checkinID"] as? Int ?? 101101
                    print("checkinID:", id, "lat:", lat, "lng:", lng)
                    
                    //Have to call this on the main thread....
                    let positions = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
                    let marker = GMSMarker(position: positions)
                    marker.map = self.mapView
                    
                }
            }
        }
    }
    
    func makeSendLocation(text:String) -> UIButton {
        let locationButton = UIButton(type: UIButtonType.system)
        locationButton.frame = CGRect(x: view.frame.size.width-(locationButton.frame.size.width+60), y: view.frame.size.height-(locationButton.frame.size.height+100), width: 45, height: 45)
        locationButton.backgroundColor = UIColor.blue
        locationButton.setTitle(text, for: .normal)
        locationButton.setTitleColor(UIColor.white, for: .normal)
        locationButton.setTitle("👏", for: .highlighted)
        locationButton.setTitleColor(UIColor.orange, for: .highlighted)
        locationButton.addTarget(self, action: #selector(sendLocation), for: .touchUpInside)
        return locationButton
        
    }
}

// Delegates to handle events for the location manager.
extension FirstViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        //listLikelyPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
