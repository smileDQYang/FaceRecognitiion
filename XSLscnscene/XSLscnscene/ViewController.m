//
//  ViewController.m
//  XSLscnscene
//
//  Created by admin on 2/11/17.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"
#import "XSLScnceneView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *myswitch;
/** xslView */
@property (nonatomic,strong) XSLScnceneView *scnceneView;

/** 位置*/
@property (nonatomic,assign) NSInteger indext;

/**  图片数组*/
@property (nonatomic,strong) NSArray *imageArry;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.indext = 0;
    self.scnceneView = [[XSLScnceneView alloc]initWithFrame:CGRectMake(5,
                                                                       5,
                                                                       [UIScreen mainScreen].bounds.size.width - 10,
                                                                       [UIScreen mainScreen].bounds.size.height - 90)];
    
    self.scnceneView.image = @"WechatIMG67.jpeg";
    [self.view addSubview:self.scnceneView];
    self.imageArry = @[@"WechatIMG67.jpeg",
                       @"WechatIMG70.jpeg",
                       @"WechatIMG71.jpeg",
                       @"WechatIMG72.jpeg",
                       @"WechatIMG73.jpeg"];
    
    
}

#pragma mark- 换图
- (IBAction)changeImgae:(id)sender {
    self.indext = self.indext + 1;
    if (self.indext > 4) {
        self.indext = 0;
    }
    self.scnceneView.image = self.imageArry[self.indext];
}

#pragma mark- 是否切换鱼眼效果
- (IBAction)changeSwitch:(id)sender {
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
