//
//  WebPEncodingError.swift
//  Mughal
//
//  Created by Cordt Zermin on 05.03.21.
//
//  Comments are taken from the mapped library at https://github.com/webmproject/libwebp

import Foundation
import CWebP


/// Mapped from CWebP.WebPEncodingError
///
/// Encoding error conditions.
public enum WebPEncodingError: Int, Error {
    case ok = 0
    case outOfMemory           // memory error allocating objects
    case bitstreamOutOfMemory  // memory error while flushing bits
    case nullParameter         // a pointer parameter is NULL
    case invalidConfiguration  // configuration is invalid
    case badDimension          // picture has invalid width/height
    case partition0Overflow    // partition is bigger than 512k
    case partitionOverflow     // partition is bigger than 16M
    case badWrite              // error while flushing bytes
    case fileTooBig            // file is bigger than 4G
    case abort                 // abort request by user
    case last                  // list terminator. always last.
}
