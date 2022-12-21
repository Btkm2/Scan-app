//
//  PhotoPickerView.swift
//  CaptureSample
//
//  Created by Beket Muratbek on 04.11.2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import SwiftUI
import UIKit
import Foundation
import PhotosUI

struct PhotoLibraryPickerView: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var picker: Bool
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var picker_config = PHPickerConfiguration()
        //can change it to videos to pick videos as well
        picker_config.filter = .images
        //setting 0 to multiple selection
        picker_config.selectionLimit = 0
        let imagepicker = PHPickerViewController(configuration: picker_config)
//        imagepicker.sourceType = .photoLibrary
        imagepicker.delegate = context.coordinator
        return imagepicker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Cordinator {
        return Cordinator(parent: self)
    }
}

//struct PhotoPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoPickerView()
//    }
//}
class Cordinator: NSObject, PHPickerViewControllerDelegate {
    var parent : PhotoLibraryPickerView
    init(parent: PhotoLibraryPickerView) {
        self.parent = parent
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        //cancelling photo picking
        parent.picker = false
        for img in results {
            //checking whether the image can be loaded...
            if img.itemProvider.canLoadObject(ofClass: UIImage.self){
                //retreving selected Image...
                img.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    guard let upload_image = image else{
                        print(error)
                        return
                    }
                    self.parent.images.append(upload_image as! UIImage)
                    
                }
            }else{
                //cannot be loaded
                print("Error!!")
            }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //
    }
}
