#define ScratchWidth 600
#define ScratchHeight 500

@interface WindowController:NSWindowController

@property(retain,nonatomic) XcodeViewController* xcodeViewController;

-(void)replaceDocument:(Document*)document;

@end
