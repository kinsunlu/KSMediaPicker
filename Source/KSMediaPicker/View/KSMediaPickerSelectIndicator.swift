//
//  KSMediaPickerSelectIndicator.swift
//  KSMediaPickerDemo
//
//  Created by kinsun on 2019/5/8.
//  Copyright © 2019年 kinsun. All rights reserved.
//

import UIKit

extension KSMediaPickerViewImageCell {
    
    open class selectIndicator: UIControl {
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _normalLayer = {() -> CALayer in
            let normalLayer = CALayer()
            normalLayer.backgroundColor = UIColor.ks_black.cgColor
            normalLayer.borderColor = UIColor.ks_white.cgColor
            normalLayer.borderWidth = 1.0
            normalLayer.masksToBounds = true
            normalLayer.contents = UIImage(named: "icon_ImagePicker_Selected")?.cgImage
            normalLayer.opacity = 0.5
            return normalLayer
        }()
        
        private let _selectLayer = {() -> CALayer in
            let selectLayer = CALayer()
            selectLayer.backgroundColor = UIColor.ks_main.cgColor
            selectLayer.borderColor = UIColor.ks_white.cgColor
            selectLayer.borderWidth = 1.0
            selectLayer.masksToBounds = true
            selectLayer.isHidden = true
            return selectLayer
        }()
        
        private let _textLayer = {() -> CATextLayer in
            let textLayer = CATextLayer()
            textLayer.isWrapped = true
            textLayer.alignmentMode = .center
            textLayer.contentsScale = UIScreen.main.scale
            let font = UIFont.systemFont(ofSize: 12.0)
            let fontRef = CGFont(font.fontName as CFString)
            textLayer.font = fontRef
            textLayer.fontSize = font.pointSize
            textLayer.foregroundColor = UIColor.ks_white.cgColor
            return textLayer
        }()
        
        override public init(frame: CGRect) {
            super.init(frame: frame)
            layer.addSublayer(_normalLayer)
            layer.addSublayer(_selectLayer)
            _selectLayer.addSublayer(_textLayer)
        }
        
        override open func layoutSublayers(of layer: CALayer) {
            super.layoutSublayers(of: layer)
            let windowSize = layer.bounds.size
            let windowWidth = windowSize.width
            let windowHeight = windowSize.height
            
            let viewW = CGFloat(22.0)
            var viewH = viewW
            var viewX = (windowWidth-viewW)*0.5
            var viewY = (windowHeight-viewH)*0.5
            let frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
            _normalLayer.frame = frame
            _selectLayer.frame = frame
            let cornerRadius = viewW*0.5
            _normalLayer.cornerRadius = cornerRadius
            _selectLayer.cornerRadius = cornerRadius
            
            if isMultipleSelected {
                viewH = _textLayer.fontSize
                viewX = 0.0
                viewY = (22.0-viewH)*0.5-1.0
                _textLayer.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
            }
        }
        
        open var index = UInt(0) {
            didSet {
                let isSelected = index > 0
                if isMultipleSelected && isSelected {
                    _textLayer.string = "\(index)"
                }
                _selectLayer.isHidden = !isSelected
                _normalLayer.isHidden = isSelected
            }
        }
        
        open var isMultipleSelected = true {
            didSet {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                if isMultipleSelected {
                    _textLayer.isHidden = false
                    _selectLayer.contents = nil
                } else {
                    _textLayer.isHidden = true
                    _selectLayer.contents = _normalLayer.contents
                }
                CATransaction.commit()
                setNeedsLayout()
            }
        }
    }
}
