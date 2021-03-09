//
//  WebPConfig.swift
//  Mughal
//
//  Created by Cordt Zermin on 05.03.21.
//
//  Comments are taken from the mapped library at https://github.com/webmproject/libwebp

import Foundation
import CWebP


/// Mapping of CWebP.WebPConfig
///
/// Compression parameters.
struct WebPConfig {
    
    /// Lossless encoding (0=lossy(default), 1=lossless).
    var lossless: Int = 0
    
    /// between 0 and 100. For lossy, 0 gives the smallest
    /// size and 100 the largest. For lossless, this
    /// parameter is the amount of effort put into the
    /// compression: 0 is the fastest but gives larger
    /// files compared to the slowest, but best, 100.
    var quality: Float
    
    /// quality/speed trade-off (0=fast, 6=slower-better)
    var method: Int
    
    /// Hint for image type (lossless only for now).
    var imageHint: WebPImageHint = .default
    
    /// if non-zero, set the desired target size in bytes.
    /// Takes precedence over the 'compression' parameter.
    var targetSize: Int = 0
    
    /// if non-zero, specifies the minimal distortion to
    /// try to achieve. Takes precedence over target_size.
    var targetPSNR: Float = 0
    
    /// maximum number of segments to use, in [1..4]
    var segments: Int
    
    /// Spatial Noise Shaping. 0=off, 100=maximum.
    var snsStrength: Int
    
    /// range: [0 = off .. 100 = strongest]
    var filterStrength: Int
    
    /// range: [0 = off .. 7 = least sharp]
    var filterSharpness: Int
    
    /// filtering type: 0 = simple, 1 = strong (only used
    /// if filter_strength > 0 or autofilter > 0)
    var filterType: Int
    
    /// Auto adjust filter's strength [0 = off, 1 = on]
    var autofilter: Int
    
    /// Algorithm for encoding the alpha plane (0 = none,
    /// 1 = compressed with WebP lossless). Default is 1.
    var alphaCompression: Int = 1
    
    /// Predictive filtering method for alpha plane.
    /// 0: none, 1: fast, 2: best. Default if 1.
    var alphaFiltering: Int
    
    /// Between 0 (smallest size) and 100 (lossless).
    /// Default is 100.
    var alphaQuality: Int = 100
    
    /// number of entropy-analysis passes (in [1..10]).
    var pass: Int
    
    /// if true, export the compressed picture back.
    /// In-loop filtering is not applied.
    var showCompressed: Bool
    
    /// preprocessing filter:
    /// 0=none, 1=segment-smooth, 2=pseudo-random dithering
    var preprocessing: Int
    
    /// log2(number of token partitions) in [0..3]. Default
    /// is set to 0 for easier progressive decoding.
    var partitions: Int = 0
    
    /// quality degradation allowed to fit the 512k limit
    /// on prediction modes coding (0: no degradation,
    /// 100: maximum possible degradation).
    var partitionLimit: Int
    
    /// If true, compression parameters will be remapped
    /// to better match the expected output size from
    /// JPEG compression. Generally, the output size will
    /// be similar but the degradation will be lower.
    var emulateJpegSize: Bool
    
    /// If non-zero, try and use multi-threaded encoding.
    var threadLevel: Int
    
    /// If set, reduce memory usage (but increase CPU use).
    var lowMemory: Bool
    
    /// Near lossless encoding [0 = max loss .. 100 = off
    /// (default)].
    var nearLossless: Int = 100
    
    /// if non-zero, preserve the exact RGB values under
    /// transparent area. Otherwise, discard this invisible
    /// RGB information for better compression. The default
    /// value is 0.
    var exact: Int
    
    /// reserved for future lossless feature
    var useDeltaPalette: Bool
    
    /// if needed, use sharp (and slow) RGB->YUV conversion
    var useSharpYUV: Bool
    
    /// minimum permissible quality factor
    var qMin: Int32
    
