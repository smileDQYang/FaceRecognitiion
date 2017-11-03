//
//  XSLScnceneView.m
//  XSLscnscene
//
//  Created by admin on 2/11/17.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import "XSLScnceneView.h"

@interface XSLScnceneView()

/**3D 引擎内容视图 */
@property(nonatomic,strong)SCNView *myScnView;

/**3d 引擎内容视图 相机场景的基本构建块 */
@property (nonatomic,strong) SCNNode *cameraNode;

/**3D 引擎内容视图 球体场景基本构建块*/
@property (nonatomic,strong) SCNNode *ballNode;

/** 3D 转动方向Z*/
@property (nonatomic,assign) CGFloat cameraPositionZ;


/** X轴方向渲染*/
@property (nonatomic,assign) CGFloat x_float;

/** y轴方向渲染*/
@property (nonatomic,assign) CGFloat  y_float;

/** z轴方向渲染 */
@property (nonatomic,assign) CGFloat  z_float;


/** 末尾缩放比例 */
@property (nonatomic,assign) CGFloat  lastZoomScale;

/** 起始缩放比例 */
@property (nonatomic,assign) CGFloat firstZoomScale;

/** 起始位置 */
@property (nonatomic,assign) CGPoint firstLocation;

/** 结束 位置*/
@property (nonatomic,assign) CGPoint lastLocation;

/** 结束 位置 2*/
@property (nonatomic,assign) CGPoint last2Location;


/**起始角度 x */
@property (nonatomic,assign) CGFloat firstXAngle;

/** 起始角度 2倍x */
@property (nonatomic,assign) CGFloat first2XAngle;

/** 起始角度 y */
@property (nonatomic,assign) CGFloat firstYAngle;

/** 起始角度 2倍 y*/
@property (nonatomic,assign) CGFloat first2YAngle;


/**当前相机 dis*/
@property (nonatomic,assign) CGFloat nowCameraDis;
/**最大相机 dis*/
@property (nonatomic,assign) CGFloat maxCameraDis;
/**最小相机 dis*/
@property (nonatomic,assign) CGFloat minCameraDis;

/**Z 轴 相机 点*/
@property (nonatomic,assign) CGFloat nowCameraPositionZ;


@property (nonatomic,strong) NSTimer *animationTimer_pan;
@property (nonatomic,strong) NSTimer *animationTimer_zoom;
@property int animationCount_pan;
@property int animationCount_zoom;
@property BOOL allowAnimation;




@end

@implementation XSLScnceneView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSetting];
        [self stepUI];
    }
    return  self;
}

#pragma mark- 创建 视图
-(void)stepUI{
    
    self.myScnView = [[SCNView alloc]initWithFrame:self.bounds];
    self.myScnView.scene = [SCNScene scene];  // 内容视图容器
    [self addSubview:self.myScnView];
    // camera
    self.cameraNode = [SCNNode node];
    self.cameraNode.camera = [SCNCamera camera];
    self.cameraNode.camera.automaticallyAdjustsZRange = YES;
    self.cameraNode.position = SCNVector3Make(0, 0, self.cameraPositionZ);
    self.cameraNode.camera.xFov = self.nowCameraDis;
    self.cameraNode.camera.yFov = self.nowCameraDis;
//    self.cameraNode.position = SCNVector3Make(0, 0, self.nowCameraPositionZ);
    [self.myScnView.scene.rootNode addChildNode:self.cameraNode];
    
    self.ballNode = [SCNNode node];
    SCNSphere *ball = [SCNSphere sphereWithRadius:200]; // 创建一个半径为200的球体
    ball.segmentCount = 80; // 球体上的线段数,默认是24 ,小于 3则相当于没有定义这个参数
    self.ballNode.geometry = ball;   // 返回到的接受的几何体;
    self.ballNode.geometry.firstMaterial.doubleSided = NO; //接收方是否为双侧,默认没有,可以做成动画
    self.ballNode.geometry.firstMaterial.cullMode = SCNCullModeFront;
    self.ballNode.position = SCNVector3Make(0, 0, 0);
    [self.myScnView.scene.rootNode addChildNode:self.ballNode];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(setPanAction:)];
    [self.myScnView addGestureRecognizer:pan];
}

