#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@interface AppDelegate () <FlutterStreamHandler>
/// 接收分享文件事件通道
@property (nonatomic, strong) FlutterEventChannel *receiveFileEventChannel;
@property (nonatomic, strong) FlutterEventSink receiveFileEventSink;

/// 分享文件处理结果未消费标志（Flutter 监听建立前先缓存，建立后补发）
@property (nonatomic, assign) bool fileShared;
@property (nonatomic, assign) int fileSharedCode;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];

    FlutterViewController *vc = (FlutterViewController *)self.window.rootViewController;
    self.receiveFileEventChannel = [FlutterEventChannel eventChannelWithName:@"app/receive_file_channel"
                                                              binaryMessenger:vc.binaryMessenger];
    [self.receiveFileEventChannel setStreamHandler:self];

    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

//MARK: 第三方App通过"打开方式"分享文件到APP回调
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    [super application:app openURL:url options:options];
    if ([url.absoluteString hasPrefix:@"file:///private"]) {
        // 系统先将分享文件复制到 Documents/Inbox，此处校验并复制到固件接收目录
        self.fileShared = true;
        NSRange range = [url.absoluteString rangeOfString:@"/" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            NSString *fileName = [url.absoluteString substringFromIndex:range.location + 1];
            fileName = [fileName stringByRemovingPercentEncoding];
            NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *filePath = [documentPath stringByAppendingPathComponent:@"upgrade_receive_files"];

            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:filePath]) {
                [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            }

            // 判断文件是否合法，.bin/.img 结尾合法
            BOOL legal = YES;
            if (![fileName hasSuffix:@".bin"] && ![fileName hasSuffix:@".img"]) {
                legal = NO;
            }

            // copy新的文件到接收目录
            NSString *inboxPath = [documentPath stringByAppendingPathComponent:@"Inbox"];
            if (legal) {
                // 文件已存在则先删除
                NSString *targetPath = [filePath stringByAppendingPathComponent:fileName];
                if ([fileManager fileExistsAtPath:targetPath]) {
                    [fileManager removeItemAtPath:targetPath error:nil];
                }
                NSError *error;
                [fileManager copyItemAtPath:[inboxPath stringByAppendingPathComponent:fileName]
                                     toPath:targetPath
                                      error:&error];
                if (error) {
                    NSLog(@"固件文件复制失败：%@", error);
                    [self notifyReceiveFileResult:-2];
                } else {
                    [self notifyReceiveFileResult:0];
                }
            } else {
                [self notifyReceiveFileResult:-4];
            }
        } else {
            [self notifyReceiveFileResult:-2];
        }
    }

    return YES;
}

/// 通知 Flutter 层分享文件处理结果，Flutter 监听未建立时缓存待补发
- (void)notifyReceiveFileResult:(int)code {
    self.fileShared = true;
    self.fileSharedCode = code;
    if (self.receiveFileEventSink) {
        self.fileShared = false;
        self.receiveFileEventSink(@(code));
    }
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events{
    self.receiveFileEventSink = events;
    // Flutter 监听建立后补发未消费的分享结果（冷启动分享场景）
    if (self.fileShared) {
        self.fileShared = false;
        self.receiveFileEventSink(@(self.fileSharedCode));
    }
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments{
    self.receiveFileEventSink = nil;
    return nil;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // 保证Inbox文件夹永远是空
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *inboxPath = [documentPath stringByAppendingPathComponent:@"Inbox"];
    [[NSFileManager defaultManager] removeItemAtPath:inboxPath error:nil];
}

@end
