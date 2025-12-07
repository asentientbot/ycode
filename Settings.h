#define AmyThemeBackgroundColor @"1 1 1"

#define AmyThemeBaseColor @"0.1 0 0.4"
#define AmyThemeNormalColor [Settings lightColorStringWithString:AmyThemeBaseColor alpha:0.7]
#define AmyThemeMetaColor [Settings lightColorStringWithString:AmyThemeBaseColor alpha:0.5]
#define AmyThemeHighlightColor [Settings lightColorStringWithString:AmyThemeBaseColor alpha:0.05]
#define AmyThemeSelectionColor [Settings lightColorStringWithString:AmyThemeBaseColor alpha:0.15]

#define AmyThemeKeywordColor @"0.7 0 0.7"
#define AmyThemeTypeColor @"0.5 0 0.8"

#define AmyThemeStringColor @"0.8 0.3 1"
#define AmyThemeNumberColor @"0.5 0.3 1"

#define AmyThemeRegularFont @"SFMono-Regular - 12"
#define AmyThemeItalicFont @"SFMono-RegularItalic - 12"
#define AmyThemeBoldFont @"SFMono-Bold - 12"

#define AmyThemeTerminalFont @"SFMono-Regular"
#define AmyThemeTerminalFontSize 11

#define TypeOverrideMapping @{\
	@"com.apple.property-list":@"public.xml",\
	@"com.apple.applesingle-archive":@"com.netscape.javascript-source",\
	@"com.apple.terminal.settings":@"public.xml"\
}

@interface Settings:NSObject
@end
