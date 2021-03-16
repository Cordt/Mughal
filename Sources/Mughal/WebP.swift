//
//  Mughal.swift
//  Mughal
//
//  Created by Cordt Zermin on 05.03.21.
//

import Foundation
import CoreImage
import CWebP

public struct WebP {
    
    /// Generates WebP images from the image at the given URL in all available size classes
    public static func generateImages(with quality: Quality, for configurations: [ImageConfiguration]) -> Parallel<[Image]> {
        let queue = DispatchQueue(label: "mughal.image-processing")
        let group = DispatchGroup()
        
        configurations.forEach {
            precondition($0.targetExtension == .webp, "Only WebP is supported as a target extension as of now")
        }
        
        struct EncodableImage {
            var config: WebPConfig
            var image: CIImage
            var dimensions: (Int, Int)
            var name: String
            var `extension`: Image.Extension
        }
        
        // Prepare encodable images
        let encodableImages: [EncodableImage] = configurations.compactMap { config in
            guard let ciImage = CIImage.init(contentsOf: config.url),
                  let fileName = config.fileName else {
                return nil
            }
            
            var webPConfig: WebPConfig = .preset(.picture, quality: quality.webPQuality)
            if quality == .lossLess { webPConfig.lossless = 1 }
            
            return EncodableImage(
                config: webPConfig,
                image: ciImage,
                dimensions: config.targetDimensions,
                name: fileName,
                extension: config.targetExtension
            )
        }

        var images: [Image] = [Image]()
        
        encodableImages.forEach { encodableImage in
            group.enter()
            queue.async {
                do {
                    let data = try WebPEncoder.encode(
                        encodableImage.image,
                        config: encodableImage.config,
                        width: encodableImage.dimensions.0,
                        height: encodableImage.dimensions.1
                    )
                    images.append(
                        Image(
                            name: encodableImage.name,
                            extension: encodableImage.extension,
                            imageData: data
                        )
                    )
                    group.leave()
                    
                } catch let error {
                    print("Failed to encode image with error: \(error)")
                    group.leave()
                }
            }
        }
        
        switch group.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(30)) {
        case .success:
            return Parallel { $0(images) }
            
        case .timedOut:
            print("Image processing timed out - process aborted")
            return Parallel { $0([]) }
        }
    }
    
    public static func generateImages(with quality: Quality, for configurations: ImageConfiguration...) -> Parallel<[Image]> {
        generateImages(with: quality, for: configurations)
    }
}
