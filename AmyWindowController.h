@interface AmyWindowController:NSWindowController

@property(retain) XcodeViewController* xcodeViewController;
-(instancetype)initWithDocument:(AmyDocument*)document;

@end
