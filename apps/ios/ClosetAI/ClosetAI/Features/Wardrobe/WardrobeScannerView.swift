//
//  WardrobeScannerView.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import SwiftUI
import PhotosUI

struct WardrobeScannerView: View {

    @State private var viewModel: WardrobeScannerViewModel

    @State private var selectedPhoto: PhotosPickerItem?

    init(viewModel: WardrobeScannerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {

            if let analysis = viewModel.analysis {
                analysisView(analysis)
            } else {
                emptyState
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            if viewModel.isAnalyzing {
                ProgressView("Analyzing photo...")
            }

            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images
            ) {
                Label(
                    "Choose Photo",
                    systemImage: "photo"
                )
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Add Wardrobe Item")
        .onChange(of: selectedPhoto) { _, newPhoto in
            guard let newPhoto else {
                return
            }

            Task {
                await viewModel.analyze(
                    photo: newPhoto
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tshirt")
                .font(.system(size: 56))

            Text("Add an item")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose a photo and ClosetAI will analyze it.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private func analysisView(
        _ analysis: WardrobeAnalysis
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(analysis.name)
                .font(.title2)
                .fontWeight(.bold)

            LabeledContent(
                "Category",
                value: analysis.category.rawValue.capitalized
            )

            if let subcategory = analysis.subcategory {
                LabeledContent(
                    "Type",
                    value: subcategory.capitalized
                )
            }

            if !analysis.attributes.colors.isEmpty {
                LabeledContent(
                    "Colors",
                    value: analysis.attributes.colors.joined(
                        separator: ", "
                    )
                )
            }

            if let material = analysis.attributes.material {
                LabeledContent(
                    "Material",
                    value: material.capitalized
                )
            }

            if let style = analysis.attributes.style {
                LabeledContent(
                    "Style",
                    value: style.capitalized
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    let viewModel = WardrobeScannerViewModel(
        aiService: DevelopmentWardrobeAIService()
    )

    NavigationStack {
        WardrobeScannerView(
            viewModel: viewModel
        )
    }
}
