//
//  CameraPhotoPickerView.swift
//  CaptureSample
//
//  Created by Beket Muratbek on 13.11.2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct CameraPhotoPicker: UIViewControllerRepresentable{
    let camerapicker = UIImagePickerController()
    func makeUIViewController(context: Context) -> some UIViewController {
        let view = UIView()
        camerapicker.sourceType = .camera
        camerapicker.showsCameraControls = false
        let overlayView = CameraView(model: CameraViewModel())
        let hostingController = UIHostingController(rootView: overlayView)
        let host = hostingController.view!
//        hostingController.frame = (camerapicker.cameraOverlayView?.frame)!
        view.frame = host.frame
        print(type(of: host))
        view.tag = 101
//        camerapicker.self.frame = self.view.frame
        camerapicker.cameraOverlayView = view
        return camerapicker
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if camerapicker.sourceType == .camera {
            camerapicker.showsCameraControls = false
        }
    }
}
