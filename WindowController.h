@interface WindowController:NSWindowController

@property(retain) XcodeViewController* xcodeViewController;

+(void)syncProjectMode;
-(void)replaceDocument:(Document*)document;

@end
