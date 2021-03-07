//
//  WebPPreset.swift
//  Mughal
//
//  Created by Cordt Zermin on 06.03.21.
//
//  Comments are taken from the mapped library at https://github.com/webmproject/libwebp

import Foundation
import CWebP


/// Mapping of CWebP.WebPPreset
///
/// Enumerate some predefined settings for WebPConfig, depending on the type
/// of source picture. These presets are used when calling WebPConfigPreset().
public enum WebPPreset {
    /// default preset.
    case `default`
    /// digital picture, like portrait, inner shot
    case picture
    /// outdoor photograph, with natural lighting
    case photo
    /// hand or line drawing, with high-contrast details
    case drawing
    /// small-sized colorful images
    case icon
    /// text-like
    case text
    
    func webPConfig(quality: Float) -> CWebP.WebPConfig {
        var config = CWebP.WebPConfig()
        
        switch self {
        case .default:
            WebPConfigPreset(&config, WEBP_PRESET_DEFAULT, quality)
        case .picture:
            WebPConfigPreset(&config, WEBP_PRESET_PICTURE, quality)
        case .photo:
            WebPConfigPreset(&config, WEBP_PRESET_PHOTO, quality)
        case .drawing:
            WebPConfigPreset(&config, WEBP_PRESET_DRAWING, quality)
        case .icon:
            WebPConfigPreset(&config, WEBP_PRESET_ICON, quality)
        case .text:
            WebPConfigPreset(&config, WEBP_PRESET_TEXT, quality)
        }
        
        return config
    }
}
