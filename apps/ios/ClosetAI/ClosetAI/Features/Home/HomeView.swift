//
//  HomeView.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import SwiftUI

struct HomeView: View {

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 56))

                Text("Welcome to ClosetAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your wardrobe is ready.")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
