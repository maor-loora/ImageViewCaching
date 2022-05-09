//
//  AsyncCachedImage.swift
//  Loora-iOS
//
//  Created by Maor Atlas on 08/05/2022.
//
#if canImport(UIKit)

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct AsyncCachedImage<ContentPlaceholder, ContentError>: View where ContentPlaceholder: View, ContentError: View {
    @StateObject private var viewModel = AsyncCachedImageViewModel()

    private let url: URL?
    private let placeholder: () -> ContentPlaceholder?
    private let error: () -> ContentError?

    init(strUrl: String? = nil,
         @ViewBuilder placeholder: @escaping () -> ContentPlaceholder? = { nil },
         @ViewBuilder error: @escaping () -> ContentError? = { nil }
    ) {
        self.init(url: URL(string: strUrl ?? ""), placeholder: placeholder, error: error)
    }

    init(url: URL? = nil,
         @ViewBuilder placeholder: @escaping () -> ContentPlaceholder? = { nil },
         @ViewBuilder error: @escaping () -> ContentError? = { nil }
    ) {
        self.url = url
        self.placeholder = placeholder
        self.error = error
    }

    var body: some View {
        VStack {
            switch viewModel.state {
            case .initial:
                placeholderView

            case .loading:
                placeholderView

            case .loaded(let image):
                image
                    .resizable()

            case .error:
                errorView
            }
        }
        .onAppear {
            viewModel.update(with: url)
            viewModel.loadData()
        }
    }

    @ViewBuilder
    private var placeholderView: some View {
        HStack {
            if let placeholder = placeholder {
                placeholder()
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var errorView: some View {
        HStack {
            if let error = error {
                // TODO: need to find a better way to do it, to compare to nil, currently I couldn't find a way to pass nil instead of EmptyView for ViewBuilder at: "extension AsyncCachedImage where ContentError == EmptyView"
                let errorValue = error()
                if !(errorValue is EmptyView) {
                    errorValue
                } else {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private final class AsyncCachedImageViewModel: ObservableObject {

    fileprivate enum AsyncCachedState: Equatable {
        case initial
        case loading
        case loaded(image: Image)
        case error
    }

    @Published fileprivate var state: AsyncCachedState = .initial

    private var url: URL?

    fileprivate func update(with url: URL?) {
        self.url = url
    }

    fileprivate func loadData() {
        guard let url = url else {
            state = .error
            return
        }

        state = .loading

        URLCache.shared.loadImage(url: url) { [weak self] uiImage in
            guard let self = self else { return }
            guard let uiImage = uiImage else {
                DispatchQueue.main.async {
                    self.state = .error
                }
                return
            }

            let image = Image(uiImage: uiImage)
            DispatchQueue.main.async {
                self.state = .loaded(image: image)
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension AsyncCachedImage where ContentPlaceholder == EmptyView, ContentError == EmptyView {
    init(strUrl: String? = nil) {
        self.init(url: URL(string: strUrl ?? ""))
    }

    init(url: URL? = nil) {
        self.init(url: url) {
            EmptyView()
        } error: {
            EmptyView()
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension AsyncCachedImage where ContentPlaceholder == EmptyView {
    init(strUrl: String? = nil,
         @ViewBuilder error: @escaping () -> ContentError? = { nil }) {
        self.init(url: URL(string: strUrl ?? ""), error: error)
    }

    init(url: URL? = nil,
         @ViewBuilder error: @escaping () -> ContentError? = { nil }) {
        self.init(url: url) {
            EmptyView()
        } error: {
            error()
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension AsyncCachedImage where ContentError == EmptyView {
    init(strUrl: String? = nil,
         @ViewBuilder placeholder: @escaping () -> ContentPlaceholder? = { nil }) {
        self.init(url: URL(string: strUrl ?? ""), placeholder: placeholder)
    }

    init(url: URL? = nil,
         @ViewBuilder placeholder: @escaping () -> ContentPlaceholder? = { nil }) {
        self.init(url: url) {
            placeholder()
        } error: {
            EmptyView()
        }
    }
}

#endif
