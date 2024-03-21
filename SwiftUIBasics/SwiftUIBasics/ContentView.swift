//
//  ContentView.swift
//  SwiftUIBasics
//
//  Created by Salman on 3/13/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe.desk")
                .imageScale(.large)
                .foregroundStyle(.tint)
            HStack {
                Text("Hello, world!")
                Text("Salman Mallick") }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
