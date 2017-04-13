//
//  ReadBookViewController.m
//  E-book
//
//  Created by 小王 on 2017/4/5.
//  Copyright © 2017年 小王. All rights reserved.
//

#import "ReadBookViewController.h"
#import "EBTimerApplication.h"
#import "BookmarkViewController.h"

@interface ReadBookViewController ()<WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    int currentPage;
    int allPage;
}

@property (nonatomic, strong) WKWebViewConfiguration *webConfig;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *stateView;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UISwipeGestureRecognizer* leftSwipeGesture;
@property (nonatomic, strong) UISwipeGestureRecognizer* rightSwipeGesture;

@end

static NSString *const EBLongTimeNoOperationNotification = @"LongTimeNoOperationNotice";
static NSString *const CONTENTSIZEOBSERVER = @"contentSize";

static BOOL naviHidden;
static BOOL nightColor;

@implementation ReadBookViewController

/*
-(BOOL)prefersStatusBarHidden
{
    if (naviHidden) {
        return YES;
    }
    return NO;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}
 */

-(WKWebViewConfiguration *)webConfig
{
    if (!_webConfig) {
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc]init];
        // 设置字体大小(最小的字体大小)
        preference.minimumFontSize = 14;
        // 设置偏好设置对象
        config.preferences = preference;
        
        _webConfig = config;
    }
    return _webConfig;
}

-(WKWebView *)webView
{
    if (!_webView) {
        
        _stateView = [[UIView alloc] initWithFrame:(CGRect){0, 0, ScreenWidth, 20}];
        [_stateView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:_stateView];
        
        _webView = [[WKWebView alloc] initWithFrame:(CGRect){0, 20, ScreenWidth, ScreenHeight - 20} configuration:self.webConfig];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.scrollView.delegate = self;
        _webView.scrollView.pagingEnabled = YES;
    }
    return _webView;
}

-(UIToolbar *)toolBar
{
    if (!_toolBar) {
        UIColor *barTintColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        
        UINavigationBar *naviBar = self.navigationController.navigationBar;
        [naviBar setBackgroundImage:[self createImageWithColor:barTintColor] forBarMetrics:UIBarMetricsDefault];
        
        UIToolbar *toolBar = self.navigationController.toolbar;
        [toolBar setBackgroundImage:[self createImageWithColor:barTintColor] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
        toolBar.tintColor = [UIColor whiteColor];
        
        //为toolbar增加按钮
        UIBarButtonItem *lastPage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"上一页"] style:UIBarButtonItemStylePlain target:self action:@selector(lastPage)];
        UIBarButtonItem *modeSwitch = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"夜间模式"] style:UIBarButtonItemStylePlain target:self action:@selector(modeSwitch:)];
        UIBarButtonItem *nextPage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"下一页"] style:UIBarButtonItemStylePlain target:self action:@selector(nextPage)];
        UIBarButtonItem *bookmark = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"目录"] style:UIBarButtonItemStylePlain target:self action:@selector(bookmark)];
        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [self setToolbarItems: @[flexItem,lastPage,flexItem,modeSwitch,flexItem,nextPage,flexItem,bookmark,flexItem]];
        
        _toolBar = toolBar;
    }
    return _toolBar;
}

-(UISwipeGestureRecognizer *)leftSwipeGesture
{
    if (!_leftSwipeGesture) {
        
        _leftSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(flipAnimation:)];
        _leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    return _leftSwipeGesture;
}

-(UISwipeGestureRecognizer *)rightSwipeGesture
{
    if (!_rightSwipeGesture) {
        
        _rightSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(flipAnimation:)];
        _rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return _rightSwipeGesture;
}

-(void)loadBookData
{
    // 创建URL对象：指定要加载资源的路径
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:_bookName withExtension:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    
    [self.webView loadRequest:request];
    
    [self.webView sizeToFit];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:naviHidden animated:animated];
    [self.navigationController setToolbarHidden:naviHidden animated:animated];
    
    [self.webView.scrollView addObserver:self forKeyPath:CONTENTSIZEOBSERVER options:NSKeyValueObservingOptionNew context:nil];
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSNotificationCenter *noticenter = [NSNotificationCenter defaultCenter];
    [noticenter addObserver:self
                   selector:@selector(timeOutNotification:)
                       name:EBLongTimeNoOperationNotification
                     object:nil];
    
    [EBTimerApplication shareTimer].EBTimeoutInMinutes = 5;
    [EBTimerApplication shareTimer].NotificationName = EBLongTimeNoOperationNotification;
    [[EBTimerApplication shareTimer] resetIdleTimer];
    
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    //移除监听
    [_webView.scrollView removeObserver:self forKeyPath:CONTENTSIZEOBSERVER];
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    if (_webView) {
        _webView.UIDelegate = nil;
        _webView.navigationDelegate = nil;
        
    }
    
    [[EBTimerApplication shareTimer] stopTimer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.webView];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%d/%d",currentPage,allPage];
    
    [self.toolBar sizeToFit];
    
    [self loadBookData];
    
    [self addGestureRecognizer];
}

