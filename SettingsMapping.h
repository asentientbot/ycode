@interface SettingsMapping:NSObject

@property(retain) NSString* name;
@property(assign) SEL getter;
@property(assign) SEL setter;
@property(assign) BOOL defaultValue;

@end
