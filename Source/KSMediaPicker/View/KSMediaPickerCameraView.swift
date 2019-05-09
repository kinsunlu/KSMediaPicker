//
//  KSMediaPickerCameraView.swift
// 
//
//  Created by kinsun on 2019/3/11.
//

import UIKit

extension KSMediaPickerCameraView {
    
    public enum style {
        case unknown
        case photo
        case video
    }
    
    private enum previewSize: UInt {
        case square
        case hdPicture
        case hdVideo
        
        private static let _squareSize = CGSize(width: 1.0, height: 1.0)
        private static let _hdPictureSize = CGSize(width: 3.0, height: 4.0)
        private static let _hdVideoSize = CGSize(width: 9.0, height: 16.0)
        
        public var cgSizeValue: CGSize {
            get {
                switch self {
                case .square:
                    return previewSize._squareSize
                case .hdPicture:
                    return previewSize._hdPictureSize
                case .hdVideo:
                    return previewSize._hdVideoSize
                }
            }
        }
    }
}

import AVFoundation

open class KSMediaPickerCameraView: UIView, AVCaptureFileOutputRecordingDelegate {

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if arch(i386) || arch(x86_64)
    private let _frontCameraDevice: AVCaptureDevice?
    private let _backCameraDevice: AVCaptureDevice?
    #else
    private let _frontCameraDevice: AVCaptureDevice
    private let _backCameraDevice: AVCaptureDevice
    #endif
    private var _videoInput: AVCaptureDeviceInput?
    private lazy var _audioInput = {() -> AVCaptureDeviceInput? in
        if let audio = AVCaptureDevice.default(for: .audio) {
            return try? AVCaptureDeviceInput(device: audio)
        }
        return nil
    }()
    private lazy var _imageOutput = AVCaptureStillImageOutput()
    private lazy var _videoOutput = {() -> AVCaptureMovieFileOutput in
        let videoOutput = AVCaptureMovieFileOutput()
        videoOutput.movieFragmentInterval = CMTime(value: 1, timescale: 1)
        return videoOutput
    }()
    private let _session = {() -> AVCaptureSession in
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        return session
    }()
    private let _previewLayer: AVCaptureVideoPreviewLayer
    public let toolBar = KSMediaPickerCameraToolBar(style: .darkContent)
    
