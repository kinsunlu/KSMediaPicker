//
//  KSMediaPickerViewVideoCell.swift
// 
//
//  Created by kinsun on 2019/3/5.
//

import UIKit

open class KSMediaPickerViewVideoCell: KSMediaPickerViewImageCell {
    
    private let _infoView = KSMediaPickerViewVideoCell.infomationView()
    
    override open func viewWillFinishInit() {
        super.viewWillFinishInit()
        contentView.addSubview(_infoView)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let windowSize = bounds.size
        let viewW = windowSize.width
        let viewH = CGFloat(20.0)
        let viewX = CGFloat(0.0)
        let viewY = windowSize.height-viewH
        _infoView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
    }
    
    override open var itemModel: KSMediaPickerItemModel! {
        didSet {
            let duration = itemModel.asset.duration
            _infoView.text = String(format: "%02.0f:%02td", duration/60.0, Int(duration)%60)
        }
    }
}

import CoreGraphics

extension KSMediaPickerViewVideoCell {
    
    private class infomationView: UIView {
        
        open var text: String? {
            get {
                return _textLayer.string as? String
            }
            set {
                _textLayer.string = newValue
            }
        }
        
        private let _gradientLayer = {() -> CAGradientLayer in
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.ks_black.withAlphaComponent(0.8).cgColor,
                                    UIColor.clear.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.locations = [NSNumber(value: 0), NSNumber(value: 1)]
            return gradientLayer
        }()
        
        private let _videoIndLayer = {() -> CALayer in
            let videoIndLayer = CALayer()
            videoIndLayer.contents = UIImage(named: "icon_ImagePicker_play")?.cgImage
            return videoIndLayer
        }()
        
        private let _textLayer = {() -> CATextLayer in
            let textLayer = CATextLayer()
            textLayer.isWrapped = true
            textLayer.alignmentMode = .right
            textLayer.contentsScale = UIScreen.main.scale
            
            let font = UIFont.systemFont(ofSize: 12.0)
            textLayer.font = CGFont(font.fontName as CFString)
            textLayer.fontSize = font.pointSize
            textLayer.foregroundColor = UIColor.ks_white.cgColor
            return textLayer
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = UIColor.clear
            
            layer.addSublayer(_gradientLayer)
            layer.addSublayer(_videoIndLayer)
            layer.addSublayer(_textLayer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSublayers(of layer: CALayer) {
            super.layoutSublayers(of: layer)
            let bounds = self.bounds
            _gradientLayer.frame = bounds
            
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            let windowHeight = windowSize.height
            let margin = CGFloat(8.0)
            
            var viewW = CGFloat(12.0)
            var viewH = viewW
            var viewX = margin
            var viewY = (windowHeight-viewH)*0.5
            _videoIndLayer.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
            
            viewX = _videoIndLayer.frame.maxX
            viewW = windowWidth-viewX-margin
            viewH = _textLayer.fontSize
            viewY = (windowHeight-viewH)*0.5-1.0
            _textLayer.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        }
        
    }
}
