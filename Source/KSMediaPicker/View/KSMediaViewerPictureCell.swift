//
//  KSMediaViewerPictureCell.swift
// 
//
//  Created by kinsun on 2019/3/25.
//

import UIKit

open class KSMediaViewerPictureCell: KSMediaViewerCell {
    
    override open func initCell() {
        super.initCell()
        let imageView = UIImageView()
        scrollView!.addSubview(imageView)
        mainView = imageView
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        guard let imageView = mainView as? UIImageView,
            let scrollView = self.scrollView,
            let image = imageView.image else {
                return
        }
        let windowSize = scrollView.bounds.size
        let windowWidth = windowSize.width
        let windowHeight = windowSize.height
        let floatZore = CGFloat(0.0)
        let size = image.size
        
        let viewW = windowWidth
        var viewH = size.height/size.width*viewW
        let viewX = floatZore
        let viewY = floatZore
        if viewH < windowHeight {
            viewH = windowHeight
            imageView.contentMode = .scaleAspectFit
        } else {
            imageView.contentMode = .scaleToFill
        }
        imageView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        scrollView.contentSize = imageView.bounds.size
    }
    
    override open var data: Any {
        didSet {
            guard let k_data = data as? KSMediaPickerOutputModel,
                let imageView = mainView as? UIImageView,
                let scrollView = self.scrollView else {
                    return
            }
            scrollView.contentSize = scrollView.bounds.size
            scrollView.contentOffset = .zero
            imageView.transform = .identity
            imageView.image = k_data.image ?? k_data.thumb
            setNeedsLayout()
        }
    }
    
    override open var mainViewFrameInSuperView: CGRect {
        guard let imageView = mainView as? UIImageView,
            let scrollView = self.scrollView else {
                return .zero
        }
        return KSMediaViewerController<AnyObject>.transitionThumbViewFrame(inSuperView: scrollView, at: imageView.image)
    }
}
