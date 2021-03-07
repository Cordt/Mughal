//
//  WebPImageHint.swift
//  Mughal
//
//  Created by Cordt Zermin on 05.03.21.
//
//  Comments are taken from the mapped library at https://github.com/webmproject/libwebp

import Foundation
import CWebP


/// Mapping of CWebP.WebPImageHint
///
/// Image characteristics hint for the underlying encoder.
public enum WebPImageHint: CWebP.WebPImageHint {
    case `default` = 0
    case picture = 1
    case photo = 2
    case graph = 3
}

extension CWebP.WebPImageHint: ExpressibleByIntegerLiteral {
    
    /// Maps the raw value of the underlying type `CWebP.WebPImageHint` to `WebPImageHint`
    public init(integerLiteral value: Int) {
        switch UInt32(value) {
        case CWebP.WEBP_HINT_DEFAULT.rawValue:
            self = CWebP.WEBP_HINT_DEFAULT
            
        case CWebP.WEBP_HINT_PICTURE.rawValue:
            self = CWebP.WEBP_HINT_PICTURE
            
        case CWebP.WEBP_HINT_PHOTO.rawValue:
            self = CWebP.WEBP_HINT_PHOTO
            
        case CWebP.WEBP_HINT_GRAPH.rawValue:
            self = CWebP.WEBP_HINT_GRAPH
            
        case CWebP.WEBP_HINT_LAST.rawValue:
            self = CWebP.WEBP_HINT_LAST
            
        default:
            fatalError()
        }
    }
}
