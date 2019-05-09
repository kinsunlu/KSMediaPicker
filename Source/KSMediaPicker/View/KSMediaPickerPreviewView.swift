//
//  KSMediaPickerPreviewView.swift
// 
//
//  Created by kinsun on 2019/3/5.
//

import UIKit

extension KSMediaPickerPreviewView {
    
    private class scrollView: UIScrollView, UIScrollViewDelegate {
        
        private enum imageDirection {
            case equal
            case transversal
            case lengthwise
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public let imageView = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            showsVerticalScrollIndicator = false
            showsHorizontalScrollIndicator = false
            alwaysBounceVertical = true
            alwaysBounceHorizontal = true
            maximumZoomScale = 3.0
            clipsToBounds = true
            if #available(iOS 11.0, *) {
                contentInsetAdjustmentBehavior = .never
            }
            addSubview(imageView)
            delegate = self
        }
        
        private var _isSquare = false
        
        override open var frame: CGRect {
            set {
                if frame.size != newValue.size {
                    let windowSize = newValue.size
                    _isSquare = floor(windowSize.width) == floor(windowSize.height)
                    _imageDirection = _imageDirection(from: _imageSize, windowSize)
                }
                if _isNeedLayoutSubviews {
                    zoomScale = 1.0
                    contentOffset = .zero
                }
                super.frame = newValue
            }
            get {
                return super.frame
            }
        }
        
        private var _isNeedLayoutSubviews = true
        
        public func set(frame: CGRect, isNeedLayoutSubviews: Bool) {
            _isNeedLayoutSubviews = isNeedLayoutSubviews
            self.frame = frame
        }
        
        open var itemModel: KSMediaPickerItemModel? {
            didSet {
                guard let k_itemModel = itemModel else {
                    return
                }
                let asset = k_itemModel.asset
                let floatWidth = CGFloat(asset.pixelWidth)
                let floatHeight = CGFloat(asset.pixelHeight)
                _imageSize = CGSize(width: floatWidth, height: floatHeight)
            }
        }
        
        private var _imageSize = CGSize.zero {
            didSet {
                _imageDirection = _imageDirection(from: _imageSize, frame.size)
                _isNeedLayoutSubviews = true
                setNeedsLayout()
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            guard _isNeedLayoutSubviews || imageView.frame.size == .zero else {
                return
            }
            _isNeedLayoutSubviews = false
            let offset: CGPoint
            if _imageDirection == .equal {
                imageView.frame = bounds
                offset = .zero
            } else if _imageSize != .zero {
                let windowSize = frame.size
                let windowWidth = windowSize.width
                let windowHeight = windowSize.height
                let floatZore = CGFloat(0.0)
                let viewX: CGFloat
                let viewY: CGFloat
                let viewW: CGFloat
                let viewH: CGFloat
                
                let imageWidth = _imageSize.width
                let imageHeight = _imageSize.height
                
                if _imageDirection == .transversal {
                    viewH = windowHeight
                    viewW = imageWidth/imageHeight*viewH
                    viewY = floatZore
                    viewX = (windowWidth-viewW)*0.5
                } else {
                    viewW = windowWidth
                    viewH = imageHeight/imageWidth*viewW
                    viewX = floatZore
                    viewY = (windowHeight-viewH)*0.5
                }
                imageView.frame = CGRect(origin: .zero, size: CGSize(width: viewW, height: viewH))
                offset = CGPoint(x: -viewX, y: -viewY)
            } else {
                offset = .zero
            }
            contentSize = imageView.frame.size
            zoomScale = itemModel?.zoomScale ?? 1.0
            contentOffset = itemModel?.contentOffset ?? offset
            
            let minimumZoomScale: CGFloat
            if _isSquare {
                switch _imageDirection {
                case .equal:
                    minimumZoomScale = 1.0
                    break
                case .transversal:
                    minimumZoomScale = frame.size.width/imageView.frame.size.width
                    break
                case .lengthwise:
                    minimumZoomScale = frame.size.height/imageView.frame.size.height
                    break
                }
            } else {
                minimumZoomScale = 1.0
            }
            self.minimumZoomScale = minimumZoomScale
        }
        
        private func _imageDirection(from imageSize: CGSize, _ superSize: CGSize) -> KSMediaPickerPreviewView.scrollView.imageDirection {
            let superWidth = floor(superSize.width)
            let superHeight = floor(superSize.height)
            let imageWidth = floor(imageSize.width)
            let imageHeight = floor(imageSize.height)
            let constrainImageHeight = floor(imageHeight/imageWidth*superWidth)
            let dirction: KSMediaPickerPreviewView.scrollView.imageDirection
            if superHeight == constrainImageHeight {
                dirction = .equal
            } else {
                let maxHeight = max(superHeight, constrainImageHeight)
                if maxHeight == superHeight {
                    dirction = .transversal
                } else {
                    dirction = .lengthwise
                }
            }
            return dirction
        }
        
        private var _imageDirection = KSMediaPickerPreviewView.scrollView.imageDirection.equal
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            let contentSize = scrollView.contentSize
            let contentSizeWidth = floor(contentSize.width)
            let contentSizeHeight = floor(contentSize.height)
            let size = scrollView.frame.size
            
            var center = scrollView.center
            if contentSizeWidth >= floor(size.width) {
                center.x = contentSizeWidth*0.5
            }
            if contentSizeHeight >= floor(size.height) {
                center.y = contentSizeHeight*0.5
            }
            imageView.center = center
        }
    }
}

