//
//  KSMediaPickerCameraToolBar.swift
// 
//
//  Created by kinsun on 2019/3/11.
//

import UIKit

extension KSMediaPickerCameraToolBar {
    
    open class button: UIControl {
        
        public enum style: UInt {
            case lightContent
            case darkContent
        }
        
        public enum status {
            case status1
            case status2
            case status3
        }
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _imageView = {() -> UIImageView in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        override public init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(_imageView)
        }
        
        override open func layoutSubviews() {
            super.layoutSubviews()
            _imageView.frame = bounds
        }
        
        open var status = button.status.status1 {
            didSet {
                _didSet(status: self.status, style: self.style)
            }
        }
        
        open var style = button.style.darkContent {
            didSet {
                _didSet(status: self.status, style: self.style)
            }
        }
        
        private func _didSet(status: button.status, style: button.style) {
            _imageView.image = image(of: status, of: style) ?? image(of: .status1, of: style)
        }
        
        private var _lightContentStatusImageArray = [button.status: UIImage]()
        private var _darkContentStatusImageArray = [button.status: UIImage]()
        
        open func set(image: UIImage, for status: button.status, of style: button.style) {
            switch style {
            case .lightContent:
                _lightContentStatusImageArray[status] = image
                break
            case .darkContent:
                _darkContentStatusImageArray[status] = image
                break
            }
            if self.status == status, self.style == style {
                _imageView.image = image
            }
        }
        
        open func image(of status: button.status, of style: button.style) -> UIImage? {
            let array: [button.status: UIImage]
            switch style {
            case .lightContent:
                array = _lightContentStatusImageArray
                break
            case .darkContent:
                array = _darkContentStatusImageArray
                break
            }
            return array[status]
        }
    }
}

open class KSMediaPickerCameraToolBar: UIView {
    
    public enum toolBarType: UInt {
        case photos
        case noFlashlightPhotos
        case videos
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public let closeButton = {() -> KSMediaPickerCameraToolBar.button in
        let closeButton = KSMediaPickerCameraToolBar.button()
        closeButton.set(image: UIImage(named: "icon_mediaPicker_camera_close")!, for: .status1, of: .lightContent)
        closeButton.set(image: UIImage(named: "icon_mediaPicker_camera_close_b")!, for: .status1, of: .darkContent)
        return closeButton
    }()
    public let priviewSizeButton = {() -> KSMediaPickerCameraToolBar.button in
        let priviewSizeButton = KSMediaPickerCameraToolBar.button()
        priviewSizeButton.set(image: UIImage(named: "icon_mediaPicker_camera_square")!, for: .status1, of: .lightContent)
        priviewSizeButton.set(image: UIImage(named: "icon_mediaPicker_camera_square_b")!, for: .status1, of: .darkContent)
        priviewSizeButton.set(image: UIImage(named: "icon_mediaPicker_camera_rectangle")!, for: .status2, of: .lightContent)
        priviewSizeButton.set(image: UIImage(named: "icon_mediaPicker_camera_rectangle_16_9")!, for: .status3, of: .lightContent)
        return priviewSizeButton
    }()
    public let flashlightButton = {() -> KSMediaPickerCameraToolBar.button in
        let flashlightButton = KSMediaPickerCameraToolBar.button()
        flashlightButton.set(image: UIImage(named: "icon_mediaPicker_camera_flashlight_auto")!, for: .status1, of: .lightContent)
        flashlightButton.set(image: UIImage(named: "icon_mediaPicker_camera_flashlight_auto_b")!, for: .status1, of: .darkContent)
        flashlightButton.set(image: UIImage(named: "icon_mediaPicker_camera_flashlight_on")!, for: .status2, of: .lightContent)
        flashlightButton.set(image: UIImage(named: "icon_mediaPicker_camera_flashlight_on_b")!, for: .status2, of: .darkContent)
        flashlightButton.set(image: UIImage(named: "icon_mediaPicker_camera_flashlight_off")!, for: .status3, of: .lightContent)
        flashlightButton.set(image: UIImage(named: "icon_mediaPicker_camera_flashlight_off_b")!, for: .status3, of: .darkContent)
        return flashlightButton
    }()
    public let cameraOrientation = {() -> KSMediaPickerCameraToolBar.button in
        let cameraOrientation = KSMediaPickerCameraToolBar.button()
        cameraOrientation.set(image: UIImage(named: "icon_mediaPicker_camera_switch")!, for: .status1, of: .lightContent)
        cameraOrientation.set(image: UIImage(named: "icon_mediaPicker_camera_switch_b")!, for: .status1, of: .darkContent)
        return cameraOrientation
    }()
    
    open var didChangedStyleCallback: ((KSMediaPickerCameraToolBar.button.style) -> Void)?
    
    open var style: KSMediaPickerCameraToolBar.button.style {
        didSet {
            if oldValue != style {
                _didSet(style: style)
                if didChangedStyleCallback != nil {
                    didChangedStyleCallback!(style)
                }
            }
        }
    }
    open var type = KSMediaPickerCameraToolBar.toolBarType.photos {
        didSet {
            let flashlightIsHidden = type != .photos
            var isNeedAnimation = false
            if flashlightIsHidden != flashlightButton.isHidden {
                flashlightButton.isHidden = flashlightIsHidden
                isNeedAnimation = true
            }
            let priviewSizeIsHidden = type == .videos
            if priviewSizeIsHidden != priviewSizeButton.isHidden {
                priviewSizeButton.isHidden = priviewSizeIsHidden
                isNeedAnimation = true
            }
            if isNeedAnimation {
                UIView.animate(withDuration: 0.2) {[weak self] in
                    self?.layoutSubviews()
                }
            }
        }
    }
     
    public init(frame: CGRect, style: KSMediaPickerCameraToolBar.button.style) {
        self.style = style
        super.init(frame: frame)
        _didSet(style: style)
        backgroundColor = .clear
        
        addSubview(closeButton)
        addSubview(priviewSizeButton)
        addSubview(flashlightButton)
        addSubview(cameraOrientation)
    }
    
    public convenience init(style: KSMediaPickerCameraToolBar.button.style) {
        self.init(frame: .zero, style: style)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let windowSize = bounds.size
        let windowWidth = windowSize.width
        let windowHeight = windowSize.height
        let floatZore = CGFloat(0.0)
        
        var buttons = [closeButton, cameraOrientation]
        switch type {
        case .photos:
            buttons.insert(priviewSizeButton, at: 1)
            buttons.insert(flashlightButton, at: 2)
            break
        case .noFlashlightPhotos:
            buttons.insert(priviewSizeButton, at: 1)
            break
        case .videos:
            break
        }
        
        let count = CGFloat(buttons.count)
        var viewX = floatZore
        let viewY = floatZore
        let viewW = CGFloat(70.0)
        let viewH = windowHeight
        let margin = (windowWidth-(viewW*count))/(count-1)
        
        for (i, button) in buttons.enumerated() {
            viewX = (viewW+margin)*CGFloat(i)
            button.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        }
    }
    
    private func _didSet(style: KSMediaPickerCameraToolBar.button.style) {
        closeButton.style = style
        priviewSizeButton.style = style
        priviewSizeButton.style = style
        flashlightButton.style = style
        flashlightButton.style = style
        cameraOrientation.style = style
        cameraOrientation.style = style
    }
}
