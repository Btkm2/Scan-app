//
//  WelcomePageView.swift
//  CaptureSample
//
//  Created by Beket Muratbek on 04.11.2022.
//  Copyright © 2022 Apple. All rights reserved.
//


import SwiftUI

struct WelcomePageView: View {
    var body: some View {
        NavigationView{
            Section {
                Form {
                    HStack{
                        Image(systemName: "plus.viewfinder")
                            .padding(.trailing,20)
                        VStack(alignment:.leading) {
                            NavigationLink("Create a 3D Model", destination: CreateModelView())
                            Text("Free")
                        }
                    }
                        .padding(.all,10)
                }
            }
        }
        .navigationTitle("Hello")
    }
}

struct WelcomePageView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePageView()
    }
}
