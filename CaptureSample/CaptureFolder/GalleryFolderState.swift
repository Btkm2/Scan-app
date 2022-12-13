//
//  GalleryFolderState.swift
//  CaptureSample
//
//  Created by Beket Muratbek on 04.12.2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import os

private var logger = Logger(subsystem: "com.apple.sample.CaptureSample",
                            category: "GalleryFolderState")

class GalleryFolderState: ObservableObject {
    
    enum Error: Swift.Error {
        case invalidGalleryDir
    }
    
    static func galleryDir() -> URL? {
        guard let documentFolder = try? FileManager.default.url(for:.documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil, create: false) else {
            return nil
        }
        return documentFolder.appendingPathComponent("Captures/Gallery", isDirectory: true)
    }
    
    func createGalleryDirectory() -> URL? {
        guard let galleryFolder = GalleryFolderState.galleryDir() else {
            logger.error("Can't get user document dir!")
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let timestamp = formatter.string(from: Date())
        let newGalleryDir = galleryFolder
            .appendingPathComponent(timestamp + "/", isDirectory: true)
        
        logger.log("Creating gallery path: \"\(String(describing: newGalleryDir))\"")
        let galleryPath = newGalleryDir.path
        do {
            try FileManager.default.createDirectory(atPath: galleryPath,
                                                    withIntermediateDirectories: true)
        } catch {
            logger.error("Failed to create gallerypath=\"\(galleryPath)\" error=\(String(describing: error))")
        }
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: galleryPath, isDirectory: &isDir)
        guard exists && isDir.boolValue else {
            return nil
        }
        return newGalleryDir
    }
}
