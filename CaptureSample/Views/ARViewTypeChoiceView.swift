//
//  ARViewTypeChoiceView.swift
//  CaptureSample
//
//  Created by Beket Muratbek on 20.12.2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import SwiftUI

enum Views: String, CaseIterable {
    case ARQuickLookView
    case ARView
}

struct SelectedView: View {
    @Binding var url: URL?
    var selectedView: Views
    
    var body: some View {
        switch selectedView {
        case .ARQuickLookView:
            ARQuickLookView(name: "MyScene", path: $url)
        case .ARView:
            ArView(url: $url)
        }
    }
}

struct ARViewTypeChoiceView: View {
    @Binding var isPresented: Bool
    @Binding var url: URL?
    @State var selectedItems: Views = .ARQuickLookView
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isPresented = false
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .renderingMode( .template)
                        .aspectRatio(contentMode: .fit)
                        .padding(.all, 7.5)
                        .background(Color("Gray"))
//                        .background(Color.red)
                        .foregroundColor(Color.white)
                        .frame(width: 30, height: 30, alignment: .center)
                        .cornerRadius(8)
                        .padding([.trailing, .top, .bottom], 5)
                        .padding(.leading, 10)
//                        .cornerRadius(10)
                })
                Picker("AR", selection: $selectedItems) {
                    ForEach(Views.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .padding(.trailing, 10)
                Spacer()
            }
            
            Spacer()
            SelectedView(url: $url, selectedView: selectedItems)
                .ignoresSafeArea(edges: .bottom)
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct ARViewTypeChoiceView_Previews: PreviewProvider {
    @State static var url: URL?
    static var previews: some View {
        ARViewTypeChoiceView(isPresented: .constant(true), url: $url)
    }
}
