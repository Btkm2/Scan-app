//
//  WelcomePageView.swift
//  CaptureSample
//
//  Created by Beket Muratbek on 04.11.2022.
//  Copyright © 2022 Apple. All rights reserved.
//


import SwiftUI

struct WelcomePageView: View {
    @ObservedObject var model: CameraViewModel
    var body: some View {
        VStack {
            NavigationView{
                Form {
                    Section {
                        Button (action: {
                            
                        }, label: {
                            Text("Press me!")
                        })
                        .onTapGesture {
                            print("Pressed")
                        }
                    }
                    Section {
                        HStack{
                            Image(systemName: "plus.viewfinder")
                                .padding(.trailing,20)
                            VStack(alignment:.leading) {
                                NavigationLink("Create a 3D Model", destination: CreateModelView(model: model))
                                Text("Free")
                            }
                        }
                        .padding(.all,10)
                    }
                }
                .navigationBarBackButtonHidden(false)
            }
        }
    }
}

struct WelcomePageView_Previews: PreviewProvider {
    @StateObject private static var model = CameraViewModel()
    static var previews: some View {
        WelcomePageView(model: model)
    }
}
