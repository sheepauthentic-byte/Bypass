// Language: Objective-C | File: Tweak.mm | Runtime: MobileSubstrate | Target: aovnet_MAPV1 (iOS ARM64)
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <substrate.h>

static void (*orig_submitButtonTapped)(id, SEL);
static void (*orig_Post_AppendURL)(id, SEL, id, id, id, id);

static void hk_submitButtonTapped(id self, SEL _cmd) {
    if (orig_submitButtonTapped) {
        orig_submitButtonTapped(self, _cmd);
    }

    SEL menuSel = NSSelectorFromString(@"Menucuatoi");
    if ([self respondsToSelector:menuSel]) {
        NSMethodSignature *sig = [self methodSignatureForSelector:menuSel];
        if (sig && sig.numberOfArguments == 2 && sig.methodReturnLength == 0) {
            ((void (*)(id, SEL))[self methodForSelector:menuSel])(self, menuSel);
        }
    }
}

static void hk_Post_AppendURL(id self, SEL _cmd, id url, id params, id success, id failure) {
    NSString *u = [url isKindOfClass:[NSString class]] ? url : [url description];
    BOOL isVipCheck = [u containsString:@"vip"] || [u containsString:@"user/info"] || [u containsString:@"check"];

    if (isVipCheck && success) {
        NSDictionary *fake = @{
            @"status": @200, 
            @"code": @0, 
            @"message": @"success",
            @"data": @{
                @"isVip": @1,
                @"expiredTime": @4102444800LL,
                @"keyStatus": @"active"
            }
        };
        ((void (^)(id))success)(fake);
        return;
    }
    
    if (orig_Post_AppendURL) {
        orig_Post_AppendURL(self, _cmd, url, params, success, failure);
    }
}

%ctor {
    Class loginVC = objc_getClass("LoginViewController");
    if (loginVC) {
        MSHookMessageEx(loginVC, @selector(submitButtonTapped),
                        (IMP)hk_submitButtonTapped, (IMP *)&orig_submitButtonTapped);
    }
    
    Class netMgr = objc_getClass("NetworkManager");
    if (netMgr) {
        MSHookMessageEx(netMgr, @selector(Post_AppendURL:myparameters:mysuccess:myfailure:),
                        (IMP)hk_Post_AppendURL, (IMP *)&orig_Post_AppendURL);
    }
}
