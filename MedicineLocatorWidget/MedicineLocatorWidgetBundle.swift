//
//  MedicineLocatorWidgetBundle.swift
//  MedicineLocatorWidget
//

import WidgetKit
import SwiftUI

/// Entry point of the widget extension (like @main in the app).
/// Lists every widget this extension offers — just one for now.
@main
struct MedicineLocatorWidgetBundle: WidgetBundle {
    var body: some Widget {
        MedicineLocatorWidget()
    }
}