import Photos

open class KSMediaPickerPreviewView: UIView {
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let _videoView = {() -> KSVideoPlayerBaseView in
        let videoView = KSVideoPlayerBaseView()
        videoView.videoGravity = .resizeAspect
        videoView.videoPlaybackFinished = {[weak videoView] in
            videoView?.play()
        }
        videoView.isHidden = true
        return videoView
    }()
    
    private let _scrollview = KSMediaPickerPreviewView.scrollView()
    
    private let _changeSizeButton = {() -> UIButton in
        let changeSizeButton = UIButton(type: .custom)
        changeSizeButton.setImage(UIImage(named: "icon_mediaPicker_preview_nocut"), for: .normal)
        changeSizeButton.setImage(UIImage(named: "icon_mediaPicker_preview_cut"), for: .selected)
        changeSizeButton.backgroundColor = .clear
        return changeSizeButton
    }()
    
    private let _zoomButton = {() -> UIButton in
        let zoomButton = UIButton(type: .custom)
        zoomButton.setImage(UIImage(named: "icon_mediaPicker_preview_aspect_fit"), for: .normal)
        zoomButton.setImage(UIImage(named: "icon_mediaPicker_preview_aspect_fill"), for: .selected)
        let bundle = Bundle.main
        zoomButton.setTitle("MEDIA_PICKER_SCALE_ASPECT_FIT".ks_mediaPickerKeyToLocalized(in: bundle), for: .normal)
        zoomButton.setTitle("MEDIA_PICKER_SCALE_ASPECT_FILL".ks_mediaPickerKeyToLocalized(in: bundle), for: .selected)
        zoomButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        zoomButton.setTitleColor(.ks_white, for: .normal)
        zoomButton.backgroundColor = UIColor.ks_black.withAlphaComponent(0.3)
        return zoomButton
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .ks_background
        clipsToBounds = true
        addSubview(_scrollview)
        
        _zoomButton.addTarget(self, action: #selector(_didClick(zoomButton:)), for: .touchUpInside)
        addSubview(_zoomButton)
        _changeSizeButton.addTarget(self, action: #selector(_didClick(changeSizeButton:)), for: .touchUpInside)
        addSubview(_changeSizeButton)
        
        addSubview(_videoView)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        _videoView.frame = bounds
        
        let windowSize = bounds.size
        let windowWidth = windowSize.width
        let windowHeight = windowSize.height
        
        let scrollviewSize = _scrollview.frame.size
        var viewW = scrollviewSize.width
        var viewH = scrollviewSize.height
        var viewX = (windowWidth-viewW)*0.5
        var viewY = (windowHeight-viewH)*0.5
        _scrollview.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        viewW = _zoomButton.sizeThatFits(windowSize).width+12.0
        viewH = CGFloat(20.0)
        viewX = CGFloat(10.0)
        viewY = windowHeight-viewH-10.0
        _zoomButton.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        _zoomButton.layer.cornerRadius = viewH*0.5
        
        viewW = 30.0
        viewH = viewW
        viewY = windowHeight-viewH-10.0
        _changeSizeButton.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
//        _changeSizeButton.layer.cornerRadius = viewH*0.5
    }
    
    //isSelected = false 显示留白 isSelected = true 显示充满
    @objc private func _didClick(zoomButton: UIButton) {
        let scrollviewZoomScale = _scrollview.zoomScale
        let zoomScale: CGFloat
        if scrollviewZoomScale == 1.0 {
            zoomScale = _scrollview.minimumZoomScale
            zoomButton.isSelected = true
        } else {
            zoomScale = 1.0
            zoomButton.isSelected = false
        }
        _scrollview.setZoomScale(zoomScale, animated: true)
    }
    
    @objc private func _didClick(changeSizeButton: UIButton) {
        let isChangedSize = changeSizeButton.isSelected
        changeSizeButton.isSelected = !isChangedSize
        let frame: CGRect
        if isChangedSize {
            frame = bounds
        } else {
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            let windowHeight = windowSize.height
            
            let viewW = _minScrollViewSize.width
            let viewH = _minScrollViewSize.height
            let viewX = (windowWidth-viewW)*0.5
            let viewY = (windowHeight-viewH)*0.5
            frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        }
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .layoutSubviews, animations: {[weak self] in
            self?._scrollview.set(frame: frame, isNeedLayoutSubviews: true)
        }, completion: nil)
    }
    
    static private let _minScale = CGFloat(3.0/4.0)
    
    private var _minScrollViewSize = CGSize.zero
    private var _normalScrollViewSize = CGSize.zero
    
    private var _itemModel: KSMediaPickerItemModel? {
        didSet {
            guard let itemModel = _itemModel else {
                return
            }
            let asset = itemModel.asset
            if asset.mediaType == .video {
                _zoomButton.isHidden = true
                _videoView.isHidden = false
                _scrollview.isHidden = true
                _changeSizeButton.isHidden = true
                _videoView.coverView?.image = itemModel.thumb
                PHImageManager.default().requestAVAsset(forVideo: asset, options: KSMediaPickerItemModel.videoOptions) {[weak self] (urlAsset, audioMix, info) in
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
            } else {
                let mainSize = UIScreen.main.bounds.size
                _videoView.isHidden = true
                if _videoView.isPlaying {
                    _videoView.pause()
                }
                _scrollview.isHidden = false
                let pixelWidth = asset.pixelWidth
                let pixelHeight = asset.pixelHeight
                
                _scrollview.itemModel = itemModel
                
                let windowWidth = mainSize.width
                if _isStandard {
                    _zoomButton.isHidden = true
                    _normalScrollViewSize = CGSize(width: windowWidth, height: windowWidth)
                    if pixelWidth == pixelHeight {
                        _changeSizeButton.isHidden = true
                        _minScrollViewSize = _normalScrollViewSize
                    } else {
                        _changeSizeButton.isHidden = false
                        let maxWidth = max(pixelHeight, pixelWidth)
                        let minScale = KSMediaPickerPreviewView._minScale
                        let floatWidth = CGFloat(pixelWidth)
                        let floatHeight = CGFloat(pixelHeight)
                        let scrollViewSize: CGSize
                        if maxWidth == pixelWidth {//横向
                            let scale = floatHeight/floatWidth
                            let minHeight: CGFloat
                            let minWidth = windowWidth
                            if scale > minScale {
                                minHeight = floor(floatHeight*minWidth/floatWidth)
                            } else {
                                minHeight = floor(minWidth*minScale)
                            }
                            scrollViewSize = CGSize(width: minWidth, height: minHeight)
                        } else {//纵向
                            let scale = floatWidth/floatHeight
                            let minWidth: CGFloat
                            let minHeight = windowWidth
                            if scale > minScale {
                                minWidth = floor(floatWidth*minHeight/floatHeight)
                            } else {
                                minWidth = floor(minHeight*minScale)
                            }
                            scrollViewSize = CGSize(width: minWidth, height: minHeight)
                        }
                        _minScrollViewSize = scrollViewSize
                    }
                } else {
                    _changeSizeButton.isHidden = true
                    _zoomButton.isSelected = false
                    _zoomButton.isHidden = _changeSizeButton.isSelected
                }
                _scrollview.set(frame: CGRect(origin: .zero, size: _changeSizeButton.isSelected ? _minScrollViewSize : _normalScrollViewSize), isNeedLayoutSubviews: true)
                setNeedsLayout()
                _scrollview.imageView.image = itemModel.thumb
                PHImageManager.default().requestImage(for: asset, targetSize: mainSize, contentMode: .aspectFit, options: KSMediaPickerItemModel.pictureOptions) {[weak self] (image, info) in
                    self?._scrollview.imageView.image = image
                }
            }
        }
    }
    
    private var _isStandard = false
    
    public func set(itemModel: KSMediaPickerItemModel, isStandard: Bool = false) {
        saveCurrentState()
        _isStandard = isStandard
        _itemModel = itemModel
    }
    
    public func saveCurrentState() {
        if let k_itemModel = _itemModel, k_itemModel.index > 0 {
            if k_itemModel.asset.mediaType == .image {
                k_itemModel.contentOffset = _scrollview.contentOffset
                k_itemModel.zoomScale = _scrollview.zoomScale
                let scrollviewFrame = _scrollview.frame
                k_itemModel.contentSize = scrollviewFrame.size
                var rect = _scrollview.convert(_scrollview.imageView.frame, to: self)
                let scrollviewOrigin = scrollviewFrame.origin
                rect.origin.x -= scrollviewOrigin.x
                rect.origin.y -= scrollviewOrigin.y
                k_itemModel.imageFrame = rect
            } else {
                k_itemModel.contentSize = _videoView.bounds.size
            }
        }
    }
    
    open var isStandard: Bool {
        return _isStandard
    }
    
    open var itemModel: KSMediaPickerItemModel? {
        return _itemModel
    }
    
    public func videoPlay() {
        if !_videoView.isHidden {
            _videoView.play()
        }
    }
    public func videoPause() {
        if !_videoView.isHidden || _videoView.isPlaying {
            _videoView.pause()
        }
    }
}
