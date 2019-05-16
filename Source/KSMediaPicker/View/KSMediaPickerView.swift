//
//  KSMediaPickerView.swift
// 
//
//  Created by kinsun on 2019/3/1.
//

import UIKit

extension KSMediaPickerView {
    
    private class segmentedControl: KSSegmentedControl {
        
        fileprivate enum style {
            case light
            case dark
        }
        
        private var _style = KSMediaPickerView.segmentedControl.style.light {
            didSet {
                _didSet(style: _style)
            }
        }
        open var style: KSMediaPickerView.segmentedControl.style {
            set {
                if newValue != _style {
                    _style = newValue
                }
            }
            get {
                return _style
            }
        }
        
        override public init(frame: CGRect) {
            let bundle = Bundle.main
            let items = ["MEDIA_PICKER_ALBUM_TAB_TITLE".ks_mediaPickerKeyToLocalized(in: bundle),
                         "MEDIA_PICKER_CAMERA_TAB_TITLE".ks_mediaPickerKeyToLocalized(in: bundle),
                         "MEDIA_PICKER_VIDEOCORDER_TAB_TITLE".ks_mediaPickerKeyToLocalized(in: bundle)]
            super.init(frame: frame, items: items)
            font = UIFont.systemFont(ofSize: 17.0)
            _didSet(style: .light)
        }
        
