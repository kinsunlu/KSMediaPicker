//
//  KSMediaPickerViewerView.swift
// 
//
//  Created by kinsun on 2019/3/25.
//

import UIKit

open class KSMediaPickerViewerView: KSMediaViewerView {
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public let pageControl = {() -> KSPageControl in
        let pageControl = KSPageControl()
        pageControl.tooMuchEgdeMargin = 18.0
        pageControl.tintColor = .ks_white
        return pageControl
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
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
