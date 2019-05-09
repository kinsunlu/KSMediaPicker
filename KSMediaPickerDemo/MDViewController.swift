//
//  ViewController.swift
//  KSMediaPickerDemo
//
//  Created by kinsun on 2019/4/29.
//  Copyright © 2019年 kinsun. All rights reserved.
//

import UIKit

extension MDViewController {
    
    private class previewCell: UICollectionViewCell {
        
        public static let k_iden = NSStringFromClass(previewCell.self)
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _imageView = {() -> UIImageView in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        }()
        
        private let _playIconView = {() -> UIImageView in
            let playIconView = UIImageView(image: UIImage(named: "icon_video_play"))
            playIconView.contentMode = .center
            playIconView.isHidden = true
            return playIconView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(_imageView)
            contentView.addSubview(_playIconView)
        }
        
        override func layoutSubviews() {
            let bounds = contentView.bounds
            _imageView.frame = bounds
            _playIconView.frame = bounds
        }
        
        open var model: KSMediaPickerOutputModel? {
            didSet {
                _imageView.image = model?.thumb
                _playIconView.isHidden = model?.mediaType != .video
            }
        }
        
        open var imageViewFrameInSuperView: CGRect? {
            let contentView = _imageView.superview
            let cell = contentView?.superview
            let wrapperView = cell?.superview
            let collcetionView = wrapperView?.superview
            let view = collcetionView?.superview
            return cell?.convert(_imageView.frame, to: view)
        }
    }
}

class MDViewController: UIViewController, KSMediaPickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let _mediaView: UICollectionView
    private let _layout = {() -> UICollectionViewFlowLayout in
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2.0
        layout.minimumInteritemSpacing = 2.0
        layout.sectionInset = .zero
        return layout
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let mediaView = UICollectionView(frame: .zero, collectionViewLayout: _layout)
        _mediaView = mediaView
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        mediaView.backgroundColor = .ks_background
        if #available(iOS 11.0, *) {
            mediaView.contentInsetAdjustmentBehavior = .never
        }
        mediaView.contentInset = .zero
        let obj = previewCell.self
        mediaView.register(obj, forCellWithReuseIdentifier: obj.k_iden)
        mediaView.delegate = self
        mediaView.dataSource = self
    }
    
    private let _startButton = {() -> UIButton in
        let startButton = UIButton(type: .custom)
        startButton.titleLabel?.font = .systemFont(ofSize: 14.0)
        startButton.setTitleColor(.ks_wordMain, for: .normal)
        startButton.setTitle("选择媒体", for: .normal)
        return startButton
    }()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .ks_white
        view.addSubview(_mediaView)
        _startButton.addTarget(self, action: #selector(_didClick(startButton:)), for: .touchUpInside)
        view.addSubview(_startButton)
        self.view = view
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let boundsSize = view.bounds.size
        let windowWidth = boundsSize.width
        let windowHeight = boundsSize.height
        
        var viewW = floor((windowWidth-6.0)*0.25)
        var viewH = viewW
        _layout.itemSize = CGSize(width: viewW, height: viewH)
        
        viewW = windowWidth
        viewH = windowWidth
        let viewX = CGFloat(0.0)
        var viewY = (windowHeight-viewH)*0.5
        _mediaView.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
        
        viewY = _mediaView.frame.maxY
        viewH = windowHeight-viewY-UIEdgeInsets.safeAreaInsets.bottom
        _startButton.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
    }
    
    @objc private func _didClick(startButton: UIButton) {
        let alert = UIAlertController(title: "选取类型", message: "混合选择：视频和照片可以同时选择。\n单一媒体类型选择：当选择视频后所有照片将进入不可选状态，反之亦然。", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancel)
        let mix = UIAlertAction(title: "混合选择", style: .default) {[weak self] (action) in
            let ctl = KSMediaPickerController(maxItemCount: 16)
            ctl.delegate = self
            let nav = KSNavigationController(rootViewController: ctl)
            self?.present(nav, animated: true, completion: nil)
        }
        alert.addAction(mix)
        let individual = UIAlertAction(title: "单一媒体类型选择", style: .default) {[weak self] (action) in
            /// 两个参数都请不要传0，因为没处理单媒体类型录影和拍照的问题
            let ctl = KSMediaPickerController(maxVideoItemCount: 1, maxPictureItemCount: 9)
            ctl.delegate = self
            let nav = KSNavigationController(rootViewController: ctl)
            self?.present(nav, animated: true, completion: nil)
        }
        alert.addAction(individual)
        present(alert, animated: true, completion: nil)
    }
    
    private var _mediaArray: [KSMediaPickerOutputModel]?
    
    func mediaPicker(_ mediaPicker: KSMediaPickerController, didFinishSelected outputArray: [KSMediaPickerOutputModel]) {
        mediaPicker.navigationController?.dismiss(animated: true, completion: nil)
        _mediaArray = outputArray
        _mediaView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _mediaArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: previewCell.k_iden, for: indexPath) as! previewCell
        cell.model = _mediaArray?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let mediaArray = _mediaArray {
            let ctl = KSMediaPickerViewerController()
            ctl.itemFrameAtIndex = {[weak self] (index) -> CGRect in
                let k_indexPath = IndexPath(item: Int(index), section: 0)
                let cell = self?._mediaView.cellForItem(at: k_indexPath) as? previewCell
                return cell?.imageViewFrameInSuperView ?? .zero
            }
            ctl.willBeginCloseAnimation = {[weak self] (index) in
                let k_indexPath = IndexPath(item: Int(index), section: 0)
                self?._mediaView.scrollToItem(at: k_indexPath, at: UICollectionView.ScrollPosition(rawValue: 0), animated: false)
            }
            ctl.setDataArray(mediaArray, currentIndex: indexPath.item)
            present(ctl, animated: true, completion: nil)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

