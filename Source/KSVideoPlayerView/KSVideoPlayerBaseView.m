//
//  KSVideoPlayerBaseView.m
// 
//
//  Created by kinsun on 2018/12/10.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import "KSVideoPlayerBaseView.h"

@interface KSVideoPlayerBaseView ()

@property (nonatomic, assign, getter=playerIsInView, readonly) BOOL playerInView;

@end

@implementation KSVideoPlayerBaseView {
    __weak KSVideoLayer *_player;
    BOOL _isHiddenAnimating;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
        [center addObserver:self selector:@selector(_didChangedPlayerSuperLayer:) name:KSVideoLayerDidChangedNotification object:nil];
        [center addObserver:self selector:@selector(_didResetPlayer:) name:KSVideoLayerDidResetNotification object:nil];
        _videoGravity = KSVideoLayerGravityResizeAspect;
        _volume = 1.f;
        _player = [KSVideoLayer shareInstance];
        self.backgroundColor = UIColor.clearColor;
        self.clipsToBounds = YES;
        
        UIImageView *coverView = [[UIImageView alloc] init];
        coverView.contentMode = UIViewContentModeScaleAspectFit;
        coverView.clipsToBounds = YES;
        [self addSubview:coverView];
        _coverView = coverView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _coverView.frame = self.bounds;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if (self.playerIsInView) {
        _player.frame = layer.bounds;
    }
}

- (void)setShowToolsBar:(BOOL)showToolsBar {
    _showToolsBar = showToolsBar;
    if (_playing && showToolsBar && !_isHiddenAnimating) {
        _isHiddenAnimating = YES;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf _autoHiddenTools];
        });
    }
}

- (void)_autoHiddenTools {
    _isHiddenAnimating = NO;
    if (_playing) self.showToolsBar = NO;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        [self pause];
    }
}

- (void)_clikeCenterButton:(UIButton *)btn {
    if (_playing) {
        [self pause];//暂停
    } else {
        [self play];//播放
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    _playerItem = playerItem;
    [self resetViewStatus];
}

- (void)_didChangedPlayerSuperLayer:(NSNotification *)noti {
    KSVideoLayer *player = noti.object;
    if (player == _player && player.superlayer != self.layer) {
        [self resetViewStatus];
    }
}

- (void)_didResetPlayer:(NSNotification *)noti {
    if (noti.object == _player) {
        [self resetViewStatus];
    }
}

- (void)resetViewStatus {
    [self pause];
    self.playing = NO;
    _coverView.hidden = NO;
}

- (void)setVolume:(float)volume {
    _volume = volume;
    if (self.playerInView) _player.volume = volume;
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
}

- (void)play {
    if (_playerItem != nil && !_playing) {
        _coverView.hidden = YES;
        self.playing = YES;
        CALayer *layer = self.layer;
        KSVideoLayer *player = _player;
        if (player.superlayer != layer) {
            player.videoGravity = _videoGravity;
            player.volume = _volume;
            player.videoCanBePlayed = _videoCanBePlayed;
            player.videoTimeDidChangdCallback = _videoTimeDidChangdCallback;
            player.videoTimeDidChangdWithLeftTime = _videoTimeDidChangdWithLeftTime;
            __weak typeof(self) weakSelf = self;
            [player setVideoPlaybackFinished:^{
                [weakSelf resetViewStatus];
                void (^videoPlaybackFinished)(void) = weakSelf.videoPlaybackFinished;
                if (videoPlaybackFinished != nil) {
                    videoPlaybackFinished();
                }
            }];
            [layer insertSublayer:player atIndex:0];
            [layer setNeedsLayout];
            [NSNotificationCenter.defaultCenter postNotificationName:KSVideoLayerDidChangedNotification object:player];
        }
        player.playerItem = _playerItem;
        self.showToolsBar = YES;
    }
}

- (void)pause {
    if (self.playerIsInView) {
        [_player pause];
    }
    self.playing = NO;
    self.showToolsBar = YES;
}

- (BOOL)playerIsInView {
    return _player != nil && _player.superlayer == self.layer;
}

- (void)setVideoGravity:(KSVideoLayerGravity)videoGravity {
    _videoGravity = videoGravity;
    _player.videoGravity = videoGravity;
    switch (videoGravity) {
        case KSVideoLayerGravityResize:
            _coverView.contentMode = UIViewContentModeScaleToFill;
            break;
        case KSVideoLayerGravityResizeAspect:
            _coverView.contentMode = UIViewContentModeScaleAspectFit;
            break;
        case KSVideoLayerGravityResizeAspectFill:
            _coverView.contentMode = UIViewContentModeScaleAspectFill;
            break;
    }
}

- (void)changeVideoTime:(float)time {
    [_player changeVideoTime:time];
}

- (void)dealloc {
    if (self.playerIsInView) {
        [_player resetPlayer];
    }
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center removeObserver:self name:KSVideoLayerDidResetNotification object:nil];
    [center removeObserver:self name:KSVideoLayerDidChangedNotification object:nil];
}

@end
