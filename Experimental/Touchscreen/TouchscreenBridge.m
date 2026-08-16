#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import <IOKit/hid/IOHIDManager.h>
#import <IOKit/hid/IOHIDUsageTables.h>
#include <math.h>

static const int kTargetVendor = 0x1A86;
static const int kTargetProduct = 0xE5E3;

typedef struct {
    IOHIDManagerRef manager;
    IOHIDDeviceRef device;
    double x;
    double y;
    CFIndex xMin, xMax, yMin, yMax;
    BOOL haveX, haveY;
    BOOL tip;
    BOOL mouseDown;
    BOOL probeOnly;
    BOOL invertX;
    BOOL invertY;
    BOOL swapXY;
    CGRect displayBounds;
} TouchState;

static TouchState gState = {0};

static NSString *supportDir(void) {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/T495sTouchscreen"];
}

static NSDictionary *loadSettings(void) {
    NSString *path = [supportDir() stringByAppendingPathComponent:@"settings.plist"];
    NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:path];
    return d ?: @{};
}

static CGRect builtInDisplayBounds(void) {
    CGDirectDisplayID ids[32];
    uint32_t count = 0;
    if (CGGetActiveDisplayList(32, ids, &count) == kCGErrorSuccess) {
        for (uint32_t i = 0; i < count; i++) {
            if (CGDisplayIsBuiltin(ids[i])) return CGDisplayBounds(ids[i]);
        }
    }
    return CGDisplayBounds(CGMainDisplayID());
}

static void postMouse(CGEventType type, CGPoint p) {
    CGMouseButton button = kCGMouseButtonLeft;
    CGEventRef e = CGEventCreateMouseEvent(NULL, type, p, button);
    if (e) {
        CGEventPost(kCGHIDEventTap, e);
        CFRelease(e);
    }
}

static CGPoint mappedPoint(void) {
    double nx = 0.0, ny = 0.0;
    if (gState.xMax > gState.xMin) nx = (gState.x - gState.xMin) / (double)(gState.xMax - gState.xMin);
    if (gState.yMax > gState.yMin) ny = (gState.y - gState.yMin) / (double)(gState.yMax - gState.yMin);
    nx = fmin(1.0, fmax(0.0, nx));
    ny = fmin(1.0, fmax(0.0, ny));
    if (gState.swapXY) { double t = nx; nx = ny; ny = t; }
    if (gState.invertX) nx = 1.0 - nx;
    if (gState.invertY) ny = 1.0 - ny;
    return CGPointMake(gState.displayBounds.origin.x + nx * gState.displayBounds.size.width,
                       gState.displayBounds.origin.y + ny * gState.displayBounds.size.height);
}

static void emitTouch(void) {
    if (gState.probeOnly || !gState.haveX || !gState.haveY) return;
    CGPoint p = mappedPoint();
    if (gState.tip) {
        if (!gState.mouseDown) {
            postMouse(kCGEventMouseMoved, p);
            postMouse(kCGEventLeftMouseDown, p);
            gState.mouseDown = YES;
        } else {
            postMouse(kCGEventLeftMouseDragged, p);
        }
    } else if (gState.mouseDown) {
        postMouse(kCGEventLeftMouseUp, p);
        gState.mouseDown = NO;
    }
}

static void dumpElements(IOHIDDeviceRef device) {
    CFArrayRef elements = IOHIDDeviceCopyMatchingElements(device, NULL, kIOHIDOptionsTypeNone);
    if (!elements) return;
    NSLog(@"Touchscreen HID elements: %ld", (long)CFArrayGetCount(elements));
    for (CFIndex i = 0; i < CFArrayGetCount(elements); i++) {
        IOHIDElementRef el = (IOHIDElementRef)CFArrayGetValueAtIndex(elements, i);
        uint32_t page = IOHIDElementGetUsagePage(el);
        uint32_t usage = IOHIDElementGetUsage(el);
        CFIndex min = IOHIDElementGetLogicalMin(el);
        CFIndex max = IOHIDElementGetLogicalMax(el);
        IOHIDElementType type = IOHIDElementGetType(el);
        NSLog(@"element type=%d page=0x%X usage=0x%X logical=[%ld,%ld] reportID=%u",
              (int)type, page, usage, (long)min, (long)max, IOHIDElementGetReportID(el));
    }
    CFRelease(elements);
}

