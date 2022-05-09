//
//  UIImageView+Extension.swift
//  Loora-iOS
//
//  Created by Maor Atlas on 08/05/2022.
//

#if canImport(UIKit)

import UIKit

extension UIImageView {
    public func loadImage(fromURL url: String?,
                   placeholderImage: UIImage? = nil,
                   errorImage: UIImage? = nil,
                   completion: ((UIImage?) -> Void)? = nil) {

        guard let url = url, let imageURL = URL(string: url) else {
            if let completion = completion {
                completion(nil)
            } else {
                self.image = errorImage ?? placeholderImage
            }

            return
        }

        imageDescription = url

        if let placeholderImage = placeholderImage {
            self.image = placeholderImage
        } else {
            self.image = nil
        }

        let cache = URLCache.shared
        cache.loadImage(url: imageURL) { [weak self] image in
            DispatchQueue.main.async { [weak self] in
                if let completion = completion {
                    completion(image)
                } else if url == self?.imageDescription {
                    if let image = image {
                        self?.image = image
                    } else {
                        self?.image = errorImage ?? placeholderImage
                    }
                }
            }
        }
    }

    private struct AssociatedKeys {
        static var imageDescription: String = "UIImage._imageDescription"
    }

    private(set) var _imageDescription: String? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.imageDescription) as? String
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociatedKeys.imageDescription, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var imageDescription: String? {
        get {
            _imageDescription
        }
        set (value) {
            _imageDescription = value
        }
    }
}

#endif