-(void)timeOutNotification:(NSNotification *)notifi
{
    if (!naviHidden) {
        naviHidden = YES;
        [self.navigationController setNavigationBarHidden:naviHidden animated:true];
        [self.navigationController setToolbarHidden:naviHidden animated:true];
    }
}

-(void)addGestureRecognizer
{
    //手势
    //单击手势
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
    
    //左轻扫手势
    [self.view addGestureRecognizer:self.leftSwipeGesture];
    
    //右轻扫手势
    [self.view addGestureRecognizer:self.rightSwipeGesture];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)tapGestureAction:(UITapGestureRecognizer*)tapGesture
{
    naviHidden = !naviHidden;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    
    [UIView commitAnimations];
    
    [self.navigationController setNavigationBarHidden:naviHidden animated:true];
    [self.navigationController setToolbarHidden:naviHidden animated:true];
}

-(void)flipAnimation:(UISwipeGestureRecognizer *)swipeGesture
{
    NSInteger direction = swipeGesture.direction;
    
    if (direction == UISwipeGestureRecognizerDirectionLeft) {
        
        if (currentPage == allPage) {
            
            [DKProgressHUD showInfoWithStatus:@"已是最后一页，没有更多了···" toView:self.view];
            return;
        } else {
            
            currentPage = currentPage + 1;
        }
        
    } else if (direction == UISwipeGestureRecognizerDirectionRight){
        
        if (currentPage == 1) {
            
            [DKProgressHUD showInfoWithStatus:@"别翻了，当前就是第一页！" toView:self.view];
            return;
        } else {
            
            currentPage = currentPage - 1;
        }
    }
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    
    if (direction == UISwipeGestureRecognizerDirectionLeft) {
        
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.webView cache:NO];
        
    } else if (direction == UISwipeGestureRecognizerDirectionRight) {
        
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.webView cache:NO];
    }
    [self scrollToPoint];
    //动画完成
    [UIView commitAnimations];
    //更新title
    self.navigationItem.title = [NSString stringWithFormat:@"%d/%d",currentPage,allPage];
}

-(void)scrollToPoint
{
    //后台异步
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        float toTop = (currentPage-1) *(ScreenHeight - 20);
        //主线程异步刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            self.webView.scrollView.contentOffset = CGPointMake(0, toTop);
        });
    });
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        CGFloat ViewHeight = self.view.frame.size.height;
        
        //获取页面高度，并重置webview的frame
        //获取页面高度
        double webViewHeight = [result doubleValue];
        allPage = webViewHeight/ViewHeight;
        
        currentPage = 1;
        self.navigationItem.title = [NSString stringWithFormat:@"%d/%d",currentPage,allPage];
    }];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY >= 0) {
        int page = offsetY/(ScreenHeight - 20);
        self.navigationItem.title = [NSString stringWithFormat:@"%d/%d",page+1,allPage];
        currentPage = page+1;
    }
}


-(void)lastPage
{
    [self flipAnimation:self.rightSwipeGesture];
}
// 切换昼夜模式
-(void)modeSwitch:(UIBarButtonItem *)modeSwitch
{
    nightColor = !nightColor;
    
    NSString *textColor;
    NSString *backgroColor;
    NSString *JavaScript = @"document.getElementsByTagName('body')[0].style";
    
    if (nightColor) {
        
        textColor = [NSString stringWithFormat:@"%@.webkitTextFillColor= '%@'",JavaScript,@"lightgray"];
        backgroColor = [NSString stringWithFormat:@"%@.background='%@'",JavaScript,@"#2E2E2E"];
        
        [modeSwitch setImage:[UIImage imageNamed:@"日间模式"]];
    } else {
        textColor = [NSString stringWithFormat:@"%@.webkitTextFillColor= '%@'",JavaScript,@"black"];
        backgroColor = [NSString stringWithFormat:@"%@.background='%@'",JavaScript,@"white"];
        
        [modeSwitch setImage:[UIImage imageNamed:@"夜间模式"]];
    }
    
    //字体颜色
    [_webView evaluateJavaScript:textColor completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    //页面背景色
    [_webView evaluateJavaScript:backgroColor completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        [UIView animateWithDuration:0.05f animations:^{
            
            _stateView.backgroundColor = nightColor ? UIColorFromRGB(0x2E2E2E, 1.0) : [UIColor whiteColor];
        }];
    }];
}

-(void)nextPage
{
    [self flipAnimation:self.leftSwipeGesture];
}
-(void)bookmark
{
    BookmarkViewController *markVC = [[BookmarkViewController alloc] init];
    [self.navigationController pushViewController:markVC animated:YES];
}

- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:CONTENTSIZEOBSERVER]) {
        
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            
            NSString *javaScript = @"document.documentElement.offsetHeight";
            
            [_webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                
            }];
        });
    }
}


@end
