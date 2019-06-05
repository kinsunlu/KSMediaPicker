//
//  KSMediaPickerItemModel.swift
// 
//
//  Created by kinsun on 2019/3/1.
//

import UIKit
import Photos

open class KSMediaPickerItemModel: NSObject {
    
    @objc public static let thumbSize = {() -> CGSize in
        let screen = UIScreen.main
        let width = screen.bounds.size.width*screen.scale*0.25
        return CGSize(width: width, height: width)
    }()
    
    @objc public static let pictureOptions = {() -> PHImageRequestOptions in
        let options = PHImageRequestOptions()
        options.resizeMode = .none
        // 同步获得图片, 只会返回1张图片
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true;
        return options
    }()
    
    @objc public static let pictureViewerOptions = {() -> PHImageRequestOptions in
        let options = PHImageRequestOptions()
        options.resizeMode = .none
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true;
        return options
    }()
    
    @objc public static let videoOptions = {() -> PHVideoRequestOptions in
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true;
        return options
    }()
    
    open var contentOffset: CGPoint?
    open var zoomScale: CGFloat?
    open var contentSize: CGSize?
    open var imageFrame: CGRect?
    open var isHighlight = false
    open var isLoseFocus = false
    @objc open var index = UInt(0) {
        didSet {
            if index == 0 {
                contentOffset = nil
                zoomScale = nil
                contentSize = nil
                imageFrame = nil
            }
        }
    }
    @objc open var thumb: UIImage?
    @objc public let asset: PHAsset
    
    public init(_ asset: PHAsset) {
        self.asset = asset
        super.init()
    }
}
