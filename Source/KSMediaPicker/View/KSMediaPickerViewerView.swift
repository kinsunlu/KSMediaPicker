//
//  KSMediaPickerViewerView.swift
//  pet
//
//  Created by kinsun on 2019/3/25.
//

import UIKit

open class KSMediaPickerViewerView: KSMediaViewerView {

    public let pageControl = {() -> KSPageControl in
        let pageControl = KSPageControl()
        pageControl.toMuchEgdeMargin = 18.0
        pageControl.tintColor = .ks_white
        return pageControl
    }()
    
    override open func initView() {
        super.initView()
        addSubview(pageControl)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        let windowSize = bounds.size
        let viewH = CGFloat(5.0)
        let viewY = windowSize.height-viewH-UIEdgeInsets.safeAreaInsets.bottom-18.0
        pageControl.frame = CGRect(x: 0.0, y: viewY, width: windowSize.width, height: viewH)
    }
}
