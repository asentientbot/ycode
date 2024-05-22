@interface Delegate:NSObject<NSApplicationDelegate,NSUserInterfaceValidations>

@property(assign) BOOL nextWindowIsNotTab;
@property(assign) CGPoint lastCascadePoint;

-(BOOL)shouldMakeTab;

@end
