#import <UIKit/UIKit.h>

// 1. Hook màn hình đăng nhập / nhập key để tự động bypass
%hook LoginViewController // Thay thế tên Class màn hình nhập key nếu game của bạn có tên khác

- (void)submitButtonTapped:(id)sender {
    NSLog(@"[DEBUG] Đã can thiệp nút xác nhận key, tiến hành mở khóa trực tiếp.");
    
    // Gọi trực tiếp phương thức mở menu mod (Menucuatoi)
    if ([self respondsToSelector:@selector(Menucuatoi)]) {
        [self performSelector:@selector(Menucuatoi)];
    }
    
    // Ẩn giao diện nhập key đi để vào game
    if ([self respondsToSelector:@selector(view)]) {
        [[self view] setHidden:YES];
    }
}

%end

// 2. Hook tầng mạng để giả lập dữ liệu VIP / Key thành công từ Server
%hook NetworkManager

- (void)Post_AppendURL:(NSString *)url myparameters:(NSDictionary *)params mysuccess:(void(^)(id responseObject))success myfailure:(void(^)(NSError *error))failure {
    // Lọc các đường dẫn request liên quan đến kiểm tra VIP hoặc thông tin tài khoản
    if ([url containsString:@"vip"] || [url containsString:@"user/info"] || [url containsString:@"license"] || [url containsString:@"checkkey"]) {
        NSLog(@"[DEBUG] Đã chặn endpoint mạng: %@, trả về dữ liệu VIP giả lập.", url);
        
        // Tạo gói dữ liệu JSON giả lập báo kích hoạt thành công vĩnh viễn
        NSDictionary *fakeResponse = @{
            @"status": @200,
            @"code": @0,
            @"message": @"success",
            @"data": @{
                @"is_vip": @1,
                @"vip_level": @99,
                @"active": @true,
                @"expire_time": @"2099-01-01 00:00:00"
            }
        };
        
        if (success) {
            success(fakeResponse);
        }
        return;
    }
    
    // Các request mạng khác giữ nguyên luồng chạy bình thường
    %orig(url, params, success, failure);
}

%end

// 3. Hook hệ thống để ẩn hoặc trả về UDID giả lập
%hook UIDevice

- (NSUUID *)identifierForVendor {
    NSLog(@"[DEBUG] Chặn yêu cầu lấy UDID phần cứng, trả về UDID giả lập.");
    return [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"];
}

%end

%hook NSUserDefaults

- (id)objectForKey:(NSString *)defaultName {
    if ([defaultName containsString:@"udid"] || [defaultName containsString:@"device_id"] || [defaultName containsString:@"uuid"]) {
        return @"FakeUDID_Bypass_000000";
    }
    return %orig(defaultName);
}

%end
