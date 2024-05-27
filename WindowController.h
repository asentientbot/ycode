@interface WindowController:NSWindowController

@property(retain) XcodeViewController* xcodeViewController;

-(instancetype)initWithDocument:(Document*)document;

@end
