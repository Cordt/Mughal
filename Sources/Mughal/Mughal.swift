//
//  Mughal.swift
//  Mughal
//
//  Created by Cordt Zermin on 05.03.21.
//

import Foundation
import CoreImage
import CWebP


/// Reflects 'natural' css breakpoints
///
/// See this article by David Gilbertson for reference: [The correct way to do css breakpoints](https://www.freecodecamp.org/news/the-100-correct-way-to-do-css-breakpoints-88d6a5ba1862/)
/// extraLarge is not covered, as the images are defined by their upper bound, which this size class does not have by default
public enum SizeClass: String, CaseIterable {
    case extraSmall
    case small
    case normal
    case large
    
    var upperBound: Int {
        switch self {
        case .extraSmall: return 600
        case .small: return 900
        case .normal: return 1200
        case .large: return 1800
        }
    }
    
    func sizeThatFits(for original: (CGFloat, CGFloat)) -> (Int, Int) {
        if original.0 >= original.1 {
            let factor: CGFloat = CGFloat(self.upperBound) / original.0
            return (Int(original.0 * factor), Int(original.1 * factor))
        } else {
            let factor: CGFloat = CGFloat(self.upperBound) / original.1
            return (Int(original.0 * factor), Int(original.1 * factor))
        }
    }
}

public struct WebPImage {
    let name: String
    let imageData: Data
    let sizeClass: SizeClass
    
    func save(at path: URL) {
        let url = path.appendingPathComponent("\(name)-\(sizeClass).webp")
        do {
            try imageData.write(to: url)
            
        } catch {
            print("Failed to write images to disk")
        }
    }
}

public func generateWebP(from url: URL, with quality: Float, _ completion: @escaping ([WebPImage]) -> ()) {
    let queue = DispatchQueue(label: "mughal.image-processing")
    let group = DispatchGroup()
    
    print("Starting to convert image to WebP")
    
    let image = CIImage(contentsOf: url)!
    let imageName = url.lastPathComponent.split(separator: ".").first.map { String($0) }
    guard let honestImageName = imageName else {
        print("Could not obtain file name from url")
        completion([])
        return
    }
    var images: [WebPImage] = [WebPImage]()
    
    SizeClass.allCases.forEach { sizeClass in
        group.enter()
        queue.async {
            do {
                let newSize = sizeClass.sizeThatFits(for: (image.extent.width, image.extent.height))
                let imageData = try WebPEncoder.encode(image, config: .preset(.picture, quality: quality), width: newSize.0, height: newSize.1)
                images.append(WebPImage(name: honestImageName, imageData: imageData, sizeClass: sizeClass))
                group.leave()
                
            } catch let error {
                print(error)
                group.leave()
            }
        }
    }
    
    switch group.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(5)) {
    case .success:
        completion(images)
        
    case .timedOut:
        print("Image processing timed out - process aborted")
        completion([])
    }
    
    print("Finished encoding image to WebP")
}