        private func _didSet(style: KSMediaPickerView.segmentedControl.style) {
            switch style {
            case .light:
                normalTextColor = .ks_wordMain_2
                selectedTextColor = .ks_main
                indndicatorColor = .ks_main
                break
            case .dark:
                let color = UIColor.ks_white
                normalTextColor = color
                selectedTextColor = color
                indndicatorColor = color
                break
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

open class KSMediaPickerView: UIView, KSMediaPickerScrollViewDelegate {
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public let scrollView = {() -> KSMediaPickerScrollView in
        let scrollView = KSMediaPickerScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    
    public let albumNavigationView = KSMediaPickerView.navigationView()
    
    public let collectionView = {() -> KSMediaPickerCollectionView in
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = KSMediaPickerCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.clipsToBounds = true
        collectionView.bounces = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        return collectionView
    }()
    
    public let previewView = KSMediaPickerPreviewView()
    
    private let _toolBarSafeAreaView = {() -> UIView in
        let toolBarSafeAreaView = UIView()
        toolBarSafeAreaView.backgroundColor = .clear
        return toolBarSafeAreaView
    }()
    
    public let segmentedControl: KSSegmentedControl = KSMediaPickerView.segmentedControl(frame: .zero)
    
    public let albumTableView = {() -> UITableView in
        let albumTableView = UITableView(frame: .zero, style: .plain)
        albumTableView.isHidden = true
        albumTableView.backgroundColor = .ks_white
        albumTableView.rowHeight = 75.0
        albumTableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            albumTableView.contentInsetAdjustmentBehavior = .never
        }
        return albumTableView
    }()
    
    private let _blackBackgroundLayer = {() -> CALayer in
        let blackBackgroundLayer = CALayer()
        blackBackgroundLayer.opacity = 0.0
        blackBackgroundLayer.backgroundColor = UIColor.ks_black.cgColor
        return blackBackgroundLayer
    }()
    
    public let cameraView = KSMediaPickerCameraView()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .ks_white
        layer.addSublayer(_blackBackgroundLayer)
        
        scrollView.addSubview(collectionView)
        scrollView.addSubview(previewView)
        scrollView.addSubview(albumTableView)
        albumNavigationView.nextButton.isEnabled = false
        scrollView.addSubview(albumNavigationView)
        
        cameraView.scrollView.delegate = self
        scrollView.addSubview(cameraView)
        
        scrollView.delegate = self
        addSubview(scrollView)
        
        collectionView.handlePanCallback = {[weak self] (pan) in
            self?._collectionView(did: pan)
        }
        collectionView.scrollViewDidScrollCallback = {[weak self] (scrollView) in
            self?._collectionViewDidScroll(scrollView)
        }
        collectionView.scrollViewDidEndDraggingCallback = {[weak self] (scrollView, decelerate) in
            self?._collectionViewDidEndDragging(scrollView, decelerate: decelerate)
        }
        self.segmentedControl.didClickItem = {[weak self] (segmentedControl, index) in
            self?.didClick(segmentedControl: segmentedControl, index: index)
        }
        
        _toolBarSafeAreaView.addSubview(self.segmentedControl)
        addSubview(_toolBarSafeAreaView)
    }
    
    override open func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        _blackBackgroundLayer.frame = layer.bounds
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        scrollView.frame = bounds
        
        let safeArea = UIEdgeInsets.safeAreaInsets
        
        let windowSize = bounds.size
        let windowWidth = windowSize.width
        let windowHeight = windowSize.height
        let floatZore = CGFloat(0.0)
        let safeBottomMargin = safeArea.bottom
        
        scrollView.contentSize = CGSize(width: windowWidth*2.0, height: 0.0)
        
        var viewW = windowWidth
        var viewH = safeBottomMargin+48.0
        var viewX = floatZore
        var viewY = windowHeight-viewH
        _toolBarSafeAreaView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        viewY = floatZore
        viewH = 48.0
        self.segmentedControl.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        let margin = CGFloat(3.0)
        let columnCount = UInt(4)
        let itemW = floor((windowWidth-margin*CGFloat(columnCount-1))/CGFloat(columnCount))
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemW, height: itemW)
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        layout.sectionInset = .zero
        
        viewX = floatZore
        viewY = floatZore
        viewW = windowWidth
        viewH = UIView.statusBarNavigationBarSize.height
        albumNavigationView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        let navHeight = albumNavigationView.frame.maxY
        let baseY = previewView.frame.origin.y
        viewX = floatZore
        if baseY == 0 {
            viewY = navHeight
            _baseY = viewY
        } else {
            viewY = baseY
        }
        viewW = windowWidth
        viewH = viewW
        previewView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        let previewViewFrameMaxY = previewView.frame.maxY
        viewY = floatZore
        viewH = previewViewFrameMaxY+20.0
        _previewGestureCorrespondingArea = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        let toolBarSafeAreaViewHeight = _toolBarSafeAreaView.bounds.size.height
        
        viewX = floatZore
        viewY = floatZore
        viewW = windowWidth
        viewH = windowHeight-toolBarSafeAreaViewHeight
        let frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        collectionView.frame = frame
        let conetntInset = UIEdgeInsets(top: previewViewFrameMaxY+3.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionView.contentInset = conetntInset
        collectionView.scrollIndicatorInsets = conetntInset
        
        let inset = UIEdgeInsets(top: navHeight, left: 0.0, bottom: 0.0, right: 0.0)
        albumTableView.frame = frame
        albumTableView.contentInset = inset
        albumTableView.scrollIndicatorInsets = inset
        
        viewX = collectionView.frame.maxX
        viewY = floatZore
        viewW = windowWidth
        viewH = windowHeight-toolBarSafeAreaViewHeight
        cameraView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
    }
    
    private var _baseY: CGFloat?
    private var _previewGestureCorrespondingArea: CGRect?
    private var _isInGestureCorrespondingArea = false
    
    private var _panBeginLocationY = CGFloat(0)
    private var _isScrollDown = false
    private var _isRetract = false {
        didSet {
            if albumNavigationView.isHidden != _isRetract {
                let trans = CATransition()
                trans.duration = 0.2
                trans.type = .push
                trans.subtype = _isRetract ? .fromTop : .fromBottom
                albumNavigationView.isHidden = _isRetract
                albumNavigationView.layer.add(trans, forKey: nil)
            }
        }
    }
    
    private func _collectionView(did pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            _panBeginLocationY = pan.location(in: self).y
            break
        case .changed:
            guard let baseY = _baseY else {
                return
            }
            let location = pan.location(in: self)
            let locationY = location.y
            _isScrollDown = locationY > _panBeginLocationY
            _isInGestureCorrespondingArea = _previewGestureCorrespondingArea != nil && _previewGestureCorrespondingArea!.contains(location)
            if _isInGestureCorrespondingArea {
                var previewFrame = previewView.frame
                var y = locationY-previewFrame.size.height
                if y >= baseY {
                    y = baseY
                }
                previewFrame.origin.y = y
                previewView.frame = previewFrame
                
                _previewGestureCorrespondingArea!.size.height = previewFrame.maxY+20.0
            }
            _panBeginLocationY = locationY
            break
        case .cancelled, .ended, .failed:
            guard _isInGestureCorrespondingArea, let baseY = _baseY else {
                return
            }
            var previewFrame = previewView.frame
            let maxY = previewFrame.maxY
            let boundary = (previewFrame.size.height+baseY)*(_isScrollDown ? 0.2 : 0.8)
            if maxY < boundary {
                _isRetract = true
                previewFrame.origin.y = baseY-previewFrame.size.height
            } else {
                _isRetract = false
                previewFrame.origin.y = baseY
            }
            
            let height = previewFrame.maxY
            _previewGestureCorrespondingArea!.size.height = height+20.0
            
            var topPoint: CGPoint? = nil
            let offsetY = -collectionView.contentOffset.y
            if offsetY > height {
                topPoint = CGPoint(x: 0.0, y: -(height+3.0))
            }
            UIView.animate(withDuration: 0.2, animations: {[weak self, weak previewView] in
                previewView?.frame = previewFrame
                guard let k_topPoint = topPoint else {
                    return
                }
                self?.collectionView.contentOffset = k_topPoint
            })
            break
        default:
            break
        }
    }
    
