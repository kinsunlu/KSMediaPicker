//
//  KSMediaPickerOutputModel.swift
// 
//
//  Created by kinsun on 2019/3/24.
//

import UIKit
import Photos

open class KSMediaPickerOutputModel: NSObject {
    
    @objc public let sourceAsset: PHAsset
    @objc public let thumb: UIImage?
    @objc public let image: UIImage?
    @objc public let videoAsset: AVURLAsset?
    @objc public let mediaType: PHAssetMediaType
    
    public init(asset: PHAsset, image: UIImage?, thumb: UIImage?) {
        sourceAsset = asset
        mediaType = asset.mediaType
        self.thumb = thumb
        self.image = image
        videoAsset = nil
        super.init()
    }
    
    public init(asset: PHAsset, videoAsset: AVURLAsset?, thumb: UIImage?) {
        sourceAsset = asset
        mediaType = asset.mediaType
        self.thumb = thumb
        self.videoAsset = videoAsset
        image = nil
        super.init()
    }
    
}
