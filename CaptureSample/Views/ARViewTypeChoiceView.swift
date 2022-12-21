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
    @Binding var url: URL?
    @State var selectedItems: Views = .ARQuickLookView
    
    var body: some View {
        VStack {
            Picker("AR", selection: $selectedItems) {
                ForEach(Views.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Spacer()
            SelectedView(url: $url, selectedView: selectedItems)
                .ignoresSafeArea(edges: .bottom)
            Spacer()
        }
    }
}

struct ARViewTypeChoiceView_Previews: PreviewProvider {
    @State static var url: URL?
    static var previews: some View {
        ARViewTypeChoiceView(url: $url)
    }
}