static void deviceMatched(void *context, IOReturn result, void *sender, IOHIDDeviceRef device) {
    (void)context; (void)result; (void)sender;
    if (gState.device) CFRelease(gState.device);
    gState.device = device;
    CFRetain(device);
    NSString *product = (__bridge NSString *)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductKey));
    NSNumber *vendor = (__bridge NSNumber *)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDVendorIDKey));
    NSNumber *pid = (__bridge NSNumber *)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductIDKey));
    NSLog(@"Matched touchscreen: %@ VID=%@ PID=%@", product, vendor, pid);
    dumpElements(device);
}

static void deviceRemoved(void *context, IOReturn result, void *sender, IOHIDDeviceRef device) {
    (void)context; (void)result; (void)sender; (void)device;
    NSLog(@"Touchscreen removed");
    if (gState.mouseDown) {
        CGEventRef current = CGEventCreate(NULL);
        CGPoint p = current ? CGEventGetLocation(current) : CGPointZero;
        if (current) CFRelease(current);
        postMouse(kCGEventLeftMouseUp, p);
        gState.mouseDown = NO;
    }
    if (gState.device) { CFRelease(gState.device); gState.device = NULL; }
}

static void inputValue(void *context, IOReturn result, void *sender, IOHIDValueRef value) {
    (void)context; (void)result; (void)sender;
    IOHIDElementRef el = IOHIDValueGetElement(value);
    uint32_t page = IOHIDElementGetUsagePage(el);
    uint32_t usage = IOHIDElementGetUsage(el);
    CFIndex v = IOHIDValueGetIntegerValue(value);

    if (page == kHIDPage_GenericDesktop && usage == kHIDUsage_GD_X) {
        gState.x = (double)v;
        gState.xMin = IOHIDElementGetLogicalMin(el);
        gState.xMax = IOHIDElementGetLogicalMax(el);
        gState.haveX = YES;
        emitTouch();
    } else if (page == kHIDPage_GenericDesktop && usage == kHIDUsage_GD_Y) {
        gState.y = (double)v;
        gState.yMin = IOHIDElementGetLogicalMin(el);
        gState.yMax = IOHIDElementGetLogicalMax(el);
        gState.haveY = YES;
        emitTouch();
    } else if ((page == kHIDPage_Digitizer && (usage == kHIDUsage_Dig_TipSwitch || usage == 0x33)) ||
               (page == kHIDPage_Button && usage == 1)) {
        gState.tip = (v != 0);
        emitTouch();
    }

    if (gState.probeOnly) {
        NSLog(@"value page=0x%X usage=0x%X value=%ld", page, usage, (long)v);
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray<NSString *> *args = [[NSProcessInfo processInfo] arguments];
        gState.probeOnly = [args containsObject:@"--probe-only"];
        NSDictionary *s = loadSettings();
        gState.invertX = [s[@"InvertX"] boolValue];
        gState.invertY = [s[@"InvertY"] boolValue];
        gState.swapXY = [s[@"SwapXY"] boolValue];
        gState.displayBounds = builtInDisplayBounds();

        if (!gState.probeOnly) {
            NSDictionary *opts = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt: @YES};
            if (!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts)) {
                NSLog(@"Accessibility permission is required for TouchscreenBridge.");
            }
        }

        gState.manager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
        NSDictionary *match = @{
            @kIOHIDVendorIDKey: @(kTargetVendor),
            @kIOHIDProductIDKey: @(kTargetProduct)
        };
        IOHIDManagerSetDeviceMatching(gState.manager, (__bridge CFDictionaryRef)match);
        IOHIDManagerRegisterDeviceMatchingCallback(gState.manager, deviceMatched, NULL);
        IOHIDManagerRegisterDeviceRemovalCallback(gState.manager, deviceRemoved, NULL);
        IOHIDManagerRegisterInputValueCallback(gState.manager, inputValue, NULL);
        IOHIDManagerScheduleWithRunLoop(gState.manager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOReturn openResult = IOHIDManagerOpen(gState.manager, kIOHIDOptionsTypeNone);
        NSLog(@"IOHIDManagerOpen: 0x%08X, waiting for VID 0x%04X PID 0x%04X", openResult, kTargetVendor, kTargetProduct);

        if (gState.probeOnly) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                CFRunLoopStop(CFRunLoopGetMain());
            });
        }
        CFRunLoopRun();

        IOHIDManagerUnscheduleFromRunLoop(gState.manager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOHIDManagerClose(gState.manager, kIOHIDOptionsTypeNone);
        CFRelease(gState.manager);
        if (gState.device) CFRelease(gState.device);
    }
    return 0;
}
