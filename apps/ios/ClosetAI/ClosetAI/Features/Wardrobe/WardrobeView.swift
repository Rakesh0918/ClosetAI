//
//  WardrobeView.swift
//  ClosetAI
//
//  Created by Rakesh on 09/08/26.
//

import SwiftUI

struct WardrobeView: View {

    @State private var viewModel: WardrobeViewModel

    init(viewModel: WardrobeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading wardrobe...")
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else {
                    wardrobeContent
                }
            }
            .navigationTitle("My Wardrobe")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        WardrobeScannerView(
                            viewModel: viewModel.makeScannerViewModel()
                        )
                    } label: {
                        Image(systemName: "camera")
                    }
                    .accessibilityLabel("Scan wardrobe item")
                }
            }
        }
        .task {
            await viewModel.loadWardrobe()
        }
    }

    private var wardrobeContent: some View {
        VStack(spacing: 0) {
            filterBar

            List(viewModel.filteredItems) { item in
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.headline)

                    Text(
                        item.subcategory
                        ?? item.category.rawValue.capitalized
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Text(item.attributes.style ?? "No style")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.plain)
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {

                filterButton(
                    title: "All",
                    filter: .all
                )

                ForEach(WardrobeCategory.allCases, id: \.self) { category in
                    filterButton(
                        title: category.rawValue.capitalized,
                        filter: .category(category)
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }
    
    private func filterButton(
        title: String,
        filter: WardrobeFilter
    ) -> some View {
        Button {
            viewModel.selectFilter(filter)
        } label: {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    viewModel.selectedFilter == filter
                    ? Color.primary
                    : Color.secondary.opacity(0.12)
                )
                .foregroundStyle(
                    viewModel.selectedFilter == filter
                    ? Color(.systemBackground)
                    : .primary
                )
                .clipShape(Capsule())
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .foregroundStyle(.secondary)

            Button("Try Again") {
                Task {
                    await viewModel.retry()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    let viewModel = WardrobeViewModel(
        wardrobeService: DevelopmentWardrobeService(),
        wardrobeAIService: DevelopmentWardrobeAIService()
    )

    WardrobeView(
        viewModel: viewModel
    )
}
