//
//  Util.swift
//  Mughal
//
//  Created by Cordt Zermin on 07.03.21.
//

import Foundation

/// Represents the desired configuration of the target image
public struct ImageConfiguration {
    public let url: URL
    public let targetExtension: Image.Extension
    public let targetDimensions: (Int, Int)
    
    public init(
        url: URL,
        targetExtension: Image.Extension,
        targetDimensions: (Int, Int)
    ) {
        precondition(url.isFileURL, "Only images from the file system can be processed")
        self.url = url
        self.targetExtension = targetExtension
        self.targetDimensions = targetDimensions
    }
    
    var fileName: String? {
        self.url
            .lastPathComponent
            .split(separator: ".")
            .first
            .map(String.init)
    }
}

/// Represents the data and metadata of an image
public struct Image {
    public enum Extension: String {
        case webp
    }
    
    /// Name of the file (w/o file extension)
    public let name: String
    public let `extension`: Extension
    public let imageData: Data
    
    public init(
        name: String,
        `extension`: Extension,
        imageData: Data
    ) {
        self.name = name
        self.`extension` = `extension`
        self.imageData = imageData
    }
}

/// Calculates Image dimensions within a given upper bound
///
/// The greater of the two dimensions will assume the upper bound
public func sizeThatFits(for original: (CGFloat, CGFloat), within upperBound: Int) -> (Int, Int) {
    if original.0 >= original.1 {
        let factor: CGFloat = CGFloat(upperBound) / original.0
        return (Int(original.0 * factor), Int(original.1 * factor))
    } else {
        let factor: CGFloat = CGFloat(upperBound) / original.1
        return (Int(original.0 * factor), Int(original.1 * factor))
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
    
    public init(run: @escaping (@escaping (A) -> Void) -> Void) {
        self.run = run
    }

    public func map<B>(_ f: @escaping (A) -> B) -> Parallel<B> {
        return Parallel<B> { callback in
            self.run { a in
                callback(f(a))
            }
        }
    }
}
