//
//  KSMediaPickerHandlerBaseCell.swift
// 
//
//  Created by kinsun on 2019/3/21.
//

import UIKit
import Photos

open class KSMediaPickerHandlerBaseCell: UICollectionViewCell {
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        backgroundColor = .ks_background
    }
    
    open var itemModel: KSMediaPickerItemModel?
    
}

open class KSMediaPickerHandlerPictureCell: KSMediaPickerHandlerBaseCell {
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let _imageView = UIImageView()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(_imageView)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        guard let contentSize = itemModel?.contentSize, var imageFrame = itemModel?.imageFrame else {
            return
        }
        let windowWidth = contentView.bounds.size.width
        let imageWidth = contentSize.width
        if windowWidth != imageWidth {
            let scale = windowWidth/imageWidth
            imageFrame.size.width *= scale
            imageFrame.size.height *= scale
            imageFrame.origin.x *= scale
            imageFrame.origin.y *= scale
        }
        _imageView.frame = imageFrame
    }
    
    override open var itemModel: KSMediaPickerItemModel? {
        didSet {
            guard let k_itemModel = itemModel else {
                return
            }
            _imageView.image = k_itemModel.thumb
            let mainSize = UIScreen.main.bounds.size
            PHImageManager.default().requestImage(for: k_itemModel.asset, targetSize: mainSize, contentMode: .aspectFit, options: KSMediaPickerItemModel.pictureOptions) {[weak self] (image, info) in
                self?._imageView.image = image
            }
            setNeedsLayout()
        }
    }
    
    open var generatedImage: UIImage? {
        return contentView.renderingImage
    }
}

open class KSMediaPickerHandlerVideoCell: KSMediaPickerHandlerBaseCell {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private let _videoView = {() -> KSVideoPlayerLiteView in
        let videoView = KSVideoPlayerLiteView()
        videoView.videoGravity = .resizeAspect
        return videoView
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(_videoView)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        _videoView.frame = contentView.bounds
    }
    
    override open var itemModel: KSMediaPickerItemModel? {
        didSet {
            guard let k_itemModel = itemModel else {
                return
            }
            _videoView.coverView?.image = k_itemModel.thumb
            PHImageManager.default().requestAVAsset(forVideo: k_itemModel.asset, options: KSMediaPickerItemModel.videoOptions) {[weak self] (urlAsset, audioMix, info) in
                guard let videoView = self?._videoView, let videoAsset = urlAsset else {
                    return
                }
                if Thread.current.isMainThread {
                    videoView.playerItem = AVPlayerItem(asset: videoAsset)
                    videoView.play()
                } else {
                    DispatchQueue.main.async {
                        videoView.playerItem = AVPlayerItem(asset: videoAsset)
                        videoView.play()
                    }
                }
            }
        }
    }
    
    open var videoPath: String? {
        if let asset = _videoView.playerItem?.asset, asset is AVURLAsset {
            return (asset as! AVURLAsset).url.path
        } else {
            return nil
        }
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil && _videoView.isPlaying {
            _videoView.pause()
        }
    }
}
