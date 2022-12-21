//
//  ARView.swift
//  CaptureSample
//
//  Created by Beket Muratbek on 20.12.2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit
import os

private var logger = Logger()

struct ArView: UIViewRepresentable {
    @Binding var url: URL?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        guard let fileURL = url else {
            logger.error("Unable to unwrap optional value!")
            return ARView()
        }
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        let objectAnchor = try? Entity.load(contentsOf: URL(string: "\(fileURL)/Test.usdz")!)
        let anchorEntity = AnchorEntity()
        anchorEntity.addChild(objectAnchor!)
        
        arView.scene.addAnchor(anchorEntity)
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { ///Update needs when we place different models while app runs (it actually update the view)
        //nothing goes here
    }
}
