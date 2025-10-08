enum
{
	TagSetting=1,
	TagTheme,
	TagProjectMode,
	TagTab,
	TagFileAssociation,
};

@interface Delegate:NSObject<NSApplicationDelegate,NSUserInterfaceValidations,NSWindowDelegate>

@property(assign,nonatomic) BOOL projectMode;
@property(retain) NSString* currentScreenKey;

+(Delegate*)shared;

@end
