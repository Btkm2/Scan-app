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
import AlertToast

private var logger = Logger(subsystem: "com.apple.sample.CaptureSample", category: "CreateModelView")

struct CreateModelView: View {
    @State var input: String = ""///Stores value of input field
    @State var gallery_toogle = false///Stores state of gallery picker view
    @State var camera_toggle = false///Stores state of camera picker view
    @State var ARQuickLookPreview_toggle = false///Stores state of ARQuickLookPreview
    @State var images: [UIImage] = [] ///Array of selected images. For now it only stores images that are selected from gallery
    @StateObject var model = CameraViewModel()
    @StateObject var folderState = GalleryFolderState()
    @StateObject var downloadFolder = DownloadFileFolderState()
//    @StateObject var model = CaptureFolderState().
//    @State var sendDataToggle = false
    @State var holder: URL? ///Holder to store path of new folder
    @State var url: URL?///Holder to store path of downloaded models
    @State var url_holder: URL?
    @State var toast_toggle = false ///Toggle that stores state of error toast
    @State private var progress = 0.0 ///State of a progress of uploading images to server
    @State private var upload_button_state = false ///State of upload button
    @State private var download_button_state = false ///State of sownload button
    var body: some View {
        VStack {
            NavigationView {
                Form {
                    Section(header: Text("Name"), footer: Text(input.isEmpty ? "Please enter name of your order" : "") //MARK: This called ternary operator
                        .foregroundColor(Color.red)
                    ){
                        TextField("Name your order", text: $input)
                            .onSubmit {
                                print(input)
                                if folderState.isDirectoryExists(dirName: input) {
                                    toast_toggle = true
                                }else {
                                    print("FALSE from onSubmit!!!")
                                }
                            }
                    }
                    Section(header: Text("Add Photos"), footer: Text(images.count < 20 ? "Please select at least 20 images" : "")
                        .foregroundColor(Color.red)
                    ) {
                        Button(action: {
                            gallery_toogle = true
                            print("captureDir: \(String(describing: model.captureDir?.relativePath))")
                            /// Every time when we choose to select images from gallery, new folder will be created
                            let temp = folderState.createGalleryDirectory(dirName: input)?.absoluteURL
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
                    }
                    Section(header: Text("Preview selected images")){
                        if !images.isEmpty {
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack{
                                    ForEach(images, id: \.self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .renderingMode(.original)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 40,height: 40)
                                    }
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
                        progress = 0.0
                        download_button_state = false
                        upload_button_state = true
                        writeImagesToFolder(images: images, path: holder)
                        sendZipToServer(path: archiveFolder(path: holder, fileName: input))
                        logger.log("Starting sending zip to server")
                    }, label:{
                        HStack {
                            Image(systemName:"icloud.fill")
                            Text("Send to Cloud")
                                .foregroundColor(Color.black)
                            
                        }
                    })
                    //.disabled(input.isEmpty ? true : false) //MARK: Uncomment this
                    //                    Button(action: {
                    //                        DispatchQueue.global(qos: .userInitiated).async {
                    //                            writeImagesToFolder(images: images, path: holder)
                    //                            archiveFolder(path: holder, fileName: input)
                    //                        }
                    //                    }, label: {
                    //                        Text("Zip folder")
                    //                    })
                    Button(action: {
                        upload_button_state = false
                        download_button_state = true
                        progress = 0.0
                        let downloadPath = downloadFolder.createDownloadedFileDirectory()?.absoluteURL
                        do {
                            url = try downloadPath?.asURL()
                            url_holder = url
                        } catch {
                            print(error)
                        }
                        downloadFile(path: url, fileName: input)
                    }, label: {
                        Text("Download Model")
                    })
                    Button(action: {
                        ARQuickLookPreview_toggle = true
                        print("url: \(url?.relativePath)")
                    }, label: {
                        Text("Preview model")
                    })
                        VStack(alignment: .leading) {
                            if upload_button_state {
                                HStack {
                                    Image(systemName: "tray.and.arrow.up")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 15, height: 15)
                                    Text("Upload progress")
                                        .font(.system(size: 10, weight: .light, design: .default))
                                        .onAppear {
                                            download_button_state = false
                                        }
                                }
                            }else if download_button_state {
                                HStack {
                                    Image(systemName: "tray.and.arrow.down")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 15, height: 15)
                                    Text("Download progress")
                                        .font(.system(size: 10, weight: .light, design: .default))
                                        .onAppear {
                                            upload_button_state = false
                                        }
                                }
                            }else {
                                Text("")
                                    .onAppear {
                                        download_button_state = false
                                        upload_button_state = false
                                    }
                            }
                            ProgressView(value: progress)
                                .tint(Color.green)
                    }
                }
                .navigationTitle("New Order")
                .navigationBarBackButtonHidden(true)
            }
            .sheet(isPresented: $gallery_toogle, content:{
                PhotoLibraryPickerView(images: $images, picker: $gallery_toogle)
            })
            .sheet(isPresented: $camera_toggle, content: {
//                CameraPhotoPicker()
                ContentView(model: model)
                    .ignoresSafeArea(edges: [.bottom, .trailing, .leading])
            })
            .sheet(isPresented: $ARQuickLookPreview_toggle, content: {
                ARViewTypeChoiceView(isPresented: $ARQuickLookPreview_toggle, url: $url_holder)
            })
            .toast(isPresenting: $toast_toggle, alert: {
                AlertToast(displayMode: .hud, type: .error(Color.red), title: "Order with this name already exists")
            })
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
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
            if let data = image.jpegData(compressionQuality: 0.5) {
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
    func archiveFolder(path: URL?, fileName: String) -> URL?{
        var temp: URL?
        guard let unwrpPath = path else {
            return nil
        }
        do {
            let zipFilePath = unwrpPath.appendingPathComponent("\(fileName).zip")
//            let zipFile = try Zip.quickZipFiles([unwrpPath],fileName: "archive.zip" )
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
        let test_local_url = URL(string: "http://127.0.0.1:8080/upload")!
        let ngrok_url = URL(string: "https://a068-95-56-59-247.eu.ngrok.io/upload")!
        guard let unwrpPath = path else {
            return
        }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 400
        AF.session.configuration.timeoutIntervalForRequest = 400
        AF.upload(multipartFormData: { (multipartData) in
            multipartData.append(unwrpPath, withName: "files[]")
        }, to: ngrok_url,method: HTTPMethod.post).responseJSON(completionHandler: { (data) in
            debugPrint(data)
        }).uploadProgress(closure: { (uploadProgress) in
            DispatchQueue.main.async {
                progress = uploadProgress.fractionCompleted
            }
            print("Progress: \(uploadProgress.fractionCompleted)")
        })
    }
    func downloadFile(path: URL?, fileName: String) {
        let test_ngrok = URL(string: "http://localhost:8080/downloadFile")
        let ngrok_url = URL(string: "https://a068-95-56-59-247.eu.ngrok.io/downloadFile/\(fileName)")
        guard let unwrpPath = path else {
            return
        }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 400
        AF.session.configuration.timeoutIntervalForRequest = 400
        let destination: DownloadRequest.Destination = { _ , _ in
            
            let saveURL = unwrpPath.appendingPathComponent("\(fileName).usdz")
            
            return (saveURL, [.removePreviousFile])
        }
        AF.download(ngrok_url!, method: .get, to:destination).response { response in
            print(response.response!.statusCode) ///Printing the response http status code for fututre checks
            debugPrint(response)
        }.downloadProgress(closure: { (downloadProgress) in
            DispatchQueue.main.async {
                progress = downloadProgress.fractionCompleted
            }
            print("Download progress: \(downloadProgress.fractionCompleted)")
        })
    }
}

struct CreateModelView_Previews: PreviewProvider {
//    @StateObject private static var model = CameraViewModel()
    static var previews: some View {
//        CreateModelView(model: model)
        CreateModelView()
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
