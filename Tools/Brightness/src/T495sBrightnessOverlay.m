#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/graphics/IOGraphicsLib.h>

#include <math.h>
#include <string.h>

static BOOL ReadNativeBrightness(float *value) {
    io_iterator_t iterator = IO_OBJECT_NULL;
    CFMutableDictionaryRef matching = IOServiceMatching("IODisplayConnect");
    if (matching == NULL) {
        return NO;
    }

    if (IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) != KERN_SUCCESS) {
        return NO;
    }

    BOOL found = NO;
    io_service_t service = IO_OBJECT_NULL;
    while ((service = IOIteratorNext(iterator)) != IO_OBJECT_NULL) {
        float current = 0.0f;
        if (IODisplayGetFloatParameter(service, kNilOptions, CFSTR("brightness"), &current) == kIOReturnSuccess) {
            *value = current;
            found = YES;
            IOObjectRelease(service);
            break;
        }
        IOObjectRelease(service);
    }

    IOObjectRelease(iterator);
    return found;
}

static CGFloat Clamp(CGFloat value, CGFloat minimum, CGFloat maximum) {
    return fmin(maximum, fmax(minimum, value));
}

@interface T495sBrightnessController : NSObject <NSApplicationDelegate>
@property(nonatomic, strong) NSWindow *overlay;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic) CGFloat threshold;
@property(nonatomic) CGFloat maximumAlpha;
@property(nonatomic) CGFloat curve;
@property(nonatomic) NSTimeInterval interval;
@property(nonatomic) CGFloat lastAlpha;
@end

@implementation T495sBrightnessController

- (instancetype)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _threshold = 0.90;
    _maximumAlpha = 0.90;
    _curve = 1.35;
    _interval = 0.25;
    _lastAlpha = -1.0;

    NSArray<NSString *> *arguments = NSProcessInfo.processInfo.arguments;
    for (NSUInteger index = 1; index < arguments.count; index++) {
        NSString *argument = arguments[index];
        if ([argument isEqualToString:@"--threshold"] && index + 1 < arguments.count) {
            _threshold = arguments[++index].doubleValue;
        } else if ([argument isEqualToString:@"--max-alpha"] && index + 1 < arguments.count) {
            _maximumAlpha = arguments[++index].doubleValue;
        } else if ([argument isEqualToString:@"--curve"] && index + 1 < arguments.count) {
            _curve = arguments[++index].doubleValue;
        } else if ([argument isEqualToString:@"--interval-ms"] && index + 1 < arguments.count) {
            _interval = arguments[++index].doubleValue / 1000.0;
        }
    }

    _threshold = Clamp(_threshold, 0.50, 1.00);
    _maximumAlpha = Clamp(_maximumAlpha, 0.00, 0.94);
    _curve = Clamp(_curve, 0.50, 3.00);
    _interval = Clamp(_interval, 0.10, 2.00);
    return self;
}

- (NSScreen *)internalScreen {
    for (NSScreen *screen in NSScreen.screens) {
        NSNumber *screenNumber = screen.deviceDescription[@"NSScreenNumber"];
        if (screenNumber != nil && CGDisplayIsBuiltin(screenNumber.unsignedIntValue)) {
            return screen;
        }
    }
    return NSScreen.mainScreen ?: NSScreen.screens.firstObject;
}

- (void)rebuildOverlay {
    [self.overlay orderOut:nil];
    [self.overlay close];
    self.overlay = nil;

    NSScreen *screen = [self internalScreen];
    if (screen == nil) {
        return;
    }

    NSWindow *window = [[NSWindow alloc]
        initWithContentRect:screen.frame
        styleMask:NSWindowStyleMaskBorderless
        backing:NSBackingStoreBuffered
        defer:NO
        screen:screen];

    window.opaque = NO;
    window.backgroundColor = NSColor.blackColor;
    window.hasShadow = NO;
    window.ignoresMouseEvents = YES;
    window.hidesOnDeactivate = NO;
    window.canHide = NO;
    window.releasedWhenClosed = NO;
    window.animationBehavior = NSWindowAnimationBehaviorNone;
    window.level = NSScreenSaverWindowLevel - 1;
    window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces |
                                NSWindowCollectionBehaviorStationary |
                                NSWindowCollectionBehaviorFullScreenAuxiliary |
                                NSWindowCollectionBehaviorIgnoresCycle;
    window.sharingType = NSWindowSharingNone;
    window.alphaValue = 0.0;

    self.overlay = window;
    self.lastAlpha = -1.0;
    [self updateBrightness];
}

- (CGFloat)overlayAlphaForBrightness:(CGFloat)brightness {
    brightness = Clamp(brightness, 0.0, 1.0);
    if (brightness >= self.threshold) {
        return 0.0;
    }

    CGFloat progress = 1.0 - brightness / self.threshold;
    return self.maximumAlpha * pow(progress, self.curve);
}

- (void)setOverlayAlpha:(CGFloat)alpha {
    if (self.overlay == nil || fabs(alpha - self.lastAlpha) < 0.002) {
        return;
    }

    self.lastAlpha = alpha;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.0;
        self.overlay.animator.alphaValue = alpha;
    } completionHandler:nil];

    if (alpha < 0.002) {
        [self.overlay orderOut:nil];
    } else {
        [self.overlay orderFrontRegardless];
    }
}

- (void)updateBrightness {
    float brightness = 1.0f;
    if (!ReadNativeBrightness(&brightness)) {
        return;
    }
    [self setOverlayAlpha:[self overlayAlphaForBrightness:brightness]];
}

- (void)screenConfigurationChanged:(NSNotification *)notification {
    (void)notification;
    [self rebuildOverlay];
}

- (void)sessionBecameActive:(NSNotification *)notification {
    (void)notification;
    CGDisplayRestoreColorSyncSettings();
    [self rebuildOverlay];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    (void)notification;
    CGDisplayRestoreColorSyncSettings();
    [self rebuildOverlay];

    NSNotificationCenter *applicationCenter = NSNotificationCenter.defaultCenter;
    [applicationCenter addObserver:self
                          selector:@selector(screenConfigurationChanged:)
                              name:NSApplicationDidChangeScreenParametersNotification
                            object:nil];

    NSNotificationCenter *workspaceCenter = NSWorkspace.sharedWorkspace.notificationCenter;
    [workspaceCenter addObserver:self
                        selector:@selector(sessionBecameActive:)
                            name:NSWorkspaceDidWakeNotification
                          object:nil];
    [workspaceCenter addObserver:self
                        selector:@selector(sessionBecameActive:)
                            name:NSWorkspaceSessionDidBecomeActiveNotification
                          object:nil];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval
                                                  target:self
                                                selector:@selector(updateBrightness)
                                                userInfo:nil
                                                 repeats:YES];
    self.timer.tolerance = self.interval * 0.25;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    (void)notification;
    [self.timer invalidate];
    [self.overlay orderOut:nil];
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        for (int index = 1; index < argc; index++) {
            if (strcmp(argv[index], "--restore-only") == 0) {
                CGDisplayRestoreColorSyncSettings();
                return 0;
            }
        }

        NSApplication *application = NSApplication.sharedApplication;
        application.activationPolicy = NSApplicationActivationPolicyAccessory;
        T495sBrightnessController *controller = [[T495sBrightnessController alloc] init];
        application.delegate = controller;
        [application run];
    }
    return 0;
}
