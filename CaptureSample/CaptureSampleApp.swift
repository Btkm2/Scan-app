/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Custom app subclass.
*/

import SwiftUI

@main
struct CaptureSampleApp: App {
    @StateObject var model = CameraViewModel() ///Comment it so camera folder will be created only user presses on camera selection button in CreateModelView
    
    var body: some Scene {
        WindowGroup {
//            ContentView(model: model)
            SplashScreenView(model: model)
        }
    }
}
