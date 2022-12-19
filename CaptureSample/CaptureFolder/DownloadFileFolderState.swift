//
//  DownloadFile.swift
//  CaptureSample
//
//  Created by Beket Muratbek on 17.12.2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import os

private var logger = Logger(subsystem: "com.apple.sample.CaptureSample", category: "DownloadFileFolderState")

class DownloadFileFolderState: ObservableObject {
    
    enum Error: Swift.Error {
        case invalidDownloadedFileDir
    }
    
    static func downloadFileDir() -> URL? {
        guard let downloadFileFolder = try? FileManager.default.url(for:.documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil, create: false) else {
            return nil
        }
        return downloadFileFolder.appendingPathComponent("Captures/Models", isDirectory: true)
    }
    
    func createDownloadedFileDirectory() -> URL? {
        guard let downloadedFileFolder = DownloadFileFolderState.downloadFileDir() else {
            logger.error("Can't get user document dir!")
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let timestamp = formatter.string(from: Date())
        let newDownloadedFileDir = downloadedFileFolder.appendingPathComponent(timestamp + "/", isDirectory: true)
        
        logger.log("Creating downloaded file path: \"\(String(describing: newDownloadedFileDir))\"")
        let downloadedFilePath = newDownloadedFileDir.path
        do {
            try FileManager.default.createDirectory(atPath: downloadedFilePath, withIntermediateDirectories: true)
        } catch {
            logger.error("Failed to create downloaded file path=\"\(downloadedFilePath)\"error=\(String(describing: error))")
        }
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: downloadedFilePath, isDirectory: &isDir)
        guard exists && isDir.boolValue else {
            return nil
        }
        return newDownloadedFileDir
    }
}
