//
//  Mughal.swift
//  Mughal
//
//  Created by Cordt Zermin on 05.03.21.
//

import Foundation
import CoreImage
import CWebP

func generateWebP(image url: URL, _ completion: @escaping (Data?) -> ()) {
    let queue = DispatchQueue(label: "mughal.image-processing")
    
    queue.async {
        do {
            print("Starting to convert image to WebP")
            let image = CIImage(contentsOf: url)!
            let imageData = try WebPEncoder.encode(image, config: .preset(.picture, quality: 75))
            print("Finished encoding image to WebP")
            
            completion(imageData)
            
        } catch let error {
            print(error)
            completion(nil)
        }
    }
}