    private func _collectionViewDidScroll(_ scrollView: KSMediaPickerCollectionView) {
        guard !_isInGestureCorrespondingArea, _isScrollDown, _isRetract, let baseY = _baseY else {
            return
        }
        let offsetY = -(scrollView.contentOffset.y)
        if offsetY >= baseY {
            var previewFrame = previewView.frame
            var y = offsetY-previewFrame.size.height
            if y >= baseY {
                y = baseY
            }
            previewFrame.origin.y = y
            previewView.frame = previewFrame
            
            _previewGestureCorrespondingArea!.size.height = previewFrame.maxY+20.0
        }
    }
    
    private func _collectionViewDidEndDragging(_ scrollView: KSMediaPickerCollectionView, decelerate: Bool) {
        var previewFrame = previewView.frame
        let maxY = previewFrame.maxY
        guard scrollView.contentOffset.y <= -maxY, !_isInGestureCorrespondingArea, let baseY = _baseY else {
            return
        }
        let boundary = (previewFrame.size.height+baseY)*(_isScrollDown ? 0.2 : 0.8)
        if maxY < boundary && !_isRetract {
            _isRetract = true
            previewFrame.origin.y = baseY-previewFrame.size.height
        } else if _isRetract {
            _isRetract = false
            previewFrame.origin.y = baseY
        } else {
            return
        }
        
        let height = previewFrame.maxY
        _previewGestureCorrespondingArea!.size.height = height+20.0
        
        let topPoint = CGPoint(x: 0.0, y: -(height+3.0))
        UIView.animate(withDuration: 0.2, animations: {[weak self, weak previewView] in
            previewView?.frame = previewFrame
            self?.collectionView.contentOffset = topPoint
        })
    }
    
