//
//  XSLScnceneView.h
//  XSLscnscene
//
//  Created by admin on 2/11/17.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XSLScnceneView : UIView

/**全景图*/
@property (nonatomic,copy)NSString *image;

/**鱼眼效果 ,默认去\关闭*/
@property (nonatomic,assign) BOOL isFish;
//惯性滑动，追求滑动稳定可以关闭。
@property(nonatomic,assign)BOOL scrollInertia;

@end
