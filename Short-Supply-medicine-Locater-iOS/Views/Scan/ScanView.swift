//
//  ScanView.swift
//  Short-Supply-medicine-Locater-iOS
//
//
//  ScanView.swift
//  Short-Supply-medicine-Locater-iOS
//

import SwiftUI
import PhotosUI
import UIKit
import ImageIO

/// Scan a medicine box from Photos (simulator + device) or the camera (device only).
struct ScanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ScanViewModel
    @State private var photoItem: PhotosPickerItem?
    @State private var previewImage: UIImage?
    @State private var showingCamera = false

    /// Called when the user taps a suggested name.
    let onPick: (_ name: String, _ strength: String?) -> Void

    init(viewModel: ScanViewModel, onPick: @escaping (_ name: String, _ strength: String?) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onPick = onPick
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                viewfinder
                sourceButtons
                result
            }
            .padding(20)
        }
        .screenBackground()
        .navigationTitle("Scan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .onChange(of: photoItem) { _, item in
            Task { await load(item) }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraPicker { image in
                Task { await scan(image) }
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Viewfinder (dark box + coral corners)

    private var viewfinder: some View {
        ZStack {
            Color.black.opacity(0.88)

            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .accessibilityLabel("Photo of the medicine box")
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 44, weight: .semibold))
                    Text("Scan a medicine box")
                        .font(.cardTitle)
                    Text("Use a clear photo of the front. It's read on this iPhone and never uploaded.")
                        .font(.footnote)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.white)
                .padding(32)
            }

            CornerBrackets()
                .stroke(Theme.coral, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .padding(18)
                .accessibilityHidden(true)
        }
        .frame(height: 260)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
    }

    // MARK: - Camera / Photos buttons

    private var sourceButtons: some View {
        VStack(spacing: 12) {
            // Only show the camera if this device has one (the simulator doesn't).
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button {
                    showingCamera = true
                } label: {
                    Label("Take photo", systemImage: "camera.fill")
                }
                .buttonStyle(.primaryPill)
            }
            PhotosPicker(selection: $photoItem, matching: .images) {
                Label("Choose from Photos", systemImage: "photo.on.rectangle")
            }
            .buttonStyle(.tealPill)
        }
    }

    // MARK: - Result

    @ViewBuilder
    private var result: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()

        case .scanning:
            HStack(spacing: 12) {
                ProgressView()
                Text("Reading the box…").foregroundStyle(.secondary)
            }
            .cardStyle()

        case .found(let suggestion):
            Text("Is it one of these?").font(.sectionTitle)

            ForEach(suggestion.names, id: \.self) { name in
                Button {
                    onPick(name, suggestion.strength)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        IconTile(systemImage: "pills.fill")
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name).font(.cardTitle)
                            if let strength = suggestion.strength {
                                Text(strength).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.accent)
                    }
                    .cardStyle(padding: 14)
                }
                .buttonStyle(.plain)
            }

            if let barcode = suggestion.barcode {
                Text("Barcode \(barcode) detected. Barcode lookup isn't available yet, so choose the name above.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

        case .failed(let message):
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.warning)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.warningTint,
                            in: RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        }
    }

    // MARK: - Getting the image (UI work, so it lives in the View)

    private func load(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        await scan(image)
    }

    private func scan(_ image: UIImage) async {
        previewImage = image
        guard let cgImage = image.cgImage else { return }
        await viewModel.scan(cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))
    }
}