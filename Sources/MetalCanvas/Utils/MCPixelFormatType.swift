//
//  MCTexture+PixelFormatType.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2020/04/04.
//  Copyright © 2020 hideyuki machida. All rights reserved.
//

import CoreVideo

public enum MCPixelFormatType: Int {
    case kCV1Monochrome = 0
    case kCV2Indexed
    case kCV4Indexed
    case kCV8Indexed
    case kCV1IndexedGray_WhiteIsZero
    case kCV2IndexedGray_WhiteIsZero
    case kCV4IndexedGray_WhiteIsZero
    case kCV8IndexedGray_WhiteIsZero
    case kCV16BE555
    case kCV16LE555
    case kCV16LE5551
    case kCV16BE565
    case kCV16LE565
    case kCV24RGB
    case kCV24BGR
    case kCV32ARGB
    case kCV32BGRA
    case kCV32ABGR
    case kCV32RGBA
    case kCV64ARGB
    case kCV48RGB
    case kCV32AlphaGray
    case kCV16Gray
    case kCV30RGB
    case kCV422YpCbCr8
    case kCV4444YpCbCrA8
    case kCV4444YpCbCrA8R
    case kCV4444AYpCbCr8
    case kCV4444AYpCbCr16
    case kCV444YpCbCr8
    case kCV422YpCbCr16
    case kCV422YpCbCr10
    case kCV444YpCbCr10
    case kCV420YpCbCr8Planar
    case kCV420YpCbCr8PlanarFullRange
    case kCV422YpCbCr_4A_8BiPlanar
    case kCV420YpCbCr8BiPlanarVideoRange
    case kCV420YpCbCr8BiPlanarFullRange
    case kCV422YpCbCr8_yuvs
    case kCV422YpCbCr8FullRange
    case kCVOneComponent8
    case kCVTwoComponent8
    case kCV30RGBLEPackedWideGamut
    case kCVARGB2101010LEPacked
    case kCVOneComponent16Half
    case kCVOneComponent32Float
    case kCVTwoComponent16Half
    case kCVTwoComponent32Float
    case kCV64RGBAHalf
    case kCV128RGBAFloat
    case kCV14Bayer_GRBG
    case kCV14Bayer_RGGB
    case kCV14Bayer_BGGR
    case kCV14Bayer_GBRG
    case kCVDisparityFloat16
    case kCVDisparityFloat32
    case kCVDepthFloat16
    case kCVDepthFloat32
    case kCV420YpCbCr10BiPlanarVideoRange
    case kCV422YpCbCr10BiPlanarVideoRange
    case kCV444YpCbCr10BiPlanarVideoRange
    case kCV420YpCbCr10BiPlanarFullRange
    case kCV422YpCbCr10BiPlanarFullRange
    case kCV444YpCbCr10BiPlanarFullRange
    case kCV420YpCbCr8VideoRange_8A_TriPlanar

