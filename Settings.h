#define AmyThemeBlurMaterial NSVisualEffectMaterialMenu
#define AmyThemeBackgroundColorOpaque @"1 1 1"
#define AmyThemeBackgroundColorTranslucent @"1 1 1 0.8"

#define AmyThemeBaseColor @"0.1 0 0.5"
#define AmyThemeNormalColor [AmyThemeBaseColor stringByAppendingString:@" 0.8"]
#define AmyThemeMetaColor [AmyThemeBaseColor stringByAppendingString:@" 0.6"]
#define AmyThemeHighlightColor [AmyThemeBaseColor stringByAppendingString:@" 0.05"]
#define AmyThemeSelectionColor [AmyThemeBaseColor stringByAppendingString:@" 0.15"]

#define AmyThemeKeywordColor @"0.7 0 0.8 0.9"
#define AmyThemeTypeColor @"0.5 0 0.8 0.9"

#define AmyThemeStringColor @"0.7 0 0.9 0.7"
#define AmyThemeNumberColor @"0.3 0 1 0.7"

#define AmyThemeRegularFont @"SFMono-Light - 12"
#define AmyThemeItalicFont @"SFMono-LightItalic - 12"
#define AmyThemeBoldFont @"SFMono-Semibold - 12"

#define AmyThemeTerminalBlurAmount 1
#define AmyThemeTerminalBackgroundColor @"1 1 1 0.9"
#define AmyThemeTerminalFont @"SFMono-Light"
#define AmyThemeTerminalFontSize 11

@interface Settings:NSObject
@end
