//
//  Util.swift
//  Mughal
//
//  Created by Cordt Zermin on 07.03.21.
//

import Foundation


/// Represents the data and metadata of an image
public struct Image {
    public enum Extension: String {
        case webP
    }
    
    public let name: String
    public let `extension`: Extension
    public let imageData: Data
    public let sizeClass: SizeClass
    
    /// Saves one image for each size class at the given path
    public func save(at path: URL) {
        let url = path.appendingPathComponent("\(name)-\(sizeClass).\(`extension`)")
        do {
            try imageData.write(to: url)
            
        } catch {
            print("Failed to write images to disk")
        }
    }
}

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

/// The quality of the output picture
public enum Quality {
    /// Very low quality picture that can be used as a placeholder and takes very little space
    case placeholder
    case veryLow, low, medium, high, veryHigh, lossLess
    
    internal var webPQuality: Float {
        switch self {
        case .placeholder:  return 0
        case .veryLow:      return 20
        case .low:          return 40
        case .medium:       return 60
        case .high:         return 80
        case .veryHigh:     return 90
        // The quality parameter in the WebP encoder is overloaded with the quality of the compression algorithm
        case .lossLess:     return 75
        }
    }
}

/// Type that encapsulates  asynchronus calls to allow passing them as 'simple' types
///
/// For example, instead of using completion handlers in functions that contain async code,
/// the function can simply return a Parallel
public struct Parallel<A> {
    public let run: (@escaping (A) -> Void) -> Void

    public func map<B>(_ f: @escaping (A) -> B) -> Parallel<B> {
        return Parallel<B> { callback in
            self.run { a in
                callback(f(a))
            }
        }
    }
}
