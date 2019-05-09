//
//  KSIndicatorLabelControl.m
//  kinsun
//
//  Created by kinsun on 2018/12/1.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#import "KSIndicatorLabelControl.h"
#import "KSLayout.h"

@implementation KSIndicatorLabelControl {
    __weak CATextLayer *_textLayer;
    
    CGFloat _alpha;
}
@synthesize font = _font, color = _color;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _initView];
    }
    return self;
}

- (void)_initView {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.wrapped = YES;
    textLayer.alignmentMode = kCAAlignmentRight;
    textLayer.contentsScale = k_SCREEN_SCALE;
    [self.layer addSublayer:textLayer];
    _textLayer = textLayer;
    
    [self willFinishInit];
    
    self.font = [UIFont systemFontOfSize:12.f];
    self.color = UIColor.lightGrayColor;
    self.alpha = 1.f;
}

- (void)willFinishInit {}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    k_creatFrameElement;
    CGSize textSize = [self textSizeOfSize:layer.frame.size];
    viewW = textSize.width; viewH = _font.lineHeight; viewY = (layer.frame.size.height-viewH)*0.5f-1.f;
    k_settingFrame(_textLayer);
}

- (CGSize)textSizeOfSize:(CGSize)size {
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    id string = _textLayer.string;
    CGSize k_size = CGSizeZero;
    if ([string isKindOfClass:NSString.class]) {
        NSDictionary <NSAttributedStringKey, id> *attributes = @{NSFontAttributeName: _font};
        k_size = [string boundingRectWithSize:size options:options attributes:attributes context:nil].size;
    } else {
        k_size = [string boundingRectWithSize:size options:options context:nil].size;
    }
    return k_size;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    super.alpha = enabled ? _alpha : 0.5f;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    super.alpha = highlighted ? 0.5f : _alpha;
}

- (void)setAlpha:(CGFloat)alpha {
    _alpha = alpha;
    if (self.enabled && !self.isHighlighted) {
        [super setAlpha:alpha];
    } else {
        [super setAlpha:0.5f];
    }
}

- (CGFloat)alpha {
    return _alpha;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (font != nil) {
        CFStringRef fontCFString = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef = CGFontCreateWithFontName(fontCFString);
        _textLayer.font = fontRef;
        _textLayer.fontSize = font.pointSize;
        CGFontRelease(fontRef);
    }
}

- (void)setColor:(UIColor *)color {
    _color = color;
    if (color != nil) {
        _textLayer.foregroundColor = color.CGColor;
    }
}

- (void)setText:(NSString *)text {
    _textLayer.string = text;
}

- (NSString *)text {
    return _textLayer.string;
}

- (void)setAttributText:(NSAttributedString *)attributText {
    _textLayer.string = attributText;
}

- (NSAttributedString *)attributText {
    return _textLayer.string;
}

@end
