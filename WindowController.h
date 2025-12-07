@interface WindowController:NSWindowController

@property(retain,nonatomic) XcodeViewController* xcodeViewController;

-(void)replaceDocument:(Document*)document;

@end
