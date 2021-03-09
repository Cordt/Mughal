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
    public static func generateWebP(from url: URL, with quality: Quality) -> Parallel<[Image]> {
        let queue = DispatchQueue(label: "mughal.image-processing")
        let group = DispatchGroup()
        
        print("Starting to convert image to WebP")
        
        let image = CIImage(contentsOf: url)!
        let imageName = url.lastPathComponent.split(separator: ".").first.map { String($0) }
        guard let honestImageName = imageName else {
            print("Could not obtain file name from url")
            return Parallel { $0([]) }
        }
        var images: [Image] = [Image]()
        
        SizeClass.allCases.forEach { sizeClass in
            group.enter()
            queue.async {
                do {
                    let newSize = sizeClass.sizeThatFits(for: (image.extent.width, image.extent.height))
                    var config: WebPConfig = .preset(.picture, quality: quality.webPQuality)
                    if quality == .lossLess { config.lossless = 1 }
                    let imageData = try WebPEncoder.encode(image, config: config, width: newSize.0, height: newSize.1)
                    images.append(Image(name: honestImageName, extension: .webP, imageData: imageData, sizeClass: sizeClass))
                    group.leave()
                    
                } catch let error {
                    print(error)
                    group.leave()
                }
            }
        }
        
        switch group.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(5)) {
        case .success:
            print("Finished encoding images to WebP")
            return Parallel { $0(images) }
            
        case .timedOut:
            print("Image processing timed out - process aborted")
            return Parallel { $0([]) }
        }
    }
}
