//
//  KSLayout.h
//
//  Created by kinsun on 2018/10/29.
//  Copyright © 2018年 kinsun. All rights reserved.
//

#ifndef KSLayout_h
#define KSLayout_h

#define k_creatFrameElement     CGFloat viewX=0.f, viewY=0.f, viewW=0.f, viewH=0.f
#define k_setFrame              (CGRect){viewX, viewY, viewW, viewH}
#define k_settingFrame(view)    (view).frame = k_setFrame
#define k_creatWindowSizeElement(width, height) CGFloat windowWidth = (width), windowHeight = (height)
#define k_creatSizeElementOfSize(size)  k_creatWindowSizeElement((size).width, (size).height)
#define k_creatSelfSizeElement CGSize kkkk_size = self.bounds.size;\
k_creatSizeElementOfSize(kkkk_size)

//全局屏幕相关
#define k_MAIN_SCREEN   UIScreen.mainScreen
#define k_SCREEN_BOUNDS k_MAIN_SCREEN.bounds
#define k_SCREEN_WIDTH  k_SCREEN_BOUNDS.size.width
#define k_SCREEN_HEIGHT k_SCREEN_BOUNDS.size.height
#define k_SCREEN_SCALE  k_MAIN_SCREEN.scale

#endif /* KSLayout_h */
