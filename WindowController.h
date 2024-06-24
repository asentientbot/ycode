@interface WindowController:NSWindowController

@property(retain) XcodeViewController* xcodeViewController;

-(void)replaceDocument:(Document*)document;

@end
