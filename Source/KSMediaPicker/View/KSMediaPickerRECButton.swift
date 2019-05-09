//
//  KSMediaPickerRECButton.swift
// 
//
//  Created by kinsun on 2019/3/13.
//

import UIKit

extension KSMediaPickerCameraView {
    
    open class RECButton: UIControl {
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _recLayer = RECButton.RECLayer()
        
        override public init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            layer.addSublayer(_recLayer)
        }
        
        override open func layoutSublayers(of layer: CALayer) {
            super.layoutSublayers(of: layer)
            _recLayer.frame = layer.bounds
        }
        
        override open var isHighlighted: Bool {
            didSet {
                alpha = isHighlighted ? 0.5 : 1.0
            }
        }
        
        open var didStopRunningCallback: ((RECButton) -> Void)?
        open var numberOfSecondsSpentInATurn = TimeInterval(30.0)
        open var maxRunningSeconds = TimeInterval(60.0)
        private var _currentTime = TimeInterval(0.0)
        private var _isRunning = false
        open var isRunning: Bool {
            get {
                return _isRunning
            }
        }
        
        private var _timer: Timer?
        
        open func startRunning() {
            stopRunning()
            if !_isRunning {
                _isRunning = true
                let timer = Timer(timeInterval: 0.1, target: self, selector: #selector(_timerArrive(_:)), userInfo: nil, repeats: true)
                RunLoop.main.add(timer, forMode: .common)
                _timer = timer
                _recLayer.isChangeToSquare = true
                _timer?.fire()
            }
        }
        
        open func stopRunning() {
            if _isRunning {
                _timer?.invalidate()
                _timer = nil
                _recLayer.isChangeToSquare = false
                _recLayer.progress = 0.0
                _currentTime = 0.0
                _isRunning = false
                if didStopRunningCallback != nil {
                    didStopRunningCallback!(self)
                }
            }
        }
        
        @objc private func _timerArrive(_ timer: Timer) {
            _currentTime += 0.1
            _recLayer.progress = Double(_currentTime/numberOfSecondsSpentInATurn)
            if _currentTime >= maxRunningSeconds {
                stopRunning()
            }
        }
    }

}

extension KSMediaPickerCameraView.RECButton {
    
    private class RECLayer: CALayer {
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _backCircleLayer = {() -> CAShapeLayer in
            let backCircleLayer = CAShapeLayer()
            backCircleLayer.fillColor = UIColor.clear.cgColor
            backCircleLayer.strokeColor = UIColor.ks_white.withAlphaComponent(0.4).cgColor
            backCircleLayer.lineWidth = 8.0
            return backCircleLayer
        }()
        
        private let _frontCircleLayer = {() -> CAShapeLayer in
            let frontCircleLayer = CAShapeLayer()
            frontCircleLayer.fillColor = UIColor.clear.cgColor
            frontCircleLayer.strokeColor = UIColor.ks_white.cgColor
            frontCircleLayer.lineWidth = 8.0
            return frontCircleLayer
        }()
        
        private let _centerLayer = {() -> CALayer in
            let centerLayer = CALayer()
            centerLayer.backgroundColor = UIColor.ks_white.cgColor
            centerLayer.masksToBounds = true
            return centerLayer
        }()
        
        open var isChangeToSquare = false {
            didSet {
                setNeedsLayout()
            }
        }
        
        open var progress = 0.0 {
            didSet {
                setNeedsDisplay()
            }
        }
        
        override public init() {
            super.init()
            backgroundColor = UIColor.clear.cgColor
            addSublayer(_backCircleLayer)
            addSublayer(_frontCircleLayer)
            addSublayer(_centerLayer)
        }
        
        override func layoutSublayers() {
            super.layoutSublayers()
            let windowSize = bounds.size
            let windowWidth = windowSize.width
            let windowHeight = windowSize.height
            
            let lineWidth = _backCircleLayer.lineWidth
            let x = lineWidth*0.5
            let y = x
            let width = windowWidth-x*2.0
            let height = windowHeight-y*2.0
            let frame = CGRect(x: x, y: y, width: width, height: height)
            _backCircleLayer.frame = frame
            _frontCircleLayer.frame = frame
            _backCircleLayer.path = UIBezierPath(ovalIn: _backCircleLayer.bounds).cgPath
            
            let viewX: CGFloat
            let viewY: CGFloat
            let viewW: CGFloat
            let viewH: CGFloat
            if isChangeToSquare {
                viewW = windowWidth*0.5
                viewH = viewW
                viewX = (windowWidth-viewW)*0.5
                viewY = (windowHeight-viewH)*0.5
                _centerLayer.cornerRadius = 5.0
            } else {
                viewX = _backCircleLayer.lineWidth
                viewY = viewX
                viewW = windowWidth-viewX*2.0
                viewH = windowHeight-viewY*2.0
                _centerLayer.cornerRadius = viewW*0.5
            }
            _centerLayer.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        }
        
        override func draw(in ctx: CGContext) {
            super.draw(in: ctx)
            let circlePath: UIBezierPath
            let size = _frontCircleLayer.bounds.size
            let width = size.width
            let height = size.height
            let center = CGPoint(x: width*0.5, y: height*0.5)
            let radius = min(width, height)*0.5
            let pi = CGFloat.pi*2.0
            let startAngle = -(pi*0.25)
            let endAngle = CGFloat(progress)*pi+startAngle
            
            let isDoubleLoop = Int(progress)%2 == 0
            if isDoubleLoop {
                circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            } else {
                circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
            }
            _frontCircleLayer.path = circlePath.cgPath
        }
    }

}
