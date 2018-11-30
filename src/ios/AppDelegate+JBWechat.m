//
//  AppDelegate+JBWechat.m
//  黄金象
//
//  Created by MAC005 on 2018/11/30.
//

#import "AppDelegate+JBWechat.h"
#import <objc/runtime.h>
#import "CDVWechat.h"

@implementation AppDelegate (JBWechat)
+ (void)load{
    //方法交换应该被保证，在程序中只会执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL systemSel = @selector(application:openURL:options:);
        //自己实现的将要被交换的方法的selector
        SEL swizzSel = @selector(swiz_application:openURL:options:);
        //两个方法的Method
        Method systemMethod = class_getInstanceMethod([self class], systemSel);
        Method swizzMethod = class_getInstanceMethod([self class], swizzSel);
        
        //首先动态添加方法，实现是被交换的方法，返回值表示添加成功还是失败
        BOOL isAdd = class_addMethod(self, systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
        if (isAdd) {
            //如果成功，说明类中不存在这个方法的实现
            //将被交换方法的实现替换到这个并不存在的实现
            class_replaceMethod(self, swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
        }else{
            //否则，交换两个方法的实现
            method_exchangeImplementations(systemMethod, swizzMethod);
        }
    });
}

-(BOOL)swiz_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    CDVWechat* wechat = [self.viewController getCommandInstance:@"Wechat"];
    
    if ([url.scheme isEqualToString:wechat.wechatAppId]) {
        return [WXApi handleOpenURL:url delegate:wechat];
    }
    
    [self swiz_application:app openURL:url options:options];

    return YES;
}
@end
