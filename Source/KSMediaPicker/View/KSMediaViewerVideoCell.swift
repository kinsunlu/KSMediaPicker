//
//  KSMediaViewerVideoCell.swift
// 
//
//  Created by kinsun on 2019/3/25.
//

import UIKit
import Photos

open class KSMediaViewerVideoCell: KSMediaViewerCell {
    
    override open func initCell() {
        super.initCell()
        scrollView?.delegate = nil
        let videoView = KSVideoPlayerLiteView()
        videoView.videoGravity = .resizeAspect
        scrollView?.addSubview(videoView)
        mainView = videoView
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let bounds = (scrollView ?? contentView).bounds
        mainView?.frame = bounds
    }
    
    override open var data: Any {
        didSet {
            guard let k_data = data as? KSMediaPickerOutputModel,
                let videoView = mainView as? KSVideoPlayerLiteView else {
                    return
            }
            videoView.coverView?.image = k_data.thumb
            PHImageManager.default().requestAVAsset(forVideo: k_data.sourceAsset, options: KSMediaPickerItemModel.videoOptions) { (urlAsset, audioMix, info) in
                guard let videoAsset = urlAsset else {
                    return
                }
                if Thread.current.isMainThread {
                    videoView.playerItem = AVPlayerItem(asset: videoAsset)
                } else {
                    DispatchQueue.main.async {
                        videoView.playerItem = AVPlayerItem(asset: videoAsset)
                    }
                }
            }
        }
    }
    
    override open var mainViewFrameInSuperView: CGRect {
        guard let k_data = data as? KSMediaPickerOutputModel,
            let scrollView = self.scrollView else {
                return .zero
        }
        return KSMediaViewerController<AnyObject>.transitionThumbViewFrame(inSuperView: scrollView, at: k_data.thumb)
    }
}
