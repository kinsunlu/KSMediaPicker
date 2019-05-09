//
//  KSMediaPickerViewAlbumCell.swift
// 
//
//  Created by kinsun on 2019/3/5.
//

import UIKit
import Photos

open class KSMediaPickerViewAlbumCell: UITableViewCell {

    open var albumModel: KSMediaPickerAlbumModel! {
        didSet {
            let itemModel = albumModel.assetList.first
            if itemModel != nil {
                PHImageManager.default().requestImage(for: itemModel!.asset, targetSize: KSMediaPickerItemModel.thumbSize, contentMode: .aspectFill, options: KSMediaPickerItemModel.pictureViewerOptions) {[weak self] (image, info) in
                    self?.imageView?.image = image
                }
                textLabel?.text = albumModel.albumTitle
                detailTextLabel?.text = String(albumModel.assetList.count)
            }
        }
    }
    
    private let _lineView = {() -> UIView in
        let lineView = UIView()
        lineView.backgroundColor = .ks_lightGray
        lineView.isUserInteractionEnabled = false
        return lineView
    }()
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageView?.image = .ks_defaultPlaceholder
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        
        textLabel?.font = UIFont.systemFont(ofSize: 16.0)
        textLabel?.textColor = .ks_wordMain
        
        detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0)
        detailTextLabel?.textColor = .ks_wordMain_2
        
        contentView.addSubview(_lineView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let windowSize = contentView.bounds.size
        let windowWidth = windowSize.width
        let windowHeight = windowSize.height
        
        var viewW = CGFloat(50.0)
        var viewH = viewW
        var viewX = CGFloat(12.0)
        var viewY = (windowHeight-viewH)*0.5
        imageView?.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        let titleHeight = textLabel?.font.lineHeight ?? 0.0
        let detailHeight = detailTextLabel?.font.lineHeight ?? 0.0
        let margin = CGFloat(2.0)
        
        viewH = titleHeight
        viewX = (imageView?.frame.maxX ?? 0.0) + 12.0
        viewW = windowWidth-viewX-12.0
        viewY = (windowHeight-(viewH+margin+detailHeight))*0.5
        textLabel?.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        viewY = (textLabel?.frame.maxY ?? 0.0)+margin
        viewH = detailHeight
        detailTextLabel?.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        viewX = CGFloat(0.0)
        viewH = CGFloat(0.5)
        viewW = windowWidth
        viewY = windowHeight-viewH
        _lineView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
    }
}
