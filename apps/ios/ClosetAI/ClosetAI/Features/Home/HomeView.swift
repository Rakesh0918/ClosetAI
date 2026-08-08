//
//  HomeView.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("ClosetAI")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Home")
                .font(.title2)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
