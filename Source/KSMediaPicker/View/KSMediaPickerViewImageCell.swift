//
//  KSMediaPickerViewImageCell.swift
// 
//
//  Created by kinsun on 2019/3/1.
//

import UIKit
import Photos

open class KSMediaPickerViewImageCell: UICollectionViewCell {
    
    public let imageView = {() -> UIImageView in
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let _indView = KSMediaPickerViewImageCell.selectIndicator()
    
    private let _shelterLayer = {() -> CALayer in
        let shelterLayer = CALayer()
        shelterLayer.backgroundColor = UIColor.ks_white.withAlphaComponent(0.5).cgColor
        shelterLayer.isHidden = true
        return shelterLayer
    }()
    
    private let _highlightView = {() -> UIView in
        let highlightView = UIView()
        highlightView.isHidden = true
        highlightView.isUserInteractionEnabled = false
        highlightView.backgroundColor = UIColor.ks_main.withAlphaComponent(0.5)
        highlightView.layer.borderWidth = 2.0
        highlightView.layer.borderColor = UIColor.ks_main.cgColor
        return highlightView
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        viewWillFinishInit()
        contentView.addSubview(_highlightView)
        contentView.addSubview(_indView)
        _indView.addTarget(self, action: #selector(_didClick(selectedItem:)), for: .touchUpInside)
        contentView.layer.addSublayer(_shelterLayer)
    }
    
    open func viewWillFinishInit() {
        contentView.addSubview(imageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        imageView.frame = bounds
        _highlightView.frame = bounds
        
        let viewW = CGFloat(36.0)
        let viewH = viewW
        let viewX = bounds.size.width-viewW
        let viewY = CGFloat(0.0)
        _indView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
    }
    
    override open func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        _shelterLayer.frame = contentView.layer.bounds
    }
    
    open var isMultipleSelected: Bool {
        set {
            _indView.isMultipleSelected = newValue
        }
        get {
            return _indView.isMultipleSelected
        }
    }
    
    open var isLoseFocus: Bool {
        set {
            _shelterLayer.isHidden = !newValue
        }
        get {
            return !_shelterLayer.isHidden
        }
    }
    
    open var didSelectedItem: ((KSMediaPickerViewImageCell) -> UInt)?
    
    open var itemModel: KSMediaPickerItemModel! {
        didSet {
            isLoseFocus = itemModel.isLoseFocus
            let thumb = itemModel.thumb
            if thumb == nil {
                PHImageManager.default().requestImage(for: itemModel.asset, targetSize: KSMediaPickerItemModel.thumbSize, contentMode:.aspectFit , options: KSMediaPickerItemModel.pictureViewerOptions) {[weak self] (image, info) in
                    self?._updateThumb(image)
                }
            } else {
                imageView.image = thumb
            }
            _indView.index = itemModel.index
            itemIsHighlight = itemModel.isHighlight
        }
    }
    
    private func _updateThumb(_ image: UIImage?) {
        itemModel.thumb = image
        imageView.image = image
    }
    
    @objc private func _didClick(selectedItem: KSMediaPickerViewImageCell.selectIndicator) {
        guard didSelectedItem != nil else {
            return
        }
        let index = didSelectedItem!(self)
        selectedItem.index = index
        itemModel.index = index
    }
    
    open var itemIsHighlight: Bool {
        set {
            _highlightView.isHidden = !newValue
        }
        get {
            return !_highlightView.isHidden
        }
    }
    
    open var imageViewFrameInSuperView: CGRect {
        get {
            let wrapperView = superview
            let collectionView = wrapperView?.superview
            let view = collectionView?.superview
            return convert(imageView.frame, to: view)
        }
    }
}
