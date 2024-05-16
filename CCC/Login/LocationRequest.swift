//
//  LocationRequest.swift
//  CCC
//
//  Created by Truk Karawawattana on 30/4/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import CoreLocation

class LocationRequest: UIViewController {
    
    var emailFormLogin: String?
    
    var locationManager: CLLocationManager!

    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("LOCATION REQUEST")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 5.0 //minimun distance to update in meters
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            print("Location allow")
        }
        else if status == .notDetermined {
            print("Location ?")
        }
        else {
            print("Location not allow")
            locationManager.stopUpdatingLocation()
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Register_2") as! Register_2
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - CLLocation Delegate
extension LocationRequest: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        //print("Location: \(location)")
        print("Lat: \(location.coordinate.latitude)")
        print("Long: \(location.coordinate.longitude)")
        
        SceneDelegate.GlobalVariables.userLat = location.coordinate.latitude.description
        SceneDelegate.GlobalVariables.userLong = location.coordinate.longitude.description
        
        saveLocation()
    }
    
    func saveLocation() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "latitude":SceneDelegate.GlobalVariables.userLat,
                                     "longitude":SceneDelegate.GlobalVariables.userLong,
                                     
        ]
        print(parameters)
        loadRequest_V2(method:.post, apiName:"update_profile/update_location", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("LOCATION SUBMIT\(json)")
        
                self.locationManager.stopUpdatingLocation()
                self.switchToHome()
            }
        }
    }
}

