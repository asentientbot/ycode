#define AmyThemeBlurMaterial NSVisualEffectMaterialMenu
#define AmyThemeBackgroundColorOpaque @"1 1 1"
#define AmyThemeBackgroundColorTranslucent @"1 1 1 0.8"

#define AmyThemeBaseColor @"0.1 0 0.5"
#define AmyThemeNormalColor [AmyThemeBaseColor stringByAppendingString:@" 0.7"]
#define AmyThemeMetaColor [AmyThemeBaseColor stringByAppendingString:@" 0.5"]
#define AmyThemeHighlightColor [AmyThemeBaseColor stringByAppendingString:@" 0.05"]
#define AmyThemeSelectionColor [AmyThemeBaseColor stringByAppendingString:@" 0.15"]

#define AmyThemeKeywordColor @"0.7 0 0.8 0.9"
#define AmyThemeTypeColor @"0.5 0 0.8 0.9"

#define AmyThemeStringColor @"0.7 0 0.9 0.7"
#define AmyThemeNumberColor @"0.3 0 0.9 0.7"

#define AmyThemeRegularFont @"SFMono-Regular - 12"
#define AmyThemeItalicFont @"SFMono-RegularItalic - 12"
#define AmyThemeBoldFont @"SFMono-Bold - 12"

#define AmyThemeTerminalBlurAmount 1
#define AmyThemeTerminalBackgroundColor @"1 1 1 0.9"
#define AmyThemeTerminalFont @"SFMono-Regular"
#define AmyThemeTerminalFontSize 11

#define TypeOverrideMapping @{\
	@"com.apple.property-list":@"public.xml",\
	@"com.apple.applesingle-archive":@"com.netscape.javascript-source",\
	@"com.apple.terminal.settings":@"public.xml"\
}

@interface Settings:NSObject
@end