#pragma mark- 默认设置
-(void)defaultSetting{
    self.lastZoomScale = 1;
    self.nowCameraDis = 60;
    self.maxCameraDis = 120;
    self.minCameraDis = 40;
    self.nowCameraPositionZ = 90;
    self.isFish = YES;  // 鱼眼效果
    self.scrollInertia = YES; // 默认有惯性
}


#pragma mark- 配置
-(void)setSCNScenePrame{
    
    
    
}

#pragma mark- 平移手势
-(void)setPanAction:(UIPanGestureRecognizer *)pan{
  
 
    if(pan.state == UIGestureRecognizerStateBegan){
        [self.animationTimer_pan invalidate];
        self.animationTimer_pan = nil;
        self.allowAnimation = NO;
        self.firstLocation = self.lastLocation;
    }else if(pan.state == UIGestureRecognizerStateChanged){
        CGPoint targetLocation = [pan translationInView:self.myScnView];
        
        CGFloat zoomRait = (self.nowCameraDis-self.minCameraDis)/(self.maxCameraDis-self.minCameraDis);//0~1
        zoomRait = 0.5 + 0.5*zoomRait;//0.5~1
        
        targetLocation = CGPointMake(targetLocation.x*zoomRait + self.firstLocation.x,
                                     targetLocation.y*zoomRait + self.firstLocation.y);
        
        self.last2Location = self.lastLocation;
        self.lastLocation = targetLocation;
        
        CGFloat rait = -(M_PI * 2)/(self.myScnView.frame.size.width) * 0.5;
        
        CGFloat YAngle = rait * targetLocation.x;
        CGFloat XAngle = rait * targetLocation.y;
        
        [self doScrollWithXangle:-XAngle Yangle:-YAngle animationDuration:0];
        
        //NSLog(@"%f",-YAngle - self.firstYAngle);
        if(-YAngle - self.firstYAngle>1){
            //NSLog(@"===========wait To Fix");
        }
        
        if(self.firstXAngle != -XAngle){
            self.first2XAngle = self.firstXAngle;
            self.firstXAngle = -XAngle;
        }
        if(self.firstYAngle != -YAngle){
            self.first2YAngle = self.firstYAngle;
            self.firstYAngle = -YAngle;
        }
    }else if(pan.state == UIGestureRecognizerStateEnded && self.scrollInertia){
        //挑战自己，手写惯性————————T_T
        [self.animationTimer_pan invalidate];
        self.animationCount_pan = 20;
        self.allowAnimation = YES;
        self.animationTimer_pan = [NSTimer timerWithTimeInterval:0.05
                                                         repeats:YES
                                                           block:^(NSTimer * _Nonnull timer)
                                   {
                                       self.animationCount_pan--;
                                       if(self.animationCount_pan<=0){
                                           [timer invalidate];
                                       }else if(self.allowAnimation){
                                           CGFloat countRait = ((double)self.animationCount_pan/20.0);
                                           CGFloat newXangle = self.firstXAngle+(self.firstXAngle-self.first2XAngle)*countRait;
                                           CGFloat newYangle = self.firstYAngle+(self.firstYAngle-self.first2YAngle)*countRait;
                                           
                                           CGPoint oldLocation = self.lastLocation;
                                           self.lastLocation = CGPointMake(self.lastLocation.x+(self.lastLocation.x-self.last2Location.x)*countRait,
                                                                           self.lastLocation.y+(self.lastLocation.y-self.last2Location.y)*countRait);
                                           self.last2Location = oldLocation;
                                           
                                           [self doScrollWithXangle:newXangle Yangle:newYangle animationDuration:0.05];
                                           
                                           CGFloat Xoldvalue = self.firstXAngle;
                                           CGFloat Yoldvalue = self.firstYAngle;
                                           
                                           self.firstXAngle = newXangle;
                                           self.firstYAngle = newYangle;
                                           self.first2XAngle = Xoldvalue;
                                           self.first2YAngle = Yoldvalue;
                                       }
                                       
                                   }];
        [[NSRunLoop currentRunLoop]addTimer:self.animationTimer_pan forMode:NSRunLoopCommonModes];
    }
}

