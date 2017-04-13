//
//  EBTimerApplication.m
//  E-book
//
//  Created by 小王 on 2017/4/12.
//  Copyright © 2017年 小王. All rights reserved.
//

#import "EBTimerApplication.h"

@implementation EBTimerApplication

static EBTimerApplication *EBTimer = nil;
static NSTimer *myidleTimer;

-(void)setEBTimeoutInMinutes:(CGFloat)EBTimeoutInMinutes
{
    _EBTimeoutInMinutes = EBTimeoutInMinutes;
}

+(instancetype)shareTimer
{
    if (!EBTimer) {
        EBTimer = (EBTimerApplication *)[EBTimerApplication sharedApplication];
    }
    return EBTimer;
}

// 监听所有触摸，当屏幕被触摸，时钟将被重置

-(void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];
    
    if (!myidleTimer) {
        
        [self resetIdleTimer];
    }
    
    NSSet *allTouches = [event allTouches];
    
    if ([allTouches count] > 0) {
        
        UITouchPhase phase= ((UITouch *)[allTouches anyObject]).phase;
        
        if (phase == UITouchPhaseBegan) {
            
            [self resetIdleTimer];
        }
    }
}

//重置时钟

-(void)resetIdleTimer {
    
    [self stopTimer];
    
    //设置超时时间
    if (_EBTimeoutInMinutes == 0) {
        _EBTimeoutInMinutes = CGFLOAT_MAX;
    }
    
    myidleTimer = [NSTimer scheduledTimerWithTimeInterval:_EBTimeoutInMinutes target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:NO];
}

//当达到超时时间，发送通知

-(void)idleTimerExceeded {
    
    [[NSNotificationCenter defaultCenter] postNotificationName: _NotificationName object:nil];
    
}

-(void)stopTimer
{
    if (myidleTimer) {
        
        [myidleTimer invalidate];
    }
}


@end
