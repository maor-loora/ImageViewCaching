//
//  URLCache+Extension.swift
//  Loora-iOS
//
//  Created by Maor Atlas on 08/05/2022.
//

#if canImport(UIKit)

import Foundation
import UIKit

extension URLCache {
    // returns on background thread
    public func loadImage(url: URL, completion: ((UIImage?) -> Void)? = nil) {
        loadData(url: url) { data in
            guard let data = data else {
                completion?(nil)
                return
            }

            guard let image = UIImage(data: data) else {
                NSLog("Can't convert data to image from URL \(url.absoluteString)")
                completion?(nil)
                return
            }

            completion?(image)
        }
    }

    // returns on background thread
    public func loadData(url: URL, completion: @escaping (Data?) -> Void) {
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let data = self?.cachedResponse(for: request)?.data {
                completion(data)
            } else {
                URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
                    if let data = data, let response = response,
                       ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300 {

                        let cachedData = CachedURLResponse(response: response, data: data)
                        self?.storeCachedResponse(cachedData, for: request)
                        completion(data)
                    } else {
                        completion(nil)
                        var errorText = "Can't get data from URL \(url.absoluteString) with status code "
                        errorText += "\(String(describing: (response as? HTTPURLResponse)?.statusCode))"
                        NSLog(errorText)
                    }
                }).resume()
            }
        }
    }

    public func getCachedImage(url: URL) -> UIImage? {
        guard let data = getCachedData(url: url) else {
            return nil
        }

        return UIImage(data: data)
    }

    public func getCachedData(url: URL) -> Data? {
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        guard let data = self.cachedResponse(for: request)?.data else {
            return nil
        }

        return data
    }
}

#endif
