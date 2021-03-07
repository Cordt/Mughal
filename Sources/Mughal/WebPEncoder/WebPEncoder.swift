//
//  WebPEncoder.swift
//  Mughal
//
//  Created by Cordt Zermin on 05.03.21.
//
//  Comments are taken from the mapped library at https://github.com/webmproject/libwebp

import Foundation
import CWebP


/// Wrapper for CWebP.WebPEncode
///
/// These convenience functions wrap the WebPEncode function, that encodes the picture to the WebP format.
///
/// Main encoding call, after config and picture have been initialized.
/// 'picture' must be less than 16384x16384 in dimension (cf WEBP_MAX_DIMENSION),
/// and the 'config' object must be a valid one.
/// Returns false in case of error, true otherwise.
/// In case of error, picture->error_code is updated accordingly.
/// 'picture' can hold the source samples in both YUV(A) or ARGB input, depending
/// on the value of 'picture->use_argb'. It is highly recommended to use
/// the former for lossy encoding, and the latter for lossless encoding
/// (when config.lossless is true). Automatic conversion from one format to
/// another is provided but they both incur some loss.
public struct WebPEncoder {
    typealias WebPPictureImporter = (UnsafeMutablePointer<WebPPicture>, UnsafeMutablePointer<UInt8>, Int32) -> Int32
    
    /// Encodes a picture from RGB format to WebP
    static func encode(RGB: UnsafeMutablePointer<UInt8>, config: WebPConfig,
                       originWidth: Int, originHeight: Int, stride: Int,
                       resizeWidth: Int = 0, resizeHeight: Int = 0) throws -> Data {
        let importer: WebPPictureImporter = { picturePtr, data, stride in
            return WebPPictureImportRGB(picturePtr, data, stride)
        }
        return try encode(RGB, importer: importer, config: config, originWidth: originWidth, originHeight: originHeight, stride: stride)
    }
    
    /// Encodes a picture from RGBA format to WebP
    static func encode(RGBA: UnsafeMutablePointer<UInt8>, config: WebPConfig,
                       originWidth: Int, originHeight: Int, stride: Int,
                       resizeWidth: Int = 0, resizeHeight: Int = 0) throws -> Data {
        let importer: WebPPictureImporter = { picturePtr, data, stride in
            return WebPPictureImportRGBA(picturePtr, data, stride)
        }
        return try encode(RGBA, importer: importer, config: config, originWidth: originWidth, originHeight: originHeight, stride: stride)
    }
    
    private static func encode(_ dataPtr: UnsafeMutablePointer<UInt8>, importer: WebPPictureImporter,
                        config: WebPConfig, originWidth: Int, originHeight: Int, stride: Int,
                        resizeWidth: Int = 0, resizeHeight: Int = 0) throws -> Data {

        var config = config.rawValue
        var picture = WebPPicture()
        
        guard WebPValidateConfig(&config) != 0 else { throw WebPEncodingError.invalidConfiguration }
        guard WebPPictureInit(&picture) != 0 else { throw WebPEncodingError.outOfMemory }
        
        picture.use_argb = config.lossless == 0 ? 0 : 1
        picture.width = Int32(originWidth)
        picture.height = Int32(originHeight)
        
        let ok = importer(&picture, dataPtr, Int32(stride))
        guard ok != 0 else {
            WebPPictureFree(&picture)
            throw WebPEncodingError.invalidConfiguration
        }
        
        if resizeHeight > 0 && resizeWidth > 0 {
            guard (WebPPictureRescale(&picture, Int32(resizeWidth), Int32(resizeHeight)) != 0) else { throw WebPEncodingError.invalidConfiguration }
        }
        
        var buffer = WebPMemoryWriter()
        WebPMemoryWriterInit(&buffer)
        let writeWebP: @convention(c) (UnsafePointer<UInt8>?, Int, UnsafePointer<WebPPicture>?) -> Int32 = { (data, size, picture) -> Int32 in
            return WebPMemoryWrite(data, size, picture)
        }
        picture.writer = writeWebP
        
        withUnsafeMutablePointer(to: &buffer) { pointer in
            picture.custom_ptr = UnsafeMutableRawPointer(pointer)
        }
        
        guard WebPEncode(&config, &picture) != 0 else {
            WebPPictureFree(&picture)
            throw WebPEncodingError.abort
        }
        WebPPictureFree(&picture)
        
        return Data(bytesNoCopy: buffer.mem, count: buffer.size, deallocator: .free)
    }
}