    public let scrollView = {() -> KSMediaPickerScrollView in
        let scrollView = KSMediaPickerScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    private let _takePhotoButton = {() -> UIButton in
        let frame = CGRect(origin: .zero, size: CGSize(width: 80.0, height: 80.0))
        let takePhotoButton = KSBorderButton(type: .custom)
        takePhotoButton.frame = frame
        let layer = takePhotoButton.layer
        layer.masksToBounds = true
        layer.borderWidth = 8.0
        layer.cornerRadius = frame.size.height*0.5
        let color = UIColor.ks_main
        let borderColor = UIColor.ks_lightMain
        takePhotoButton.setBackgroundColor(color, for: .normal)
        takePhotoButton.setBackgroundColor(color.withAlphaComponent(0.5), for: .highlighted)
        takePhotoButton.setBorderColor(borderColor, for: .normal)
        takePhotoButton.setBorderColor(borderColor.withAlphaComponent(0.5), for: .highlighted)
        return takePhotoButton
    }()
    private let _takeVideoButton = RECButton(frame: CGRect(origin: .zero, size: CGSize(width: 80.0, height: 80.0)))
    
    override public init(frame: CGRect) {
        #if arch(i386) || arch(x86_64)
        _frontCameraDevice = nil
        _backCameraDevice = nil
        #else
        var frontCameraDevice: AVCaptureDevice? = nil
        var backCameraDevice: AVCaptureDevice? = nil
        let devices = AVCaptureDevice.devices(for: .video)
        for device in devices {
            switch device.position {
            case .back:
                backCameraDevice = device
                break
            case .front:
                frontCameraDevice = device
                break
            default:
                break
            }
        }
        _frontCameraDevice = frontCameraDevice!
        _backCameraDevice = backCameraDevice!
        #endif
        
        _previewLayer = AVCaptureVideoPreviewLayer(session: _session)
        _previewLayer.videoGravity = .resizeAspectFill
        _previewLayer.backgroundColor = UIColor.ks_black.cgColor
        startRunning = _session.startRunning
        stopRunning = _session.stopRunning
        super.init(frame: frame)
        backgroundColor = .clear
        #if arch(i386) || arch(x86_64)
        _videoInput = nil
        #else
        _videoInput = _videoInputFrom(device: _backCameraDevice)
        #endif
        if let input = _videoInput, _session.canAddInput(input) {
            _session.addInput(input)
        }
        
        layer.addSublayer(_previewLayer)
        
        _takePhotoButton.addTarget(self, action: #selector(_didClick(takePhotoButton:)), for: .touchUpInside)
        scrollView.addSubview(_takePhotoButton)
        _takeVideoButton.addTarget(self, action: #selector(_didClick(takeVideoButton:)), for: .touchUpInside)
        _takeVideoButton.didStopRunningCallback = {[weak self] (button) in
            self?._didFinishRecVideo(button: button)
        }
        scrollView.addSubview(_takeVideoButton)
        addSubview(scrollView)
        toolBar.cameraOrientation.addTarget(self, action: #selector(_didClick(cameraOrientation:)), for: .touchUpInside)
        toolBar.priviewSizeButton.addTarget(self, action: #selector(_didClick(priviewSizeButton:)), for: .touchUpInside)
        toolBar.flashlightButton.addTarget(self, action: #selector(_didClick(flashlightButton:)), for: .touchUpInside)
        addSubview(toolBar)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        let windowSize = bounds.size
        let windowWidth = windowSize.width
        let floatZore = CGFloat(0.0)
        
        var viewX = floatZore
        var viewY = UIView.statusBarSize.height
        var viewW = windowWidth
        var viewH = UIView.navigationBarSize.height
        toolBar.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        scrollView.frame = bounds
        scrollView.contentSize = CGSize(width: windowWidth*2.0, height: 0.0)
        
        let size = _takePhotoButton.bounds.size
        viewW = size.width
        viewH = size.height
        viewX = (windowWidth-viewW)*0.5
        viewY = scrollView.bounds.size.height-viewH
        _takePhotoButton.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        viewX += windowWidth
        _takeVideoButton.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
    }
    
    override open func layoutSublayers(of layer: CALayer) {
        let windowSize = layer.bounds.size
        let windowWidth = windowSize.width
        let floatZore = CGFloat(0.0)
        
        let viewX = floatZore
        let viewY: CGFloat
        let viewW = windowWidth
        let viewH: CGFloat
        switch _previewSizeType {
        case .square:
            viewY = UIView.statusBarNavigationBarSize.height
            viewH = viewW
            break
        default:
            viewY = floatZore
            let size = _previewSizeType.cgSizeValue
            viewH = floor(size.height/size.width*viewW)
            break
        }
        _previewLayer.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        super.layoutSublayers(of: layer)
    }
    
    open var style = KSMediaPickerCameraView.style.unknown {
        didSet {
            let style = self.style
            if oldValue != style {
                let priviewSizeButton = toolBar.priviewSizeButton
                priviewSizeButton.status = style == .photo ? .status2 : .status1
                _didClick(priviewSizeButton: priviewSizeButton)
                _didSet(style: style)
            }
        }
    }
    
    private func _didSet(style: KSMediaPickerCameraView.style) {
        _session.beginConfiguration()
        switch style {
        case .photo:
            _session.sessionPreset = .photo
            _session.removeOutput(_videoOutput)
            if let audioInput = _audioInput {
                _session.removeInput(audioInput)
            }
            if _session.canAddOutput(_imageOutput) {
                _session.addOutput(_imageOutput)
            }
            break
        case .video:
            _session.sessionPreset = .iFrame960x540
            _session.removeOutput(_imageOutput)
            if let audioInput = _audioInput, _session.canAddInput(audioInput) {
                _session.addInput(audioInput)
            }
            if _session.canAddOutput(_videoOutput) {
                _session.addOutput(_videoOutput)
                if let connection = _videoOutput.connections.first,
                    connection.isVideoOrientationSupported,
                    connection.videoOrientation != .portrait {
                    connection.videoOrientation = .portrait
                }
            }
            break
        default:
            break
        }
        _session.commitConfiguration()
    }
    
    private var _previewSizeType = KSMediaPickerCameraView.previewSize.square {
        didSet {
            setNeedsLayout()
        }
    }

    public let startRunning: () -> Void
    public let stopRunning: () -> Void
    open var didTakePhotoCallback: ((KSMediaPickerCameraView, UIImage) -> Void)?
    open var didTakeVideoCallback: ((KSMediaPickerCameraView, URL) -> Void)?
    
    open var isBackCameraDevice: Bool {
        return _videoInput?.device == _backCameraDevice
    }
    
    @objc private func _didClick(cameraOrientation: KSMediaPickerCameraToolBar.button) {
        #if arch(i386) || arch(x86_64)
        #else
        guard let input = _videoInput else {
            return
        }
        
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        trans.type = CATransitionType(rawValue: "oglFlip")
        
        var device = input.device
        if device == _frontCameraDevice {
            device = _backCameraDevice
            trans.subtype = .fromLeft
        } else if device == _backCameraDevice {
            device = _frontCameraDevice
            trans.subtype = .fromRight
        }
        guard let newInput = _videoInputFrom(device: device) else {
            return
        }
        _session.beginConfiguration()
        _session.removeInput(input)
        if _session.canAddInput(newInput) {
            _session.addInput(newInput)
            _videoInput = newInput
            if self.style == .video {
                toolBar.type = .videos
            } else {
                toolBar.type = device == _backCameraDevice ? .photos : .noFlashlightPhotos
            }
        } else {
            _session.addInput(input)
        }
        _session.commitConfiguration()
        _previewLayer.add(trans, forKey: nil)
        #endif
    }
    
    private func _videoInputFrom(device: AVCaptureDevice) -> AVCaptureDeviceInput? {
        let input: AVCaptureDeviceInput?
        do {
            try input = AVCaptureDeviceInput(device: device)
        } catch {
            input = nil
        }
        return input
    }
    
    @objc private func _didClick(priviewSizeButton: KSMediaPickerCameraToolBar.button) {
        let status = priviewSizeButton.status
        let newStatus: KSMediaPickerCameraToolBar.button.status
        let sizeType: KSMediaPickerCameraView.previewSize
        switch self.style {
        case .photo:
            switch status {
            case .status1://1:1
                newStatus = .status2
                sizeType = .hdPicture
                toolBar.style = .lightContent
                break
            case .status2://3:4
                newStatus = .status1
                sizeType = .square
                toolBar.style = .darkContent
                break
            default:
                return
            }
            break
        case .video:
            switch status {
            case .status1://1:1
                newStatus = .status3
                sizeType = .hdVideo
                break
            case .status3://9:16
                newStatus = .status1
                sizeType = .square
                break
            default:
                return
            }
            break
        default:
            return
        }
        priviewSizeButton.status = newStatus
        _previewSizeType = sizeType
    }
    
    @objc private func _didClick(flashlightButton: KSMediaPickerCameraToolBar.button) {
        guard let device = _videoInput?.device,
        self.style == .photo else {
            return
        }
        try? device.lockForConfiguration()
        let status = flashlightButton.status
        let newStatus: KSMediaPickerCameraToolBar.button.status
        let flashMode: AVCaptureDevice.FlashMode
        switch status {
        case .status1://auto
            newStatus = .status2
            flashMode = .on
            break
        case .status2://on
            newStatus = .status3
            flashMode = .off
            break
        case .status3://off
            newStatus = .status1
            flashMode = .auto
            break
        }
        if device.isFlashModeSupported(flashMode) {
            flashlightButton.status = newStatus
            device.flashMode = flashMode
        }
    }
    
    @objc private func _didClick(takePhotoButton: KSBorderButton) {
        guard let conntion = _imageOutput.connection(with: .video) else {
            return
        }
        _imageOutput.captureStillImageAsynchronously(from: conntion, completionHandler: _didTakePhotoAfter)
    }
    
    private func _didTakePhotoAfter(imageDataSampleBuffer: CMSampleBuffer?, error: Error?) {
        guard let k_imageDataSampleBuffer = imageDataSampleBuffer,
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(k_imageDataSampleBuffer) else {
            return
        }
        let image = UIImage(JPEGData: imageData, of: _previewSizeType.cgSizeValue)
        stopRunning()
        if didTakePhotoCallback != nil {
            didTakePhotoCallback!(self, image)
        }
    }
    
    @objc private func _didClick(takeVideoButton: RECButton) {
        if takeVideoButton.isRunning {
            _session.stopRunning()
            _videoOutput.stopRecording()
        } else {
            takeVideoButton.startRunning()
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy_MM_dd_HH_mm_ss"
            let tmpPath = NSTemporaryDirectory()
            let filePath = tmpPath+dateFormat.string(from: Date())+".mov"
            let fileURL = URL(fileURLWithPath: filePath)
            _videoOutput.startRecording(to: fileURL, recordingDelegate: self)
            _session.startRunning()
        }
    }
    
    private func _didFinishRecVideo(button: RECButton) {
        if _videoFileURL != nil {
            if didTakeVideoCallback != nil {
                didTakeVideoCallback!(self, _videoFileURL!)
            }
            _videoFileURL = nil
        }
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    private var _videoFileURL: URL?
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        _videoFileURL = outputFileURL
        _takeVideoButton.stopRunning()
    }
}
