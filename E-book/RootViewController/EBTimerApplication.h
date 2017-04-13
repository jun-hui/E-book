//
//  EBTimerApplication.h
//  E-book
//
//  Created by 小王 on 2017/4/12.
//  Copyright © 2017年 小王. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EBTimerApplication : UIApplication


//定义应用程序超时时间
@property (nonatomic, assign) CGFloat EBTimeoutInMinutes;
//定义通知名称
@property (nonatomic, copy) NSString *NotificationName;

+(instancetype)shareTimer;
-(void)resetIdleTimer;
-(void)stopTimer;

@end
