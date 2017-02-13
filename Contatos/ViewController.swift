//
//  ViewController.swift
//  Contatos
//
//  Created by Usuário Convidado on 11/02/17.
//  Copyright © 2017 FIAP. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class ViewController: UIViewController {

    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var mapview: MKMapView!
    
    lazy var locationManager = CLLocationManager()
    
    
    var contactStore: CNContactStore {
        return (UIApplication.shared.delegate as! AppDelegate).contactStore
    }
    var contact: CNContact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapview.delegate = self
        
        requestUserLocationAuthorization()
    }
    
    func startMonitoringUserLocation() {
        //locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
    
    func requestUserLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            
            switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Usuário já autorizou")
                    mapview.showsUserLocation = true
                    startMonitoringUserLocation()
                case .denied:
                    print("Acesso negado!!")
                case .notDetermined:
                    print("Ainda não foi solicitado")
                    locationManager.requestAlwaysAuthorization()
                case .restricted:
                    print("O device não permite o acesso à sua localização")
            }
        }
    }
    

    @IBAction func saveContact(_ sender: UIButton) {
        let newContact = CNMutableContact()
        newContact.givenName = tfName.text!
        
        let email = CNLabeledValue(label: CNLabelWork, value: tfEmail.text! as NSString)
        newContact.emailAddresses = [email]
        
        let phoneNumber = CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: tfPhone.text!))
        newContact.phoneNumbers = [phoneNumber]
        
        let profileImage = UIImage(named: "contact")
        newContact.imageData = UIImageJPEGRepresentation(profileImage!, 0.8)
        
        //newContact.postalAddresses
        
        
        let request = CNSaveRequest()
        request.add(newContact, toContainerWithIdentifier: nil)
        
        try! contactStore.execute(request)
        
        let alert = UIAlertController(title: "Sucesso", message: "Contato cadastrado com sucesso", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
            DispatchQueue.main.async {
                self.tfEmail.text = ""
                self.tfPhone.text = ""
                self.tfName.text = ""
                self.tfAddress.text = ""
            }
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func getRoute(source: CLPlacemark) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source.location!.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
        
        let directions = MKDirections(request: request)
        directions.calculate { (response: MKDirectionsResponse?, error: Error?) in
            
            if error == nil {
                if let response = response, let route = response.routes.first {
                    print("Nome:", route.name)
                    print("Distance:", route.distance)
                    print("Tempo de duração:", route.expectedTravelTime)
                    for step in route.steps {
                        print("Em \(step.distance) metro(s), \(step.instructions)")
                    }
                    
                    DispatchQueue.main.async {
                        self.mapview.add(route.polyline, level: MKOverlayLevel.aboveLabels)
                        self.mapview.showAnnotations(self.mapview.annotations, animated: true)
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func getAddressLocation(_ sender: UIButton) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(tfAddress.text!) { (placemarks: [CLPlacemark]?, error: Error?) in
            if error == nil {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    print("country:", placemark.country ?? "---")
                    print("administrativeArea:", placemark.administrativeArea ?? "---")
                    print("postalCode:", placemark.postalCode ?? "---")
                    print("location:", placemark.location ?? "---")
                    print("subAdministrativeArea:", placemark.subAdministrativeArea ?? "---")
                    print("administrativeArea:", placemark.administrativeArea ?? "---")
                    print("addressDictionary:", placemark.addressDictionary ?? "---")
                    
                    let addressAnnotation = MKPointAnnotation()
                    addressAnnotation.coordinate = placemark.location!.coordinate
                    //let region = MKCoordinateRegionMakeWithDistance(placemark.location!.coordinate, 300, 300)
                    self.mapview.addAnnotation(addressAnnotation)
                    //self.mapview.setRegion(region, animated: true)
                    
                    self.getRoute(source: placemark)
                }
            }
            
        }
    }
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
            renderer.lineWidth = 5.0
            return renderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                mapview.showsUserLocation = true
                startMonitoringUserLocation()
            default:
                break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
        let region = MKCoordinateRegionMakeWithDistance(locations.last!.coordinate, 300, 300)
        self.mapview.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
    }
    
}