- (void)doScrollWithXangle:(CGFloat)Xangle Yangle:(CGFloat)YAngle animationDuration:(CGFloat)duration{
    if(Xangle > M_PI*0.5){
        Xangle = M_PI * 0.5;
    }else if(Xangle < -M_PI*0.5){
        Xangle = - M_PI * 0.5;
    }
    NSArray *AfterAngles = [self transformX:0 Y:0 Z:self.cameraPositionZ
                                   inXAngle:Xangle
                                     YAngle:YAngle
                                     ZAngle:0];
    CGFloat newXAngle = ((NSNumber *)AfterAngles[0]).doubleValue;
    CGFloat newYAngle = ((NSNumber *)AfterAngles[1]).doubleValue;
    CGFloat newZAngle = ((NSNumber *)AfterAngles[2]).doubleValue;
    
    [self.cameraNode runAction:[SCNAction rotateToX:Xangle y:YAngle z:0 duration:duration]];
    [self.cameraNode runAction:[SCNAction moveTo:SCNVector3Make(newXAngle,
                                                                newYAngle,
                                                                newZAngle)
                                        duration:duration]];
}


- (NSArray *)transformX:(CGFloat)X Y:(CGFloat)Y Z:(CGFloat)Z
               inXAngle:(CGFloat)XAngle YAngle:(CGFloat)YAngle ZAngle:(CGFloat)ZAngle
{
    CGFloat afterX = X,afterY = Y,afterZ = Z;
    
    if(ZAngle != 0){
        CGFloat ZPointAngle = 0;
        if(afterY != 0){
            ZPointAngle = atan(afterX/afterY);
        }else{
            ZPointAngle = 0.5*M_PI*(afterX>0?1:-1);
        }
        CGFloat ZAfterAngle = ZPointAngle + ZAngle;
        CGFloat ZR = sqrt(afterX*afterX+afterY*afterY);
        afterX += (afterY<0?-1:1)*sin(ZAfterAngle)*ZR - afterX;
        afterY += (afterY<0?-1:1)*cos(ZAfterAngle)*ZR - afterY;
    }
    
    if(XAngle != 0){
        CGFloat XPointAngle = 0;
        if(afterY != 0){
            XPointAngle = atan(afterZ/afterY);
        }else{
            XPointAngle = 0.5*M_PI*(afterZ>0?1:-1);
        }
        CGFloat XAfterAngle = XPointAngle + XAngle;
        CGFloat XR = sqrt(afterY*afterY+afterZ*afterZ);
        afterZ += (afterY<0?-1:1)*sin(XAfterAngle)*XR - afterZ;
        afterY += (afterY<0?-1:1)*cos(XAfterAngle)*XR - afterY;
    }
    
    if(YAngle != 0){
        CGFloat YPointAngle = 0;
        if(afterZ != 0){
            YPointAngle = atan(afterX/afterZ);
        }else{
            YPointAngle = 0.5*M_PI*(afterX>0?1:-1);
        }
        CGFloat YAfterAngle = YPointAngle + YAngle;
        CGFloat YR = sqrt(afterX*afterX+afterZ*afterZ);
        afterX += (afterZ<0?-1:1)*sin(YAfterAngle)*YR - afterX;
        afterZ += (afterZ<0?-1:1)*cos(YAfterAngle)*YR - afterZ;
    }
    
    return @[[NSNumber numberWithDouble:afterX],
             [NSNumber numberWithDouble:afterY],
             [NSNumber numberWithDouble:afterZ]];
}



#pragma mark- 相册图片
-(void)setImage:(NSString *)image{
    _image = image;
    self.ballNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:_image];
    self.ballNode.geometry.firstMaterial.diffuse.mipFilter = SCNFillModeLines;
    self.ballNode.geometry.firstMaterial.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(-1, 1, 1), 1, 0, 0);
}

-(void)setIsFish:(BOOL)isFish{
    if (isFish) {
        self.nowCameraPositionZ = 90;
        self.nowCameraDis = 60;
    }else{
        self.nowCameraPositionZ = 0;
        self.nowCameraDis = 40;
    }
    self.cameraNode.camera.xFov = self.nowCameraDis;
    self.cameraNode.camera.yFov = self.nowCameraDis;
    self.cameraNode.position = SCNVector3Make(0, 0, self.nowCameraPositionZ);
    
    
    
}




















@end
