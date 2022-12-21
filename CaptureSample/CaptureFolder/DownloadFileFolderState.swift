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


/*
 2022-12-19 18:07:48.776759+0600 CaptureSample[1228:228985] [CaptureFolderState] Creating capture path: "file:///var/mobile/Containers/Data/Application/D3AE66C7-B7A3-42B3-A0FE-1C7319B94CEE/Documents/Captures/Dec%2019,%202022%20at%206:07:48%20PM/"
 2022-12-19 18:07:48.778532+0600 CaptureSample[1228:229159] [CameraViewModel] >>> Got back dual wide camera!
 2022-12-19 18:07:48.803991+0600 CaptureSample[1228:229159] [CameraViewModel] didSet setupResult=success
 url: nil
 2022-12-19 18:08:17.079260+0600 CaptureSample[1228:228985] Unable to find and preview file
 2022-12-19 18:08:17.079477+0600 CaptureSample[1228:228985] CFURLCopyResourcePropertyForKey failed because it was passed a URL which has no scheme
 2022-12-19 18:08:17.239036+0600 CaptureSample[1228:228985] [default] QLUbiquitousItemFetcher: <QLUbiquitousItemFetcher: 0x282f067b0> could not create sandbox wrapper. Error: Error Domain=NSPOSIXErrorDomain Code=1 "couldn't issue sandbox extension com.apple.quicklook.readonly for '/null': Operation not permitted" UserInfo={NSDescription=couldn't issue sandbox extension com.apple.quicklook.readonly for '/null': Operation not permitted} #PreviewItem
 2022-12-19 18:08:17.289812+0600 CaptureSample[1228:228985] [default] Unhandled item type 14: contentType is: public.data #PreviewItem
 2022-12-19 18:08:17.290975+0600 CaptureSample[1228:228985] [default] Unhandled item type 14: contentType is: public.data #PreviewItem
 2022-12-19 18:08:21.340158+0600 CaptureSample[1228:228985] [DownloadFileFolderState] Creating downloaded file path: "file:///var/mobile/Containers/Data/Application/D3AE66C7-B7A3-42B3-A0FE-1C7319B94CEE/Documents/Captures/Models/Dec%2019,%202022%20at%206:08:21%20PM/"
 url: Optional("/var/mobile/Containers/Data/Application/D3AE66C7-B7A3-42B3-A0FE-1C7319B94CEE/Documents/Captures/Models/Dec 19, 2022 at 6:08:21 PM")
 CaptureSample/ARQuickLookView.swift:178: Fatal error: Unexpectedly found nil while unwrapping an Optional value
 2022-12-19 18:08:23.576838+0600 CaptureSample[1228:228985] CaptureSample/ARQuickLookView.swift:178: Fatal error: Unexpectedly found nil while unwrapping an Optional value
*/
