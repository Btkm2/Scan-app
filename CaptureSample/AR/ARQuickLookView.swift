//
//  ARQuickLookView.swift
//  CaptureSample
//
//  Created by Beket Muratbek on 19.12.2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import QuickLook
import ARKit
import RealityKit
import SwiftUI
import os

private var logger = Logger()

//struct ARQuickLookView: UIViewControllerRepresentable {
//    var name: String
//    var pathToFile: URL?
//    var allowScaling: Bool = true
//
//    func makeCoordinator() -> ARQuickLookView.Coordinator {
//        Cordinator(self,path: pathToFile)
//    }
//
//    func makeUIViewController(context: Context) -> QLPreviewController {
//        let controller = QLPreviewController()
//        controller.dataSource = self
//        return controller
//    }
//
//    func updateUIViewController(_ controller: QLPreviewController, context: Context) {
//        //nothing goes here
//    }
//
//    class Cordinator: NSObject, QLPreviewControllerDataSource {
//        let parent: ARQuickLookView
//        let path: URL?
//
//        init(_ parent: ARQuickLookView, path: URL?) {
//            self.parent = parent
//            self.path = path
//            super.init()
//        }
//
//        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
//            return 1
//        }
//
//        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
//            guard let fileURL = path else {
//                fatalError("Nothing to load")
//            }
//            let item = ARQuickLookPreviewItem(fileAt: fileURL)
//            return item
//        }
//    }
//}
//struct ARQuickLookView_Previews: PreviewProvider {
//    static var previews: some View {
//        ARQuickLookView(name: "MyScene")
//    }
//}


//struct RealityKitView: UIViewRepresentable {
////    func presentARQuickLook() {
////        let previewController = QLPreviewController()
////        previewController.dataSource = self
////        present(previewController, animated: true)
////    }
//    func makeUIView(context: Context) -> ARView {
//        let view = ARView()
//
//        //Start AR session
//        let session = view.session
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal]
//        session.run(config)
//
//        //Add coaching overlay
//        let coachingOverlay = ARCoachingOverlayView()
//        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        coachingOverlay.session = session
//        coachingOverlay.goal = .horizontalPlane
//        view.addSubview(coachingOverlay)
//
//        //Set debug options
//        #if DEBUG
//        view.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry]
//        #endif
//
//        return view
//    }
//    func updateUIView(_ uiView: ARView, context: Context) {
//        //nothing goes here
//    }
//}


//class ViewController: UIViewController, QLPreviewControllerDataSource {
//
//    override func viewDidAppear(_ animated: Bool) {
//        let previewController = QLPreviewController()
//        previewController.dataSource = self
//        present(previewController, animated: true, completion: nil)
//    }
//
//    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }
//
//    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
//        guard let path = Bundle.main.path(forResource: "myScene", ofType: "reality") else { fatalError("Couldn't find the supported input file.") }
//        let url = URL(fileURLWithPath: path)
//        return url as QLPreviewItem
//    }
//}

enum CustomError: Swift.Error {
    case SomeError
}

struct ARQuickLookView: UIViewControllerRepresentable {
    // Properties: the file name (without extension), and whether we'll let
    // the user scale the preview content.
    var name: String
    @Binding var path: URL?
    var allowScaling: Bool = true
    
    func makeCoordinator() -> ARQuickLookView.Coordinator {
        // The coordinator object implements the mechanics of dealing with
        // the live UIKit view controller.
        Coordinator(self, path: path)
    }
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        // Create the preview controller, and assign our Coordinator class
        // as its data source.
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ controller: QLPreviewController,
                                context: Context) {
        // nothing to do here
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: ARQuickLookView
        let url_path: URL?
//        private lazy var fileURL: URL = Bundle.main.url(forResource: parent.name,
//                                                        withExtension: "reality")!
        
        init(_ parent: ARQuickLookView, path: URL?) {
            self.parent = parent
            self.url_path = path
            super.init()
        }
        
        // The QLPreviewController asks its delegate how many items it has:
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        // For each item (see method above), the QLPreviewController asks for
        // a QLPreviewItem instance describing that item:
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            print(String(describing: url_path))
            guard let fileURL = url_path else {
                logger.error("Unable to find and preview file")
//                return CustomError.SomeError as! QLPreviewItem
                return ARQuickLookPreviewItem(fileAt: URL(string: "/null")!)
            }
//            guard let new_url = fileURL else {
//                logger.error("Unable to unwrap optional")
//                return ARQuickLookPreviewItem(fileAt: URL(string: "/null")!)
//            }
            
            let item = ARQuickLookPreviewItem(fileAt: URL(string: "\(fileURL)/Test.usdz")!)
            item.allowsContentScaling = parent.allowScaling
            return item
        }
    }
}

//struct ARQuickLookView_Previews: PreviewProvider {
//    static var previews: some View {
//        ARQuickLookView(name: "Test", path: <#T##Binding<URL?>#>)
//    }
//}
