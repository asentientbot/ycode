@interface XcodeDocument:NSDocument

-(instancetype)initWithContentsOfURL:(NSURL*)url ofType:(NSString*)type error:(NSError**)error;

@end

@interface XcodeDocumentLocation:NSObject

-(instancetype)initWithDocumentURL:(NSURL*)url timestamp:(NSNumber*)timestamp characterRange:(NSRange)range;
-(NSRange)characterRange;

@end

@interface XcodeViewController:NSViewController

@property(retain) NSObject* fileTextSettings;

-(instancetype)initWithNibName:(NSString*)nib bundle:(NSBundle*)bundle document:(NSDocument*)document;
-(void)selectDocumentLocations:(NSArray<XcodeDocumentLocation*>*)locations;
-(NSArray<XcodeDocumentLocation*>*)currentSelectedDocumentLocations;
-(void)invalidate;
-(void)takeFocus;

@end

@interface XcodeSettings:NSObject

+(instancetype)sharedPreferences;

@end

#define XcodeThemeBackgroundKey @"DVTSourceTextBackground"
#define XcodeThemeHighlightKey @"DVTSourceTextCurrentLineHighlightColor"
#define XcodeThemeSelectionKey @"DVTSourceTextSelectionColor"
#define XcodeThemeCursorKey @"DVTSourceTextInsertionPointColor"
#define XcodeThemeInvisiblesKey @"DVTSourceTextInvisiblesColor"
#define XcodeThemeMarkdownCodeKey @"DVTMarkupTextInlineCodeColor"

#define XcodeThemeFontsKey @"DVTSourceTextSyntaxFonts"
#define XcodeThemeColorsKey @"DVTSourceTextSyntaxColors"

#define XcodeThemeCommentKeys @[@"xcode.syntax.comment",@"xcode.syntax.comment.doc",@"xcode.syntax.comment.doc.keyword",@"xcode.syntax.mark",@"xcode.syntax.url"]
#define XcodeThemePreprocessorKeys @[@"xcode.syntax.preprocessor"]
#define XcodeThemeClassKeys @[@"xcode.syntax.declaration.type"]
#define XcodeThemeFunctionKeys @[@"xcode.syntax.declaration.other",@"xcode.syntax.attribute"]
#define XcodeThemeKeywordKeys @[@"xcode.syntax.keyword"]
#define XcodeThemeStringKeys @[@"xcode.syntax.string"]
#define XcodeThemeNumberKeys @[@"xcode.syntax.number",@"xcode.syntax.character"]

@class XcodeThemeManager;

@interface XcodeTheme2:NSObject

+(XcodeThemeManager*)preferenceSetsManager;

-(NSString*)localizedName;
-(NSString*)name;
-(BOOL)hasLightBackground;
-(NSColor*)sourceTextBackgroundColor;
-(NSColor*)sourceTextCurrentLineHighlightColor;
-(NSColor*)sourceTextSelectionColor;
-(NSColor*)sourcePlainTextColor;

@end

#define XcodeLightThemeKey @"XCFontAndColorCurrentTheme"
#define XcodeDarkThemeKey @"XCFontAndColorCurrentDarkTheme"
#define XcodeThemeChangedKey @"DVTFontAndColorSettingsChangedNotification"

@interface XcodeThemeManager:NSObject

@property(retain) XcodeTheme2* currentPreferenceSet;

-(NSArray<XcodeTheme2*>*)availablePreferenceSets;

@end

NSString* xcodePath=nil;

void (*SoftInitialize)(int,NSError**);
Class SoftDocument;
Class SoftDocumentLocation;
Class SoftViewController;
Class SoftSettings;
Class SoftSettings2;
Class SoftTheme;
Class SoftTheme2;

NSMenu* (^contextMenuHook)()=NULL;

@interface Xcode:NSObject
@end