    /// maximum permissible quality factor
    var qMax: Int32
    
    /// This function will initialize the configuration according to a predefined
    /// set of parameters (referred to by 'preset') and a given quality factor.
    /// This function can be called as a replacement to WebPConfigInit(). Will
    /// return false in case of error.
    static func preset(_ preset: WebPPreset, quality: Float) -> WebPConfig {
        let webPConfig = preset.webPConfig(quality: quality)
        return WebPConfig(rawValue: webPConfig)!
    }
    
    internal init?(rawValue: CWebP.WebPConfig) {
        lossless = Int(rawValue.lossless)
        quality = rawValue.quality
        method = Int(rawValue.method)
        imageHint = WebPImageHint(rawValue: rawValue.image_hint)!
        targetSize = Int(rawValue.target_size)
        targetPSNR = Float(rawValue.target_PSNR)
        segments = Int(rawValue.segments)
        snsStrength = Int(rawValue.sns_strength)
        filterStrength = Int(rawValue.filter_strength)
        filterSharpness = Int(rawValue.filter_sharpness)
        filterType = Int(rawValue.filter_type)
        autofilter = Int(rawValue.autofilter)
        alphaCompression = Int(rawValue.alpha_compression)
        alphaFiltering = Int(rawValue.alpha_filtering)
        alphaQuality = Int(rawValue.alpha_quality)
        pass = Int(rawValue.pass)
        showCompressed = rawValue.show_compressed != 0 ? true : false
        preprocessing = Int(rawValue.preprocessing)
        partitions = Int(rawValue.partitions)
        partitionLimit = Int(rawValue.partition_limit)
        emulateJpegSize = rawValue.emulate_jpeg_size != 0 ? true : false
        threadLevel = Int(rawValue.thread_level)
        lowMemory = rawValue.low_memory != 0 ? true : false
        nearLossless = Int(rawValue.near_lossless)
        exact = Int(rawValue.exact)
        useDeltaPalette = rawValue.use_delta_palette != 0 ? true : false
        useSharpYUV = rawValue.use_sharp_yuv != 0 ? true : false
        qMin = rawValue.qmin
        qMax = rawValue.qmax
    }
    
    internal var rawValue: CWebP.WebPConfig {
        let show_compressed = showCompressed ? Int32(1) : Int32(0)
        let emulate_jpeg_size = emulateJpegSize ? Int32(1) : Int32(0)
        let low_memory = lowMemory ? Int32(1) : Int32(0)
        let use_delta_palette = useDeltaPalette ? Int32(1) : Int32(0)
        let use_sharp_yuv = useSharpYUV ? Int32(1) : Int32(0)
        
        return CWebP.WebPConfig(
            lossless: Int32(lossless),
            quality: Float(quality),
            method: Int32(method),
            image_hint: imageHint.rawValue,
            target_size: Int32(targetSize),
            target_PSNR: Float(targetPSNR),
            segments: Int32(segments),
            sns_strength: Int32(snsStrength),
            filter_strength: Int32(filterStrength),
            filter_sharpness: Int32(filterSharpness),
            filter_type: Int32(filterType),
            autofilter: Int32(autofilter),
            alpha_compression: Int32(alphaCompression),
            alpha_filtering: Int32(alphaFiltering),
            alpha_quality: Int32(alphaQuality),
            pass: Int32(pass),
            show_compressed: show_compressed,
            preprocessing: Int32(preprocessing),
            partitions: Int32(partitions),
            partition_limit: Int32(partitionLimit),
            emulate_jpeg_size: emulate_jpeg_size,
            thread_level: Int32(threadLevel),
            low_memory: low_memory,
            near_lossless: Int32(nearLossless),
            exact: Int32(exact),
            use_delta_palette: Int32(use_delta_palette),
            use_sharp_yuv: Int32(use_sharp_yuv),
            qmin: Int32(qMin),
            qmax: Int32(qMax)
        )
    }
    
}
