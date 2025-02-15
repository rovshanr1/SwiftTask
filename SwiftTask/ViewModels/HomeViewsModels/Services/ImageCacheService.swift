//
//  ImageCacheService.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 15.02.25.
//

import Foundation
import UIKit


class ImageCacheService {
    static let shared = ImageCacheService()
    private var imageCache = NSCache<NSString, UIImage>()

    func getImage(for key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }

    func saveImage(_ image: UIImage, for key: String) {
        imageCache.setObject(image, forKey: key as NSString)
    }
}

extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage? {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
