//
//  ScanView.swift
//  Short-Supply-medicine-Locater-iOS
//
//  Created by COBSCCOMP25.1P-404 on 2026-10-24.
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
        List {
            Section {
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ContentUnavailableView("Scan a medicine box",
                                           systemImage: "text.viewfinder",
                                           description: Text("Use a clear photo of the front of the box. The photo is read on this iPhone and never uploaded."))
                }
            }

            Section {
                // Only show the camera if this device has one (the simulator doesn't).
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button {
                        showingCamera = true
                    } label: {
                        Label("Take photo", systemImage: "camera")
                    }
                }
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("Choose from Photos", systemImage: "photo.on.rectangle")
                }
            }

            resultSection
        }
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

    @ViewBuilder
    private var resultSection: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()

        case .scanning:
            Section {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Reading the box…").foregroundStyle(.secondary)
                }
            }

        case .found(let suggestion):
            Section {
                ForEach(suggestion.names, id: \.self) { name in
                    Button {
                        onPick(name, suggestion.strength)
                        dismiss()
                    } label: {
                        HStack {
                            Text(name).font(.body.weight(.medium))
                            if let strength = suggestion.strength {
                                Text(strength).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.right.circle")
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .foregroundStyle(.primary)
                }
            } header: {
                Text("Is it one of these?")
            } footer: {
                if let barcode = suggestion.barcode {
                    Text("Barcode \(barcode) detected. Barcode lookup isn't available yet, so choose the name above.")
                }
            }

        case .failed(let message):
            Section {
                Label(message, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(Theme.warning)
            }
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
