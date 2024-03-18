//
//  ViewController.swift
//  Lab7
//
//  Created by user240208 on 03/16/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
       @IBOutlet weak var startBtn: UIButton!
       
       @IBOutlet weak var stopBtn: UIButton!
       
       @IBOutlet weak var speedLbl: UILabel!
       
       @IBOutlet weak var maxSpeedLbl: UILabel!
       
       @IBOutlet weak var averageSpeedLbl: UILabel!
       
       @IBOutlet weak var distanceLbl: UILabel!
       
       @IBOutlet weak var maxAccelerationLbl: UILabel!
       
       @IBOutlet weak var topBarlbl: UILabel!
       
       @IBOutlet weak var bottomBarlbl: UILabel!
       
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var tripStarted = false
    var tripStartTime: Date?
    var currentSpeed: CLLocationSpeed = 0.0
    var maxSpeed: CLLocationSpeed = 0.0
    var totalDistance: CLLocationDistance = 0.0
    var maxAcceleration: Double = 0.0
    var previousLocation: CLLocation?
    var speeds: [CLLocationSpeed] = []
    var lastSpeed: CLLocationSpeed = 0.0
    var totaltripTime : TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupmapUI()
        setLocationManager()
    }
    
    func setupmapUI() {
        topBarlbl.backgroundColor = .gray
        bottomBarlbl.backgroundColor = .gray
        speedLbl.text = "0 km/h"
        maxSpeedLbl.text = "0 km/h"
        averageSpeedLbl.text = "0 km/h"
        distanceLbl.text = "0 km"
        maxAccelerationLbl.text = "0 m/s²"
    }
    func setLocationManager() {
        tripStarted = false
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func StartBtn(_ sender: Any) {
        locationManager.requestAlwaysAuthorization()
        tripStarted = true
        tripStartTime = Date()
        totaltripTime = 0
        startUpdatingmapLocation()
    }
    
    @IBAction func StopBtn(_ sender: Any) {
        tripStarted = false
        stopUpdatingmapLocation()
        updateTrip()
        bottomBarlbl.backgroundColor = .gray
        currentSpeed = 0.0
        maxSpeed = 0.0
        totalDistance = 0.0
        maxAcceleration = 0.0
        speeds = []
        previousLocation = nil
        updatemapUI()
    }
    
    func startUpdatingmapLocation() {
        locationManager.startUpdatingLocation()
        speeds = []
        previousLocation = nil
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        bottomBarlbl.backgroundColor = .green
    }
    
    
    func stopUpdatingmapLocation() {
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
    }
    
    func updatemapUI() {
        speedLbl.text = String(format: "%.1f km/h", currentSpeed * 3.6)
        maxSpeedLbl.text = String(format: "%.1f km/h", maxSpeed * 3.6)
        averageSpeedLbl.text = speeds.isEmpty ? "0 km/h" : String(format: "%.1f km/h", (speeds.reduce(0, +) / Double(speeds.count)) * 3.6)
        distanceLbl.text = String(format: "%.1f km", totalDistance / 1000)
        maxAccelerationLbl.text = String(format: "%.2f m/s²", maxAcceleration)
        
        topBarlbl.backgroundColor = (currentSpeed * 3.6 > 115) ? .red : .gray
        let  averageSpeed = totaltripTime > 0 ? totalDistance/totaltripTime :0
        averageSpeedLbl.text = String(format :"%1f km/h", averageSpeed*3.6)
    }
    
    func updateTrip() {
        let totalTime = tripStartTime != nil ? Date().timeIntervalSince(tripStartTime!) : 0
        let averageSpeed = totalTime > 0 ? totalDistance / totalTime :0
        var previousSpeed = 0.0
        var accelerations: [Double] = []
        for speed in speeds {
            let acceleration = (speed - previousSpeed) / (totalTime / Double(speeds.count))
            accelerations.append(acceleration)
            previousSpeed = speed
        }
        maxAcceleration = accelerations.max() ?? 0.0
        
        averageSpeedLbl.text = String(format: "%.1f km/h", averageSpeed * 3.6)
        maxAccelerationLbl.text = String(format: "%.2f m/s²", maxAcceleration)
        
        speeds = []
        totalDistance = 0.0
        maxSpeed = 0.0
        tripStartTime = nil
    }
}

extension ViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, tripStarted else { return }
        
        let speed = location.speed >= 0 ? location.speed : 0
        currentSpeed = speed
        maxSpeed = max(maxSpeed, currentSpeed)
        if let tripStart = tripStartTime{
            totaltripTime = Date().timeIntervalSince(tripStart)
        }
        
        if let previousLocation = previousLocation {
            let timeInterval = location.timestamp.timeIntervalSince(previousLocation.timestamp)
            if timeInterval > 0 {
                let acceleration = abs(speed - lastSpeed) / timeInterval
                maxAcceleration = max(maxAcceleration, acceleration)
                let distance = location.distance(from: previousLocation)
                totalDistance += distance
            }
        }

        lastSpeed = speed
        previousLocation = location

        let averageSpeed = totaltripTime > 0 ? totalDistance/totaltripTime : 0
        averageSpeedLbl.text = String(format :"%1f km/h", averageSpeed*3.6)
        
        updatemapUI()
    }
}

