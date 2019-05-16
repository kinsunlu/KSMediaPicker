//
//  KSMediaPickerHandlerController.swift
// 
//
//  Created by kinsun on 2019/3/21.
//

import UIKit
import Photos

open class KSMediaPickerHandlerController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let _layout = {() -> UICollectionViewFlowLayout in
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = .zero
        return layout
    }()
    
    private let _collectionView: UICollectionView
    
    private let _navigationView = KSMediaPickerHandlerController.navigationView()
    
    public let itemModelArray: [KSMediaPickerItemModel]
    
    public required init(itemModelArray: [KSMediaPickerItemModel]) {
        self.itemModelArray = itemModelArray
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: _layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        _collectionView = collectionView
        super.init(nibName: nil, bundle: nil)
    }
    
    private static let k_class_picture = KSMediaPickerHandlerPictureCell.self
    private static let k_class_video = KSMediaPickerHandlerVideoCell.self
    private static let k_iden_picture = NSStringFromClass(k_class_picture)
    private static let k_iden_video = NSStringFromClass(k_class_video)
    
    override open func loadView() {
        let view = UIView()
        view.backgroundColor = .ks_background
        
        let classOjb = KSMediaPickerHandlerController.self
        
        _collectionView.register(classOjb.k_class_picture, forCellWithReuseIdentifier: classOjb.k_iden_picture)
        _collectionView.register(classOjb.k_class_video, forCellWithReuseIdentifier: classOjb.k_iden_video)
        _collectionView.dataSource = self
        _collectionView.delegate = self
        view.addSubview(_collectionView)
        
        _navigationView.nextButton.addTarget(self, action: #selector(_didClick(nextButton:)), for: .touchUpInside)
        _navigationView.closeButton.addTarget(self, action: #selector(_didClick(closeButton:)), for: .touchUpInside)
        view.addSubview(_navigationView)
        
        self.view = view
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _collectionView.frame = view.bounds
        
        let navHeight = UIView.statusBarNavigationBarSize.height
        _navigationView.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.size.width, height: navHeight))
        
        guard let size = itemModelArray.first?.contentSize else {
            return
        }
        
        let windowSize = view.bounds.size
        let windowWidth = windowSize.width
        let windowHeight = windowSize.height
        let itemSize: CGSize
        if size.width == windowWidth {
            itemSize = size
        } else {
            let width = windowWidth
            let height = floor(size.height*width/size.width)
            itemSize = CGSize(width: width, height: height)
        }
        _layout.itemSize = itemSize
        let bottom = windowHeight-navHeight-itemSize.height
        _collectionView.contentInset = UIEdgeInsets(top: navHeight, left: 0.0, bottom: bottom, right: 0.0)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        title = "1/\(itemModelArray.count)"
    }
    
    override open var title: String? {
        set {
            super.title = newValue
            _navigationView.title = newValue
        }
        get {
            return super.title
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let player = KSVideoLayer.shareInstance()
        if player.isPlaying {
            player.pause()
        }
    }
    
    @objc private func _didClick(closeButton: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    open var didPictureSelectedCompletionCallback: ((KSMediaPickerHandlerController, [KSMediaPickerOutputModel]) -> Void)?
    
    @objc private func _didClick(nextButton: UIButton) {
        if didPictureSelectedCompletionCallback != nil {
            var outputArray = Array<KSMediaPickerOutputModel>()
            for item in itemModelArray {
                let outputModel: KSMediaPickerOutputModel
                let asset = item.asset
                let mediaType = asset.mediaType
                switch mediaType {
                case .image:
                    guard let image = _image(from: item) else {
                        continue
                    }
                    outputModel = KSMediaPickerOutputModel(asset: asset, image: image, thumb: image.equalResize(sideLength: 105.0))
                    break
                case .video:
                    guard let videoAsset = _video(from: item) else {
                        continue
                    }
                    outputModel = KSMediaPickerOutputModel(asset: asset, videoAsset: videoAsset, thumb: item.thumb)
                    break
                default:
                    continue
                }
                outputArray.append(outputModel)
            }
            didPictureSelectedCompletionCallback!(self, outputArray)
        }
    }
    
    private func _image(from itemModel: KSMediaPickerItemModel) -> UIImage? {
        let asset = itemModel.asset
        let mainSize = UIScreen.main.bounds.size
        var k_image: UIImage? = nil
        PHImageManager.default().requestImage(for: asset, targetSize: mainSize, contentMode: .aspectFit, options: KSMediaPickerItemModel.pictureOptions) {(image, info) in
            k_image = image
        }
        if let image = k_image, let contentSize = itemModel.contentSize, var imageFrame = itemModel.imageFrame {
            let windowSize = _layout.itemSize
            let windowWidth = windowSize.width
            let imageWidth = contentSize.width
            if windowWidth != imageWidth {
                let scale = windowWidth/imageWidth
                imageFrame.size.width *= scale
                imageFrame.size.height *= scale
                imageFrame.origin.x *= scale
                imageFrame.origin.y *= scale
            }
            let imageSize = image.size
            let imageFrameSize = imageFrame.size
            let scaleWidth = imageSize.width/imageFrameSize.width
            let scaleHeight = imageSize.height/imageFrameSize.height
            let rect = CGRect(x: -(imageFrame.origin.x)*scaleWidth, y: -(imageFrame.origin.y)*scaleHeight, width: windowWidth*scaleWidth, height: windowSize.height*scaleHeight)
            let outputImageSize = CGSize(width: 720.0, height: windowSize.height*720.0/windowSize.width)
            k_image = image.cut(from: rect)?.aspectFit(from: outputImageSize, backgroundColor: .lightGray)
        }
        return k_image
    }
    
    private func _video(from itemModel: KSMediaPickerItemModel) -> AVURLAsset? {
        var urlAsset: AVAsset? = nil
        PHImageManager.default().requestAVAsset(forVideo: itemModel.asset, options: KSMediaPickerItemModel.videoOptions) {(k_urlAsset, audioMix, info) in
            urlAsset = k_urlAsset
        }
        repeat {
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.2))
        } while urlAsset == nil
        if urlAsset is AVURLAsset {
            return urlAsset as? AVURLAsset
        } else {
            return nil
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemModelArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemModel = itemModelArray[indexPath.item]
        let iden: String
        if itemModel.asset.mediaType == .image {
            iden = KSMediaPickerHandlerController.k_iden_picture
        } else {
            iden = KSMediaPickerHandlerController.k_iden_video
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: iden, for: indexPath) as! KSMediaPickerHandlerBaseCell
        cell.itemModel = itemModel
        return cell
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.bounds.size != .zero else {
            return
        }
        let offsetX = scrollView.contentOffset.x
        let width = scrollView.bounds.size.width
        let page = Int(ceil((offsetX-width*0.5)/width))
        if page != Int(_currentPage), page >= 0, page < itemModelArray.count {
            _currentPage = UInt(page)
        }
    }
    
    private var _currentPage = UInt(0) {
        didSet {
            title = "\(_currentPage+1)/\(itemModelArray.count)"
        }
    }
}

extension KSMediaPickerHandlerController {
    
    private class navigationView: UIView {
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _titleLabel = {() -> UILabel in
            let titleLabel = UILabel()
            titleLabel.font = .boldSystemFont(ofSize: 18.0)
            titleLabel.textAlignment = .center
            titleLabel.textColor = .ks_wordMain
            return titleLabel
        }()
        
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
        
        override public init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .ks_white
            addSubview(nextButton)
            addSubview(closeButton)
            addSubview(_titleLabel)
        }
        
        override func layoutSubviews() {
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
            _titleLabel.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        }
        
        open var title: String? {
            set {
                _titleLabel.text = newValue
            }
            get {
                return _titleLabel.text
            }
        }
    }
}
