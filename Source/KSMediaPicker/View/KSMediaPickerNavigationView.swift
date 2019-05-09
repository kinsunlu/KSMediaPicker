//
//  KSMediaPickerNavigationView.swift
// 
//
//  Created by kinsun on 2019/3/5.
//

import UIKit

extension KSMediaPickerView {
    
    open class navigationView: UIView {
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public let nextButton = {() -> UIButton in
            let nextButton = UIButton(type: .custom)
            nextButton.titleLabel?.font = .systemFont(ofSize: 14.0)
            nextButton.setTitle("NEXT".ks_mediaPickerKeyToLocalized, for: .normal)
            nextButton.setTitleColor(.ks_wordMain, for: .normal)
            nextButton.setTitleColor(.ks_wordMain_2, for: .disabled)
            return nextButton
        }()
        
        public let closeButton = {() -> UIButton in
            let closeButton = UIButton(type: .custom)
            closeButton.setImage(UIImage(named: "icon_mediaPicker_camera_close_b"), for: .normal)
            return closeButton
        }()
        
        private let _centerView = KSMediaPickerView.navigationView.centerView()
        
        override public init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .ks_white
            addSubview(nextButton)
            addSubview(closeButton)
            addSubview(_centerView)
        }
        
        override open func layoutSubviews() {
            super.layoutSubviews()
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            
            var viewX = CGFloat(0.0)
            let viewY = UIView.statusBarSize.height
            let viewH = windowSize.height-viewY
            var viewW = viewH+30.0
            closeButton.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
            
            viewW = nextButton.sizeThatFits(windowSize).width+30.0
            viewX = windowWidth-viewW
            nextButton.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
            
            let maxWidth = max(closeButton.bounds.size.width, nextButton.bounds.size.width)
            viewX = maxWidth
            viewW = windowWidth-viewX*2.0
            _centerView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        }
        
        open var title: String? {
            set {
                _centerView.button.text = newValue ?? ""
                _centerView.setNeedsLayout()
            }
            get {
                return _centerView.button.text
            }
        }
        
        open var centerButton: KSTriangleIndicatorButton {
            get {
                return _centerView.button
            }
        }
    }
}

extension KSMediaPickerView.navigationView {
    
    private class centerView: UIView {
        
        public let button = {() -> KSTriangleIndicatorButton in
            let button = KSTriangleIndicatorButton()
            button.font = UIFont.systemFont(ofSize: 18.0)
            button.color = .ks_wordMain
            return button
        }()
        
        override public init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(button)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let windowSize = bounds.size
            let viewW = button.sizeThatFits(windowSize).width
            let viewX = (windowSize.width-viewW)*0.5
            let viewY = CGFloat(0.0)
            button.frame = CGRect(x: viewX, y: viewY, width: viewW, height: windowSize.height)
        }
    }
}
