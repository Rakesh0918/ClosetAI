//
//  AuthenticationView.swift
//  ClosetAI
//
//  Created by Rakesh on 08/08/26.
//

import SwiftUI

struct AuthenticationView: View {

    @State private var viewModel: AuthenticationViewModel

    init(viewModel: AuthenticationViewModel) {
        _viewModel = State(
            initialValue: viewModel
        )
    }

    var body: some View {
        ZStack {
            background

            content
        }
        .alert(
            "Sign In Failed",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.clearError()
                    }
                }
            )
        ) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(
                viewModel.errorMessage
                ?? "Something went wrong. Please try again."
            )
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 0) {

            Spacer()

            logoSection

            Spacer()

            signInSection

            Spacer()

            legalSection
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }

    // MARK: - Logo

    private var logoSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "tshirt.fill")
                .font(.system(size: 56))
                .foregroundStyle(.primary)
                .accessibilityHidden(true)

            Text("ClosetAI")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your intelligent wardrobe")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Sign In

    private var signInSection: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await viewModel.signInWithApple()
                }
            } label: {
                HStack(spacing: 12) {
                    if viewModel.isSigningIn {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "apple.logo")
                            .font(.headline)
                    }

                    Text(
                        viewModel.isSigningIn
                        ? "Signing In..."
                        : "Sign in with Apple"
                    )
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSigningIn)
            .accessibilityLabel("Sign in with Apple")
        }
    }

    // MARK: - Legal

    private var legalSection: some View {
        Text("By continuing, you agree to our Terms of Service and Privacy Policy.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
    }
}