    public var osType: OSType {
        switch self{
        case .kCV1Monochrome: return kCVPixelFormatType_1Monochrome /* 1 bit indexed */
        case .kCV2Indexed: return kCVPixelFormatType_2Indexed /* 2 bit indexed */
        case .kCV4Indexed: return kCVPixelFormatType_4Indexed /* 4 bit indexed */
        case .kCV8Indexed: return kCVPixelFormatType_8Indexed /* 8 bit indexed */
        case .kCV1IndexedGray_WhiteIsZero: return kCVPixelFormatType_1IndexedGray_WhiteIsZero /* 1 bit indexed gray, white is zero */
        case .kCV2IndexedGray_WhiteIsZero: return kCVPixelFormatType_2IndexedGray_WhiteIsZero /* 2 bit indexed gray, white is zero */
        case .kCV4IndexedGray_WhiteIsZero: return kCVPixelFormatType_4IndexedGray_WhiteIsZero /* 4 bit indexed gray, white is zero */
        case .kCV8IndexedGray_WhiteIsZero: return kCVPixelFormatType_8IndexedGray_WhiteIsZero /* 8 bit indexed gray, white is zero */
        case .kCV16BE555: return kCVPixelFormatType_16BE555 /* 16 bit BE RGB 555 */
        case .kCV16LE555: return kCVPixelFormatType_16LE555 /* 16 bit LE RGB 555 */
        case .kCV16LE5551: return kCVPixelFormatType_16LE5551 /* 16 bit LE RGB 5551 */
        case .kCV16BE565: return kCVPixelFormatType_16BE565 /* 16 bit BE RGB 565 */
        case .kCV16LE565: return kCVPixelFormatType_16LE565 /* 16 bit LE RGB 565 */
        case .kCV24RGB: return kCVPixelFormatType_24RGB /* 24 bit RGB */
        case .kCV24BGR: return kCVPixelFormatType_24BGR /* 24 bit BGR */
        case .kCV32ARGB: return kCVPixelFormatType_32ARGB /* 32 bit ARGB */
        case .kCV32BGRA: return kCVPixelFormatType_32BGRA /* 32 bit BGRA */
        case .kCV32ABGR: return kCVPixelFormatType_32ABGR /* 32 bit ABGR */
        case .kCV32RGBA: return kCVPixelFormatType_32RGBA /* 32 bit RGBA */
        case .kCV64ARGB: return kCVPixelFormatType_64ARGB /* 64 bit ARGB, 16-bit big-endian samples */
        case .kCV48RGB: return kCVPixelFormatType_48RGB /* 48 bit RGB, 16-bit big-endian samples */
        case .kCV32AlphaGray: return kCVPixelFormatType_32AlphaGray /* 32 bit AlphaGray, 16-bit big-endian samples, black is zero */
        case .kCV16Gray: return kCVPixelFormatType_16Gray /* 16 bit Grayscale, 16-bit big-endian samples, black is zero */
        case .kCV30RGB: return kCVPixelFormatType_30RGB /* 30 bit RGB, 10-bit big-endian samples, 2 unused padding bits (at least significant end). */
        case .kCV422YpCbCr8: return kCVPixelFormatType_422YpCbCr8 /* Component Y'CbCr 8-bit 4:2:2, ordered Cb Y'0 Cr Y'1 */
        case .kCV4444YpCbCrA8: return kCVPixelFormatType_4444YpCbCrA8 /* Component Y'CbCrA 8-bit 4:4:4:4, ordered Cb Y' Cr A */
        case .kCV4444YpCbCrA8R: return kCVPixelFormatType_4444YpCbCrA8R /* Component Y'CbCrA 8-bit 4:4:4:4, rendering format. full range alpha, zero biased YUV, ordered A Y' Cb Cr */
        case .kCV4444AYpCbCr8: return kCVPixelFormatType_4444AYpCbCr8 /* Component Y'CbCrA 8-bit 4:4:4:4, ordered A Y' Cb Cr, full range alpha, video range Y'CbCr. */
        case .kCV4444AYpCbCr16: return kCVPixelFormatType_4444AYpCbCr16 /* Component Y'CbCrA 16-bit 4:4:4:4, ordered A Y' Cb Cr, full range alpha, video range Y'CbCr, 16-bit little-endian samples. */
        case .kCV444YpCbCr8: return kCVPixelFormatType_444YpCbCr8 /* Component Y'CbCr 8-bit 4:4:4 */
        case .kCV422YpCbCr16: return kCVPixelFormatType_422YpCbCr16 /* Component Y'CbCr 10,12,14,16-bit 4:2:2 */
        case .kCV422YpCbCr10: return kCVPixelFormatType_422YpCbCr10 /* Component Y'CbCr 10-bit 4:2:2 */
        case .kCV444YpCbCr10: return kCVPixelFormatType_444YpCbCr10 /* Component Y'CbCr 10-bit 4:4:4 */
        case .kCV420YpCbCr8Planar: return kCVPixelFormatType_420YpCbCr8Planar /* Planar Component Y'CbCr 8-bit 4:2:0.  baseAddr points to a big-endian CVPlanarPixelBufferInfo_YCbCrPlanar struct */
        case .kCV420YpCbCr8PlanarFullRange: return kCVPixelFormatType_420YpCbCr8PlanarFullRange /* Planar Component Y'CbCr 8-bit 4:2:0, full range.  baseAddr points to a big-endian CVPlanarPixelBufferInfo_YCbCrPlanar struct */
        case .kCV422YpCbCr_4A_8BiPlanar: return kCVPixelFormatType_422YpCbCr_4A_8BiPlanar /* First plane: Video-range Component Y'CbCr 8-bit 4:2:2, ordered Cb Y'0 Cr Y'1; second plane: alpha 8-bit 0-255 */
        case .kCV420YpCbCr8BiPlanarVideoRange: return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange /* Bi-Planar Component Y'CbCr 8-bit 4:2:0, video-range (luma=[16,235] chroma=[16,240]).  baseAddr points to a big-endian CVPlanarPixelBufferInfo_YCbCrBiPlanar struct */
        case .kCV420YpCbCr8BiPlanarFullRange: return kCVPixelFormatType_420YpCbCr8BiPlanarFullRange /* Bi-Planar Component Y'CbCr 8-bit 4:2:0, full-range (luma=[0,255] chroma=[1,255]).  baseAddr points to a big-endian CVPlanarPixelBufferInfo_YCbCrBiPlanar struct */
        case .kCV422YpCbCr8_yuvs: return kCVPixelFormatType_422YpCbCr8_yuvs /* Component Y'CbCr 8-bit 4:2:2, ordered Y'0 Cb Y'1 Cr */
        case .kCV422YpCbCr8FullRange: return kCVPixelFormatType_422YpCbCr8FullRange /* Component Y'CbCr 8-bit 4:2:2, full range, ordered Y'0 Cb Y'1 Cr */
        case .kCVOneComponent8: return kCVPixelFormatType_OneComponent8 /* 8 bit one component, black is zero */
        case .kCVTwoComponent8: return kCVPixelFormatType_TwoComponent8 /* 8 bit two component, black is zero */
        case .kCV30RGBLEPackedWideGamut: return kCVPixelFormatType_30RGBLEPackedWideGamut /* little-endian RGB101010, 2 MSB are zero, wide-gamut (384-895) */
        case .kCVARGB2101010LEPacked: return kCVPixelFormatType_ARGB2101010LEPacked /* little-endian ARGB2101010 full-range ARGB */
        case .kCVOneComponent16Half: return kCVPixelFormatType_OneComponent16Half /* 16 bit one component IEEE half-precision float, 16-bit little-endian samples */
        case .kCVOneComponent32Float: return kCVPixelFormatType_OneComponent32Float /* 32 bit one component IEEE float, 32-bit little-endian samples */
        case .kCVTwoComponent16Half: return kCVPixelFormatType_TwoComponent16Half /* 16 bit two component IEEE half-precision float, 16-bit little-endian samples */
        case .kCVTwoComponent32Float: return kCVPixelFormatType_TwoComponent32Float /* 32 bit two component IEEE float, 32-bit little-endian samples */
        case .kCV64RGBAHalf: return kCVPixelFormatType_64RGBAHalf /* 64 bit RGBA IEEE half-precision float, 16-bit little-endian samples */
        case .kCV128RGBAFloat: return kCVPixelFormatType_128RGBAFloat /* 128 bit RGBA IEEE float, 32-bit little-endian samples */
        case .kCV14Bayer_GRBG: return kCVPixelFormatType_14Bayer_GRBG /* Bayer 14-bit Little-Endian, packed in 16-bits, ordered G R G R... alternating with B G B G... */
        case .kCV14Bayer_RGGB: return kCVPixelFormatType_14Bayer_RGGB /* Bayer 14-bit Little-Endian, packed in 16-bits, ordered R G R G... alternating with G B G B... */
        case .kCV14Bayer_BGGR: return kCVPixelFormatType_14Bayer_BGGR /* Bayer 14-bit Little-Endian, packed in 16-bits, ordered B G B G... alternating with G R G R... */
        case .kCV14Bayer_GBRG: return kCVPixelFormatType_14Bayer_GBRG /* Bayer 14-bit Little-Endian, packed in 16-bits, ordered G B G B... alternating with R G R G... */
        case .kCVDisparityFloat16: return kCVPixelFormatType_DisparityFloat16 /* IEEE754-2008 binary16 (half float), describing the normalized shift when comparing two images. Units are 1/meters: ( pixelShift / (pixelFocalLength * baselineInMeters) ) */
        case .kCVDisparityFloat32: return kCVPixelFormatType_DisparityFloat32 /* IEEE754-2008 binary32 float, describing the normalized shift when comparing two images. Units are 1/meters: ( pixelShift / (pixelFocalLength * baselineInMeters) ) */
        case .kCVDepthFloat16: return kCVPixelFormatType_DepthFloat16 /* IEEE754-2008 binary16 (half float), describing the depth (distance to an object) in meters */
        case .kCVDepthFloat32: return kCVPixelFormatType_DepthFloat32 /* IEEE754-2008 binary32 float, describing the depth (distance to an object) in meters */
        case .kCV420YpCbCr10BiPlanarVideoRange: return kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange /* 2 plane YCbCr10 4:2:0, each 10 bits in the MSBs of 16bits, video-range (luma=[64,940] chroma=[64,960]) */
        case .kCV422YpCbCr10BiPlanarVideoRange: return kCVPixelFormatType_422YpCbCr10BiPlanarVideoRange /* 2 plane YCbCr10 4:2:2, each 10 bits in the MSBs of 16bits, video-range (luma=[64,940] chroma=[64,960]) */
        case .kCV444YpCbCr10BiPlanarVideoRange: return kCVPixelFormatType_444YpCbCr10BiPlanarVideoRange /* 2 plane YCbCr10 4:4:4, each 10 bits in the MSBs of 16bits, video-range (luma=[64,940] chroma=[64,960]) */
        case .kCV420YpCbCr10BiPlanarFullRange: return kCVPixelFormatType_420YpCbCr10BiPlanarFullRange /* 2 plane YCbCr10 4:2:0, each 10 bits in the MSBs of 16bits, full-range (Y range 0-1023) */
        case .kCV422YpCbCr10BiPlanarFullRange: return kCVPixelFormatType_422YpCbCr10BiPlanarFullRange /* 2 plane YCbCr10 4:2:2, each 10 bits in the MSBs of 16bits, full-range (Y range 0-1023) */
        case .kCV444YpCbCr10BiPlanarFullRange: return kCVPixelFormatType_444YpCbCr10BiPlanarFullRange /* 2 plane YCbCr10 4:4:4, each 10 bits in the MSBs of 16bits, full-range (Y range 0-1023) */
        case .kCV420YpCbCr8VideoRange_8A_TriPlanar: return kCVPixelFormatType_420YpCbCr8VideoRange_8A_TriPlanar /* first and second planes as per 420YpCbCr8BiPlanarVideoRange (420v), alpha 8 bits in third plane full-range.  No CVPlanarPixelBufferInfo struct. */
        }
    }
}
