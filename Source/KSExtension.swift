//
//  KSExtension.swift
//  KSMediaPickerDemo
//
//  Created by kinsun on 2019/4/29.
//  Copyright © 2019年 kinsun. All rights reserved.
//

import UIKit

extension String {

    public var ks_KeyToLocalized: String {
        return ks_KeyToLocalized(in: Bundle.main)
    }
    
    public var ks_mediaPickerKeyToLocalized: String {
        return ks_mediaPickerKeyToLocalized(in: Bundle.main)
    }
    
    public func ks_mediaPickerKeyToLocalized(in bundle: Bundle, table: String? = "KSMediaPicker") -> String {
        return ks_KeyToLocalized(in: bundle, table: table)
    }
    
    public func ks_KeyToLocalized(in bundle: Bundle, table: String? = nil) -> String {
        return bundle.localizedString(forKey: self, value: nil, table: table)
    }
    
}

extension UIEdgeInsets {
    
    static public let safeAreaInsets = {() -> UIEdgeInsets in
        let safeAreaInsets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        } else {
            safeAreaInsets = .zero
        }
        return safeAreaInsets
    }()
    
}

extension UIView {
    
    public static let statusBarSize = UIApplication.shared.statusBarFrame.size
    public static let navigationBarSize = CGSize(width: statusBarSize.width, height: 44.0)
    public static let statusBarNavigationBarSize = {() -> CGSize in
        var size = statusBarSize
        size.height += navigationBarSize.height
        return size
    }()
    
    open var renderingImage: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        let image: UIImage?
        if let ctx = UIGraphicsGetCurrentContext() {
            layer.render(in: ctx)
            image = UIGraphicsGetImageFromCurrentImageContext()
        } else {
            image = nil
        }
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension UIImage {
    
    static public let ks_defaultPlaceholder = UIImage(named: "img_default_placeholder")!
    
    public convenience init(JPEGData: Data, of cutSizeProportion: CGSize) {
        let dataRef = CFBridgingRetain(JPEGData) as! CFData
        let source = CGImageSourceCreateWithData(dataRef, nil)!
        let imageInfoRef = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)!
        let pixelHeightKey = Unmanaged.passRetained(NSString(string: "PixelHeight")).autorelease().toOpaque()
        let pixelWidthKey = Unmanaged.passRetained(NSString(string: "PixelWidth")).autorelease().toOpaque()
        let pixelHeightPoint = CFDictionaryGetValue(imageInfoRef, pixelHeightKey)!
        let pixelWidthPoint = CFDictionaryGetValue(imageInfoRef, pixelWidthKey)!
        let windowHeight = CGFloat(Unmanaged<NSNumber>.fromOpaque(pixelHeightPoint).takeUnretainedValue().doubleValue)
        let windowWidth = CGFloat(Unmanaged<NSNumber>.fromOpaque(pixelWidthPoint).takeUnretainedValue().doubleValue)
        let viewH = windowHeight
        let viewW = cutSizeProportion.height/cutSizeProportion.width*viewH
        let rect = CGRect(x: (windowWidth-viewW)*0.5, y: 0.0, width: viewW, height: viewH)
        let cgData = CGDataProvider(data: dataRef)!
        let cgImage = CGImage(jpegDataProviderSource: cgData, decode: nil, shouldInterpolate: true, intent: .defaultIntent)!
        let newCgImage = cgImage.cropping(to: rect)!
//        let newImageData = CFDataCreateMutable(kCFAllocatorDefault, 0)!
//        let destination = CGImageDestinationCreateWithData(newImageData, "public.jpeg" as CFString, 1, nil)!
        let newImageData = NSMutableData()
        let destination = CGImageDestinationCreateWithData(CFBridgingRetain(newImageData) as! CFMutableData, "public.jpeg" as CFString, 1, nil)!
        let newImageInfoRef = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, CFDictionaryGetCount(imageInfoRef), imageInfoRef)!
        CFDictionaryReplaceValue(newImageInfoRef, pixelHeightKey, Unmanaged.passRetained(NSNumber(value: Double(viewH))).autorelease().toOpaque())
        CFDictionaryReplaceValue(newImageInfoRef, pixelWidthKey, Unmanaged.passRetained(NSNumber(value: Double(viewW))).autorelease().toOpaque())
        CGImageDestinationAddImage(destination, newCgImage, newImageInfoRef)
        CGImageDestinationFinalize(destination)
        self.init(data: newImageData as Data)!
    }
    
    public func cut(from rect: CGRect) -> UIImage? {
        if let cgImage = self.cgImage {
            var newRect = rect
            let scale = self.scale
            newRect.origin.x *= scale
            newRect.origin.y *= scale
            newRect.size.width *= scale
            newRect.size.height *= scale
            
            if let newCgImage = cgImage.cropping(to: newRect) {
                return UIImage(cgImage: newCgImage)
            }
        }
        return nil
    }
    
    public func aspectFit(from size: CGSize, backgroundColor: UIColor = .clear) -> UIImage? {
        let imageSize = self.size
        let imageWidth = floor(imageSize.width)
        let imageHeight = floor(imageSize.height)
        let windowWidth = floor(size.width)
        let windowHeight = floor(size.height)
        if imageWidth == windowWidth, imageHeight == windowHeight {
            return self
        } else {
            let rect: CGRect
            let imageScale = imageWidth/imageHeight
            let windowScale = windowWidth/windowHeight
            if imageScale > windowScale {
                let height = floor(imageHeight*windowWidth/imageWidth)
                rect = CGRect(x: 0.0, y: (windowHeight-height)*0.5, width: windowWidth, height: height)
            } else {
                let width = floor(imageWidth*windowHeight/imageHeight)
                rect = CGRect(x: (windowWidth-width)*0.5, y: 0.0, width: width, height: windowHeight)
            }
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            let context = UIGraphicsGetCurrentContext()
            //        CGContextScaleCTM(context, scale, scale)
            context?.setFillColor(backgroundColor.cgColor)
            context?.addRect(CGRect(origin: .zero, size: size))
            context?.drawPath(using: .fill)
            draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
    }
    
    public func resize(_ newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public func equalResize(sideLength: CGFloat) -> UIImage? {
        let size = self.size
        let width = size.width
        let height = size.height
        let newSize: CGSize
        if width == height {
            newSize = CGSize(width: sideLength, height: sideLength)
        } else if width > height {
            newSize = CGSize(width: width/height*sideLength, height: sideLength)
        } else {
            newSize = CGSize(width: sideLength, height: height/width*sideLength)
        }
        return resize(newSize)
    }
}

extension UIColor {
    
    public static let ks_wordMain = UIColor(red: 44/255.0, green: 41/255.0, blue: 84/255.0, alpha: 1)
    public static let ks_wordMain_2 = UIColor(red: 44/255.0, green: 41/255.0, blue: 84/255.0, alpha: 0.5)
    public static let ks_background = UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
    public static let ks_main = UIColor(red: 255/255.0, green: 84/255.0, blue: 65/255.0, alpha: 1)
    public static let ks_lightMain = UIColor(red: 240/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1)
    public static let ks_lightGray = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1)
    public static let ks_white = UIColor.white
    public static let ks_black = UIColor.black
}
