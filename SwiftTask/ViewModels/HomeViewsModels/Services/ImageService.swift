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
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure:
                completion(nil)
            }
        }
    }
}
