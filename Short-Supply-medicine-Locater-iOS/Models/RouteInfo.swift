//
//  RouteInfo.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  RouteInfo.swift
//  Short-Supply-medicine-Locater-iOS
//

import MapKit

/// A calculated route: the line to draw, how far, how long, and the turn-by-turn text.
struct RouteInfo {
    let polyline: MKPolyline
    let distance: CLLocationDistance     // metres
    let travelTime: TimeInterval         // seconds
    let steps: [String]
    var attribution: String? = nil      // credit line required by the data provider
}
