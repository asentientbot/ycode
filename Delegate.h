@interface Delegate:NSObject<NSApplicationDelegate,NSUserInterfaceValidations,NSWindowDelegate>

@property(assign) BOOL projectMode;

+(Delegate*)shared;

@end
