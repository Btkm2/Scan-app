//
//  CreateModelView.swift
//  CaptureSample
//
//  Created by Beket Muratbek on 04.11.2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import SwiftUI
import Alamofire
import UIKit
import Foundation
import ObjectiveC
import os
import Zip

private var logger = Logger(subsystem: "com.apple.sample.CaptureSample", category: "CreateModelView")

struct CreateModelView: View {
    @State var input: String = ""///Stores value of input field
    @State var gallery_toogle = false///Stores state of gallery picker view
    @State var camera_toggle = false///Stores state of camera picker view
    @State var ARQuickLookPreview_toggle = false///Stores state of ARQuickLookPreview
    @State var images: [UIImage] = [] ///Array of selected images. For now it only stores images that are selected from gallery
    @ObservedObject var model: CameraViewModel
    @StateObject var folderState = GalleryFolderState()
    @StateObject var downloadFolder = DownloadFileFolderState()
//    @StateObject var model = CaptureFolderState().
//    @State var sendDataToggle = false
    @State var holder: URL? ///Holder to store path of new folder
    @State var url: URL?///Holder to store path of downloaded models
    @State var url_holder: URL?
    var body: some View {
        VStack {
            NavigationView {
                Form {
                    Section(header: Text("Name")){
                        TextField("Name your order", text: $input)
                    }
                    Section(header: Text("Add Photos")) {
                        Button(action: {
                            gallery_toogle = true
                            print("captureDir: \(String(describing: model.captureDir?.relativePath))")
                            /// Every time when we choose to select images from gallery, new folder will be created
                            let temp = folderState.createGalleryDirectory()?.absoluteURL
                            print(String(describing: temp))
                            do {
                                holder = try temp?.asURL()
                            } catch {
                                print("Error: \(error)")
                            }
                        }, label: {
                            HStack{
                                Image(systemName: "photo.on.rectangle")
                                Text("Pick from gallery")
                                    .foregroundColor(Color.black)
                            }
                        })
                        Button(action: {
                            camera_toggle = true
                        }, label: {
                            HStack {
                                Image(systemName: "camera")
                                Text("use camera")
                                    .foregroundColor(Color.black)
                            }
                        })
                        if images.count < 20 {
                            Text("Select at least 20 images")
                                .foregroundColor(Color.red)
                                .font(.system(size: 8, weight: .medium, design: .default))
                        }else {
                            Text("Ready to send images!")
                                .foregroundColor(Color.green)
                                .font(.system(size: 8, weight: .medium, design: .default))
                        }
                    }
                    Section{
                        if !images.isEmpty {
                            HStack{
                                ForEach(images, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .renderingMode(.original)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40,height: 40)
                                }
                            }
                        }else{
                            Image(systemName: "clock.arrow.2.circlepath")
                            Text("Nothing for now")
                        }
                    }
                    var hold = ""
                    //send images to server
                    Button(action:{
                        sendZipToServer(path: archiveFolder(path: holder))
                        logger.log("Send zip")
                    }, label:{
                        HStack {
                            Image(systemName:"icloud.fill")
                            Text("Send to Cloud")
                                .foregroundColor(Color.black)
                            
                        }
                    })
                    Button(action: {
                        DispatchQueue.global(qos: .userInitiated).async {
                            writeImagesToFolder(images: images, path: holder)
                            archiveFolder(path: holder)
                        }
                    }, label: {
                        Text("Zip folder")
                    })
                    Button(action: {
                        let downloadPath = downloadFolder.createDownloadedFileDirectory()?.absoluteURL
                        do {
                            url = try downloadPath?.asURL()
                            url_holder = url
                        } catch {
                            print(error)
                        }
                        downloadFile(path: url)
                    }, label: {
                        Text("Download Model")
                    })
                    Button(action: {
                        ARQuickLookPreview_toggle = true
                        print("url: \(url?.relativePath)")
                    }, label: {
                        Text("Preview model")
                    })
                }
                .navigationTitle("New Order")
            }
            .sheet(isPresented: $gallery_toogle, content:{
                PhotoLibraryPickerView(images: $images, picker: $gallery_toogle)
            })
            .sheet(isPresented: $camera_toggle, content: {
                CameraPhotoPicker()
                //                .ignoresSafeArea()
                //            CameraView(model: CameraViewModel())
                //                .ignoresSafeArea()
            })
//            .sheet(isPresented: $ARQuickLookPreview_toggle, content: {
//                ARQuickLookView(name: "Test", path: $url_holder)
//            })
            .sheet(isPresented: $ARQuickLookPreview_toggle, content: {
                ARViewTypeChoiceView(url: $url_holder)
            })
        }
    }
    
    func senData(images: [UIImage]) -> String{
//        let url = URL(string: "http://127.0.0.1:8080/upload")!
        let local_url = URL(string: "http://macairbeket.local:8080/upload")!
        let ngrok_url = URL(string: "https://b358-178-89-101-80.eu.ngrok.io/upload")!
        var response_result = ""
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        AF.session.configuration.timeoutIntervalForRequest = 60
        AF.upload(multipartFormData: { multipartFormData in
            //import image to request
            for imageData in images {
                var date = Date().timeIntervalSinceNow
                var file_name = "\(date)" + input
//                var imageDataToData: Data = imageData.jpegData(compressionQuality: 1.0)!
                var imageNSData: NSData = NSData(data: imageData.jpegData(compressionQuality: 0.8)!)
                multipartFormData.append(/*imageData as! Data*/imageNSData as Data,withName: "files[]",fileName: "\(file_name).jpeg",mimeType: "image/jpeg")
            }
        }, to: ngrok_url,method: HTTPMethod.post).responseData(completionHandler: {response in
            debugPrint(response)
            if let temp = response.response?.statusCode {
                response_result = "\(temp)"
            }
//            response_result = "\(response.response?.statusCode)"
            print("is it work???")
        })
        //{
        //(result) in
        /*            switch result {
         case .success(let upload, _, _):
         upload.uploadProgress(closure: { (progress) in
         print("Upload Progress: \(progress.fractionCompleted)")
         })
         upload.responseJSON { response in
         print("response.result :\(String(describing: response.result.value))")
         }
         case .failure(let encodingError):
         print(encodingError)*/
        //print(result)
//        print("|-----------------|")
////        var response_string = ""
//        AF.request("http://127.0.0.1:8080/hello").validate().responseData { response in
//            debugPrint(response)
//        }
//        .responseDecodable(of: Decodable.Type) { response in
//                debugPrint(response)
//            }
        return response_result
    }
    /// Function that writes images that selected from gallery to gallery folder
    /// - Parameters:
    ///   - images: Array of selected images
    ///   - path: path of newly created folder in gallery directory
    func writeImagesToFolder(images: [UIImage], path: URL?) {
        guard let unwrpPath = path else {
            return
        }
        for image in images {
            let writePath = unwrpPath.appendingPathComponent("\(UUID().uuidString).jpeg")
            if let data = image.jpegData(compressionQuality: 0.9) {
                do {
                    try data.write(to: writePath)
                } catch {
                    print("Unable to write to dir")
                    logger.error("Error when writing images to folder")
                }
            }
        }
    }
    /// Function that zip folder where selecteg images are stored
    /// - Parameter path: path of created folder
    func archiveFolder(path: URL?) -> URL?{
        var temp: URL?
        guard let unwrpPath = path else {
            return nil
        }
        do {
            let zipFilePath = unwrpPath.appendingPathComponent("Arhive.zip")
            let zipFile = try Zip.quickZipFiles([unwrpPath],fileName: "archive.zip" )
            try Zip.zipFiles(paths: [unwrpPath], zipFilePath: zipFilePath, password: nil, progress: { (progress) -> () in
                print(progress)
            })
            temp = zipFilePath
        } catch {
            logger.error("Error while zipping folder")
        }
        return temp
    }
    func sendZipToServer(path: URL?) {
        let ngrok_url = URL(string: "https://50a3-213-211-75-90.eu.ngrok.io/upload")!
        guard let unwrpPath = path else {
            return
        }
        AF.upload(multipartFormData: { (multipartData) in
            multipartData.append(unwrpPath, withName: "files[]")
        }, to: ngrok_url,method: HTTPMethod.post).responseJSON(completionHandler: { (data) in
            debugPrint(data)
        })
    }
    func downloadFile(path: URL?) {
        let test_ngrok = URL(string: "http://localhost:8080/downloadFile")
        let ngrok_url = URL(string: "https://50a3-213-211-75-90.eu.ngrok.io/downloadFile")
        guard let unwrpPath = path else {
            return
        }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 400
        AF.session.configuration.timeoutIntervalForRequest = 400
        let destination: DownloadRequest.Destination = { _ , _ in
            
            let saveURL = unwrpPath.appendingPathComponent("Test.usdz")
            
            return (saveURL, [.removePreviousFile])
        }
        AF.download(ngrok_url!, method: .get, to:destination).response { response in
            debugPrint(response)
        }
    }
}

struct CreateModelView_Previews: PreviewProvider {
    @StateObject private static var model = CameraViewModel()
    static var previews: some View {
        CreateModelView(model: model)
    }
}


/*
 <UIImage:0x6000000f05a0 named(?) {4288, 2848} renderingMode=automatic(original)>
 <UIImage:0x6000000d4000 named(?) {4288, 2848} renderingMode=automatic(original)>
 <UIImage:0x6000000d41b0 named(?) {3000, 2002} renderingMode=automatic(original)>
 <UIImage:0x6000000d4240 named(?) {3000, 2002} renderingMode=automatic(original)>
 <UIImage:0x6000000fcab0 named(?) {1668, 2500} renderingMode=automatic(original)>
 */

//        Alamofire.UploadRequest(multipartFormData: { multipartFormData in
//            for imageData in images{
//                var imageNSData: NSData = NSData(data: imageData.jpegData(compressionQuality: 1.0)!)
//                multipartFormData.append(/*imageData as! Data*/imageNSData as Data,withName: "new_photo",fileName: "\(Date().timeIntervalSince1970).jpeg",mimeType: "image/jpeg")
//            }
//        }, to: url)
