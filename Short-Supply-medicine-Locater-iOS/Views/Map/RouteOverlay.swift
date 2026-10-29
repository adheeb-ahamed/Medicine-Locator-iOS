//
//  RouteOverlay.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-29.
//

//
//  RouteOverlay.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI
import MapKit

/// The destination pin + route line. Used on the Map tab AND the Directions screen.
/// A custom MapContent works like a custom View, but goes inside Map { }.
struct RouteOverlay: MapContent {
    let pharmacy: Pharmacy
    let route: RouteInfo?
    let straightLineFrom: CLLocationCoordinate2D?     // set when MapKit had no road data

    var body: some MapContent {
        Annotation(pharmacy.name, coordinate: pharmacy.coordinate) {
            PharmacyPin(pharmacy: pharmacy, isSelected: true)
        }

        if let route {
            MapPolyline(route.polyline)
                .stroke(Theme.accent, lineWidth: 6)
        }

        if let from = straightLineFrom {
            MapPolyline(coordinates: [from, pharmacy.coordinate])
                .stroke(Theme.accent, style: StrokeStyle(lineWidth: 4, dash: [8, 6]))
        }
    }
}
