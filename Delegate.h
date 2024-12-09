@interface Delegate:NSObject<NSApplicationDelegate,NSUserInterfaceValidations,NSWindowDelegate>

@property(assign) BOOL projectMode;
@property(retain) NSString* currentScreenKey;

+(Delegate*)shared;

@end
