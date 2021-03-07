//
//  WebPEncoder+CIImage.swift
//  Mughal
//
//  Created by Cordt Zermin on 07.03.21.
//

import CoreImage
import CWebP


extension WebPEncoder {
    
    /// Encodes CIImage represented images to WebP images
    public static func encode(_ image: CIImage, config: WebPConfig, width: Int = 0, height: Int = 0) throws -> Data {
        guard let cgImage = convertToCGImageWithRGBA(image) else { throw ImageProcessingError.conversionFailed }
        
        let stride = cgImage.bytesPerRow
        let webPData = try encode(RGBA: unsafeMutablePointer(from: cgImage), config: config,
                                  originWidth: Int(image.extent.maxX), originHeight: Int(image.extent.maxY), stride: stride,
                                  resizeWidth: width, resizeHeight: height)
        return webPData
    }

    

    private static func convertToCGImageWithRGBA(_ image: CIImage) -> CGImage? {
        guard let inputCGImage = convertCIImageToCGImage(inputImage: image) else { return nil }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(data: nil, width: Int(image.extent.maxX), height: Int(image.extent.maxY),
                                      bitsPerComponent: 8, bytesPerRow: Int(image.extent.maxX) * 4,
                                      space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }

        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: image.extent.maxX, height: image.extent.maxY))
        guard let cgImage = context.makeImage() else { return nil }

        return cgImage
    }
    
    private static func unsafeMutablePointer(from: CGImage) throws -> UnsafeMutablePointer<UInt8> {
        guard let dataProvider = from.dataProvider,
              let data = dataProvider.data
        else {
            throw ImageProcessingError.loadingFailed
        }
        
        let mutableData = data as! CFMutableData
        return CFDataGetMutableBytePtr(mutableData)
    }
    
    private static func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
}
