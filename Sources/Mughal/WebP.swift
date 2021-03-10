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
    public static func generateWebP(with quality: Quality, from urls: [URL]) -> Parallel<[Image]> {
        let queue = DispatchQueue(label: "mughal.image-processing")
        let group = DispatchGroup()
        
        struct ImageConfiguration {
            struct Config {
                var sizeClass: SizeClass
                var dimensions: (Int, Int)
                var imageConfig: WebPConfig
            }
            var image: CIImage
            var fileName: String
            var configurations: [Config]
        }
        
        // Group core image with image file name
        let imageConfigurations: [ImageConfiguration] = urls.compactMap { url in
            let imageName = url.lastPathComponent.split(separator: ".").first.map { String($0) }
            guard let ciImage = CIImage.init(contentsOf: url),
                  let honestImageName = imageName else {
                return nil
            }
            
            // Create one image for each size class
            let configurations: [ImageConfiguration.Config] = SizeClass.allCases.map { sizeClass in
                let newSize = sizeClass.sizeThatFits(for: (ciImage.extent.width, ciImage.extent.height))
                var config: WebPConfig = .preset(.picture, quality: quality.webPQuality)
                if quality == .lossLess { config.lossless = 1 }
                return ImageConfiguration.Config(sizeClass: sizeClass, dimensions: newSize, imageConfig: config)
            }

            return ImageConfiguration(image: ciImage, fileName: honestImageName, configurations: configurations)
        }

        var images: [Image] = [Image]()
        
        imageConfigurations.forEach { imageConfig in
            group.enter()
            queue.async {
                do {
                    try imageConfig.configurations.forEach { config in
                        let data = try WebPEncoder.encode(imageConfig.image, config: config.imageConfig, width: config.dimensions.0, height: config.dimensions.1)
                        images.append(Image(name: imageConfig.fileName, extension: .webP, imageData: data, sizeClass: config.sizeClass))
                    }
                    group.leave()
                    
                } catch let error {
                    print(error)
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
    
    public static func generateWebP(with quality: Quality, from urls: URL...) -> Parallel<[Image]> {
        generateWebP(with: quality, from: urls)
    }
}
