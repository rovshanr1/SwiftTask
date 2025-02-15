//
//  ImageService.swift
//  SwiftTask
//
//  Created by Rovshan Rasulov on 05.02.25.
//

import SwiftUI
import PhotosUI

class ImageService {
    static let shared = ImageService()

    func loadImage(from item: PhotosPickerItem, completion: @escaping (Data?) -> Void) {
        // Upload the photo in Data format
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data, let uiImage = UIImage(data: data) {
                    // Convert to JPEG format and compress with 80% quality
                    let jpegData = uiImage.jpegData(compressionQuality: 0.8)
                    completion(jpegData)
                } else {
                    print("Error: Could not create image from data.")
                    completion(nil)
                }
            case .failure(let error):
                //Log error status
                print("Error: Failed to upload photo - \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}