    public func showPreview(_ animated: Bool) {
        var previewFrame = previewView.frame
        previewFrame.origin.y = _baseY ?? 0
        _isRetract = false
        if animated {
            UIView.animate(withDuration: 0.2, animations: {[weak self] in
                self?.previewView.frame = previewFrame
            }) {[weak self] (finish) in
                self?.setNeedsLayout()
            }
        } else {
            setNeedsLayout()
        }
    }
    
    public func collectionViewScrollToTop() {
        let point = CGPoint(x: 0.0, y: -collectionView.contentInset.top)
        if !point.equalTo(collectionView.contentOffset) {
            collectionView.setContentOffset(point, animated: false)
            showPreview(false)
        }
    }
    
    public func chengedAlbumListStatus() -> Bool {
        let isShow = !albumTableView.isHidden
        let trans = CATransition()
        trans.duration = 0.2
        trans.type = .push
        trans.subtype = isShow ? .fromTop : .fromBottom
        albumTableView.isHidden = isShow
        albumTableView.layer.add(trans, forKey: nil)
        return isShow
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView {
        case self.scrollView:
            let offsetX = scrollView.contentOffset.x
            let width = scrollView.bounds.size.width
            guard offsetX <= scrollView.contentSize.width-width else {
                return
            }
            let segmentedControl = self.segmentedControl
            let page = UInt(ceil((offsetX-width*0.5)/width))
            if page != segmentedControl.selectedSegmentIndex {
                segmentedControl.selectedSegmentIndex = page
            }
            segmentedControl.updateIndicatorProportion(offsetX/width)
            return
        case cameraView.scrollView:
            let offsetX = scrollView.contentOffset.x
            let width = scrollView.contentSize.width-scrollView.bounds.size.width
            CATransaction.begin()
            _blackBackgroundLayer.opacity = Float(offsetX/width)
            CATransaction.commit()
            let seg = self.segmentedControl as! KSMediaPickerView.segmentedControl
            let toolBar = cameraView.toolBar
            let page = ceil((offsetX-width*0.5)/width)
            if page == 0.0 {
                seg.style = .light
                toolBar.style = .darkContent
                toolBar.type = cameraView.isBackCameraDevice ? .photos : .noFlashlightPhotos
            } else {
                seg.style = .dark
                toolBar.style = .lightContent
                toolBar.type = .videos
            }
            let u_page = UInt(page)+1
            if u_page != seg.selectedSegmentIndex {
                seg.selectedSegmentIndex = u_page
            }
            seg.updateIndicatorProportion((offsetX+width)/width)
            return
        default:
            return
        }
    }
    
    public func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        let page = self.segmentedControl.selectedSegmentIndex
        if page == 0 {
            cameraView.stopRunning()
            if let callback = cameraView.toolBar.didChangedStyleCallback {
                callback(.darkContent)
            }
            previewView.videoPlay()
        } else {
            previewView.videoPause()
            if page == 1 {
                cameraView.style = .photo
            } else {
                cameraView.style = .video
            }
            if let callback = cameraView.toolBar.didChangedStyleCallback {
                callback(cameraView.toolBar.style)
            }
            cameraView.startRunning()
        }
    }
    
    public func didClick(segmentedControl: KSSegmentedControl, index: Int) {
        switch index {
        case 0:
            scrollView.setContentOffset(.zero, animated: true)
            cameraView.scrollView.contentOffset = .zero
            break
        case 1:
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                scrollView.setContentOffset(CGPoint(x: bounds.size.width, y: 0.0), animated: true)
                cameraView.scrollView.contentOffset = .zero
                break
            case 2:
                cameraView.scrollView.setContentOffset(.zero, animated: true)
                break
            default:
                break
            }
            break
        case 2:
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                scrollView.contentOffset = CGPoint(x: bounds.size.width, y: 0.0)
                cameraView.scrollView.setContentOffset(CGPoint(x: bounds.size.width, y: 0.0), animated: true)
                break
            case 1:
                cameraView.scrollView.setContentOffset(CGPoint(x: bounds.size.width, y: 0.0), animated: true)
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
}
