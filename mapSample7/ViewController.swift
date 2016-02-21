//
//  ViewController.swift
//  mapSample7
//
//  Created by Takeuchi Haruki on 2016/02/21.
//  Copyright © 2016年 Takeuchi Haruki. All rights reserved.
//


import UIKit
import MapKit

class ViewController: UIViewController,MKMapViewDelegate {
    
    var routes: [MKRoute] = [] {
        didSet {
            var time: Double = 0
            var dist: Double = 0
            for route in self.routes {
                time += Double(route.expectedTravelTime)
                dist += Double(route.distance)
            }
        }
    }
    @IBOutlet var Navi: UINavigationItem!
    
    @IBOutlet var myMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 地図の中心の座標.
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.661, 139.715)
        
        let height: CGFloat = 0
        print(height)
        myMapView.center = self.view.center
        myMapView.centerCoordinate = center
        myMapView.delegate = self
        
        // 縮尺を指定.
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
        
        // regionをmapViewに追加.
        myMapView.region = myRegion
        
        // viewにmapViewを追加.
        self.view.addSubview(myMapView)
        
        let fromCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.665213, 139.730011)
        let toCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.658987, 139.702776)
        let throughCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.608987, 139.682276)
        
        addRoute(fromCoordinate, toCoordinate: throughCoordinate)
        fitMapWithSpots(fromCoordinate, toLocation: throughCoordinate)
        addRoute(throughCoordinate, toCoordinate: toCoordinate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addRoute(fromCoordinate: CLLocationCoordinate2D, toCoordinate: CLLocationCoordinate2D){
        let fromItem: MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil))
        let toItem: MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: toCoordinate, addressDictionary: nil))
        
        let myRequest: MKDirectionsRequest = MKDirectionsRequest()
        
        // 出発&目的地
        myRequest.source = fromItem
        myRequest.destination = toItem
        myRequest.requestsAlternateRoutes = false
        
        // 徒歩
        myRequest.transportType = MKDirectionsTransportType.Walking
        
        // MKDirectionsを生成してRequestをセット.
        let myDirections: MKDirections = MKDirections(request: myRequest)
        
        // 経路探索.
        myDirections.calculateDirectionsWithCompletionHandler { (response: MKDirectionsResponse?, error: NSError?) -> Void in
            if error != nil {
                print(error)
                return
            }
            
            if let route = response?.routes.first as MKRoute? {
                print("目的地まで \(route.distance)m")
                print("所要時間 \(Int(route.expectedTravelTime/60))分")
                
                self.routes.append(route)
                
                // mapViewにルートを描画.
                self.myMapView.addOverlay(route.polyline)
            }
        }
    }
    
    func fitMapWithSpots(fromLocation: CLLocationCoordinate2D, toLocation: CLLocationCoordinate2D) {
        // fromLocation, toLocationに基いてmapの表示範囲を設定
        // 現在地と目的地を含む矩形を計算
        let maxLat: Double
        let minLat: Double
        let maxLon: Double
        let minLon: Double
        if fromLocation.latitude > toLocation.latitude {
            maxLat = fromLocation.latitude
            minLat = toLocation.latitude
        } else {
            maxLat = toLocation.latitude
            minLat = fromLocation.latitude
        }
        if fromLocation.longitude > toLocation.longitude {
            maxLon = fromLocation.longitude
            minLon = toLocation.longitude
        } else {
            maxLon = toLocation.longitude
            minLon = fromLocation.longitude
        }
        
        let center = CLLocationCoordinate2DMake((maxLat + minLat) / 2, (maxLon + minLon) / 2)
        
        let mapMargin:Double = 1.5;  // 経路が入る幅(1.0)＋余白(0.5)
        let leastCoordSpan:Double = 0.005;    // 拡大表示したときの最大値
        let span = MKCoordinateSpanMake(fmax(leastCoordSpan, fabs(maxLat - minLat) * mapMargin), fmax(leastCoordSpan, fabs(maxLon - minLon) * mapMargin))
        
        self.myMapView.setRegion(myMapView.regionThatFits(MKCoordinateRegionMake(center, span)), animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        // rendererを生成.
        let myPolyLineRendere: MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)
        
        // 線の太さを指定.
        myPolyLineRendere.lineWidth = 5
        
        // 線の色を指定.
        myPolyLineRendere.strokeColor = UIColor.redColor()
        
        return myPolyLineRendere
    }
}

