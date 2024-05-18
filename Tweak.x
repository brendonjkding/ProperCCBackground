#import <objc/runtime.h>

@interface MTMaterialView:UIView
+(id)materialViewWithRecipe:(NSInteger)arg1 configuration:(NSInteger)arg2 initialWeighting:(CGFloat)arg3;
+(id)materialViewWithRecipe:(NSInteger)arg1 options:(NSInteger)arg2 initialWeighting:(CGFloat)arg3;
+(id)materialViewWithStyleOptions:(NSInteger)arg1 materialSettings:(id)arg2 captureOnly:(BOOL)arg3;
@end

@interface CCUIModularControlCenterOverlayViewController : UIViewController
@property (nonatomic,readonly) MTMaterialView * overlayBackgroundView; 
@property (nonatomic,readonly) UIScrollView * overlayScrollView; 
@property (nonatomic,readonly) UIView * overlayContainerView; 
@property (nonatomic,readonly) id overlayHeaderView; 
@property (strong) UIView *pccb_touchBlockView;
@end

@interface CCUIOverlayStatusBarPresentationProvider : NSObject
-(id)viewProvider;
@end

@interface CCUIContentModuleContainerViewController:UIViewController
@property (strong) MTMaterialView*pccb_materialView;
@end

%group hook

%hook CCUIModularControlCenterOverlayViewController
%property (strong) UIView *pccb_touchBlockView;
-(void)viewDidLoad{
    %orig;
    double maxWidth=MAX(self.view.frame.size.width,self.view.frame.size.height);
    UILabel *_touchBlockView = [[UILabel alloc] initWithFrame:CGRectMake(-10,0,maxWidth+10,maxWidth)];
    [self.view addSubview:_touchBlockView];
    _touchBlockView.text=@"1";
    self.pccb_touchBlockView = _touchBlockView;
}
- (void)presentAnimated:(_Bool)arg1 withCompletionHandler:(id)arg2{
    self.pccb_touchBlockView.hidden = NO;
    %orig;
}
- (void)dismissAnimated:(_Bool)arg1 withCompletionHandler:(id)arg2{
    self.pccb_touchBlockView.hidden = YES;
    %orig;
}
%end//CCUIModularControlCenterOverlayViewController
%hook CCUIOverlayStatusBarPresentationProvider
-(void)layoutViews{
    %orig;
    CCUIModularControlCenterOverlayViewController*vc=[self viewProvider];
    MTMaterialView* bgView=[vc overlayBackgroundView];
    UIView*containerView=[vc overlayContainerView];
    UIView*headerView=[vc overlayHeaderView];
    CGRect frame=[bgView frame];
    frame.origin.x=containerView.frame.origin.x;
    frame.size.height=containerView.frame.size.height+headerView.frame.size.height;
    frame.size.width-=containerView.frame.origin.x;
    [bgView setFrame:frame];
    bgView.layer.cornerRadius=25.;
    bgView.layer.masksToBounds=YES;
}
%end//CCUIOverlayStatusBarPresentationProvider
%hook CCUIContentModuleContainerViewController
%property (strong) MTMaterialView*pccb_materialView;
-(void)viewWillAppear:(BOOL)animated{
    %orig;
    NSLog(@"viewWillAppear");
    if(self.presentingViewController){
        NSLog(@"presentingViewController");
        if(!self.pccb_materialView){
            if(@available(iOS 13.0,*)){
                self.pccb_materialView=[objc_getClass("MTMaterialView") materialViewWithRecipe:8 configuration:1 initialWeighting:1];
            }
            else{
                self.pccb_materialView=[objc_getClass("MTMaterialView") materialViewWithRecipe:8 options:3 initialWeighting:1];
            }
            CGRect bounds=[[UIScreen mainScreen] bounds];
            double maxWidth=MAX(bounds.size.width,bounds.size.height);
            [self.pccb_materialView setFrame:CGRectMake(0, 0, maxWidth, maxWidth)];
        };
        [self.view.subviews[0] insertSubview:self.pccb_materialView atIndex:0];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    %orig;
    if(self.presentingViewController){
        [self.pccb_materialView removeFromSuperview];
    }
}
%end//CCUIContentModuleContainerViewController
%end//hook

%ctor{
	NSLog(@"ctor: ProperCCBackgroundiPad");
    if([[[UIDevice currentDevice] model] isEqualToString:@"iPad"]){
        %init(hook);
    }
}
