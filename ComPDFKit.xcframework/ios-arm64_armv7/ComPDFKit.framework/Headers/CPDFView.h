//
//  CPDFView.h
//  ComPDFKit
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>
#import <ComPDFKit/CPDFKitPlatform.h>

@class CPDFView, CPDFDocument, CPDFPage, CPDFSelection, CPDFDestination, CPDFFreeTextAnnotation, CPDFTextWidgetAnnotation;

typedef NS_OPTIONS(NSInteger, CEditingSelectState) {
    CEditingSelectStateEmpty = 0,
    CEditingSelectStateEditTextArea,
    CEditingSelectStateEditNoneText,
    CEditingSelectStateEditSelectText,
};

typedef NS_OPTIONS(NSInteger, CEditingLoadType) {
    CEditingLoadTypeText =            (1UL << 0),
    CEditingLoadTypeImage =           (1UL << 1),
};

typedef NS_ENUM(NSInteger, CPDFDisplayDirection) {
    CPDFDisplayDirectionVertical = 0,
    CPDFDisplayDirectionHorizontal = 1,
};

typedef NS_ENUM(NSInteger, CPDFDisplayMode) {
    CPDFDisplayModeNormal = 0,
    CPDFDisplayModeNight = 1,
    CPDFDisplayModeSoft = 2,
    CPDFDisplayModeGreen = 3,
    CPDFDisplayModeCustom = 4
};

#pragma mark - CPDFEditArea

@interface CPDFEditArea : NSObject

/**
 * Gets the current page of the text block.
 */
@property (nonatomic,readonly) CPDFPage *page;

/**
 * Gets the position size of the text block.
 */
@property (nonatomic,readonly) CGRect bounds;

/**
 * Gets the current selection.
 */
@property (nonatomic,readonly) CPDFSelection *selection;

/**
 * Whether it is text code block.
 */
- (BOOL)IsTextArea;

@end

#pragma mark - CPDFEditTextArea

@interface CPDFEditTextArea : CPDFEditArea

@end


@interface CPDFEditingConfig : NSObject

/**
 * Sets the unselected border color of the text code block.
 */
@property (nonatomic,retain) CPDFKitPlatformColor *editingBorderColor;

/**
 * Sets the selected border color of the text code block.
 */
@property (nonatomic,retain) CPDFKitPlatformColor *editingSelectionBorderColor;

/**
 * Border width of the text code block.
 */
@property (nonatomic,assign) CGFloat editingBorderWidth;

/**
 * Array of dashed lines of the text code block.
 */
@property (nonatomic,retain) NSArray * editingBorderDashPattern;

@end

@protocol CPDFViewDelegate <NSObject>

@optional

- (void)PDFViewDocumentDidLoaded:(CPDFView *)pdfView;

- (void)PDFViewCurrentPageDidChanged:(CPDFView *)pdfView;

- (void)PDFViewDidClickOnLink:(CPDFView *)pdfView withURL:(NSString *)url;

- (void)PDFViewPerformURL:(CPDFView *)pdfView withContent:(NSString *)content;

- (void)PDFViewPerformUOP:(CPDFView *)pdfView withContent:(NSString *)content;

- (void)PDFViewPerformPrint:(CPDFView *)pdfView;

- (void)PDFViewPerformReset:(CPDFView *)pdfView;

- (void)PDFViewShouldBeginEditing:(CPDFView *)pdfView textView:(UITextView *)textView forAnnotation:(CPDFFreeTextAnnotation *)annotation;

- (void)PDFViewShouldEndEditing:(CPDFView *)pdfView textView:(UITextView *)textView forAnnotation:(CPDFFreeTextAnnotation *)annotation;

- (void)PDFViewShouldBeginEditing:(CPDFView *)pdfView textView:(UITextView *)textView forTextWidget:(CPDFTextWidgetAnnotation *)textWidget;

- (void)PDFViewShouldEndEditing:(CPDFView *)pdfView textView:(UITextView *)textView forTextWidget:(CPDFTextWidgetAnnotation *)textWidget;

- (void)PDFViewDidEndDragging:(CPDFView *)pdfView;

- (void)PDFViewEditingOperationDidChanged:(CPDFView *)pdfView;

- (void)PDFViewEditingSelectStateDidChanged:(CPDFView *)pdfView;

- (void)PDFEditingViewShouldBeginEditing:(CPDFView *)pdfView textView:(UITextView *)textView;

- (void)PDFEditingViewShouldEndEditing:(CPDFView *)pdfView textView:(UITextView *)textView;

@end

/**
 * This class is the main view of ComPDFKit you can instantiate a CPDFView that will host the contents of a CPDFDocument.
 *
 * @discussion CPDFView may be the only class you need to deal with for adding PDF functionality to your application.
 * It lets you display PDF data and allows users to select content, navigate through a document, set zoom level, and copy textual content to the Pasteboard.
 * CPDFView also keeps track of page history. You can subclass CPDFView to create a custom PDF viewer.
 */
@interface CPDFView : UIView

#pragma mark - Document

/**
 * Methods for associating a CPDFDocument with a CPDFView.
 */
@property (nonatomic,retain) CPDFDocument *document;

#pragma mark - Accessors

/**
 * Returns the view’s delegate.
 *
 * @see CPDFViewDelegate
 */
@property (nonatomic,assign) id<CPDFViewDelegate> delegate;

/**
 * A Boolean value indicating whether the document displays two pages side-by-side.
 */
@property (nonatomic,assign) BOOL displayTwoUp;

/**
 * Specifies whether the first page is to be presented as a cover and displayed by itself (for two-up modes).
 */
@property (nonatomic,assign) BOOL displaysAsBook;

/**
 * The layout direction, either vertical or horizontal, for the given display mode.
 *
 * @discussion Defaults to vertical layout (CPDFDisplayDirectionVertical).
 * @see CPDFDisplayDirection
 */
@property (nonatomic,assign) CPDFDisplayDirection displayDirection;

/**
 * A Boolean value indicating whether the view is displaying page breaks.
 *
 * @discussion Toggle displaying or not displaying page breaks (spacing) between pages. This spacing value is defined by the pageBreakMargins property.
 * If displaysPageBreaks is NO, then pageBreakMargins will always return { 10.0, 10.0, 10.0, 10.0 }. Default is YES.
 */
@property (nonatomic,assign) BOOL displaysPageBreaks;

/**
 * The spacing between pages as defined by the top, bottom, left, and right margins.
 *
 * @discussion If displaysPageBreaks is enabled, you may customize the spacing between pages by defining margins for the top, bottom, left, and right of each page.
 * Note that pageBreakMargins only allows positive values and will clamp any negative value to 0.0.
 * By default, if displaysPageBreaks is enabled, pageBreakMargins is { 10.0, 10.0, 10.0, 10.0 } (with respect to top, left, bottom, right), otherwise it is { 0.0, 0.0, 0.0, 0.0 }.
 */
@property (nonatomic,assign) UIEdgeInsets pageBreakMargins;

/**
 * The page render mode, either normal, night, soft, green or custom, for the given display mode.
 *
 * @see CPDFDisplayMode
 */
@property (nonatomic,assign) CPDFDisplayMode displayMode;
/**
 * If displayMode is CPDFDisplayModeCustom, you may customize the color of the page rendering.
 */
@property (nonatomic,retain) UIColor *displayModeCustomColor;

/**
 * A Boolean value indicating whether the view is displaying page crop.
 *
 * @discussion Automatically crop out valid content from the page, If there is no content in the page, no cropping will be done.
 */
@property (nonatomic,assign) BOOL displayCrop;

/**
 * A Boolean value that determines whether scrolling is enabled for the document view.
 */
@property (nonatomic,assign) BOOL scrollEnabled;

/**
 * A Boolean value that determines whether scrolling is disabled in the vertical direction for the document view.
 */
@property (nonatomic,assign) BOOL directionaHorizontalLockEnabled;

/**
 * The current scale factor for the view.
 *
 * @discussion Method to get / set the current scaling on the displayed PDF document. Default is 1.0.
 */
@property (nonatomic,assign) CGFloat scaleFactor;

- (void)setScaleFactor:(CGFloat)scaleFactor animated:(BOOL)animated;

#pragma mark - Draw

@property (nonatomic,readonly) BOOL isDrawing;
@property (nonatomic,readonly) BOOL isDrawErasing;

- (void)beginDrawing;
- (void)endDrawing;
- (void)commitDrawing;

- (void)setDrawErasing:(BOOL)isErasing;
- (void)drawUndo;
- (void)drawRedo;

#pragma mark - Annotation

- (void)editAnnotationFreeText:(CPDFFreeTextAnnotation *)freeText;
- (void)commitEditAnnotationFreeText;
- (void)setEditAnnotationFreeTextFont:(UIFont *)font;
- (void)setEditAnnotationFreeTextColor:(UIColor *)color;

#pragma mark - Page

/**
 * Returns the current page index.
 */
@property (nonatomic,readonly) NSInteger currentPageIndex;

/**
 * Scrolls to the specified page.
 */
- (void)goToPageIndex:(NSInteger)pageIndex animated:(BOOL)animated;

/**
 * Returns a CPDFDestination object representing the current page and the current point in the view specified in page space.
 */
@property (nonatomic,readonly) CPDFDestination *currentDestination;

/**
 * Goes to the specified destination.
 *
 * Destinations include a page and a point on the page specified in page space.
 */
- (void)goToDestination:(CPDFDestination *)destination animated:(BOOL)animated;

/**
 * Goes to the specified rectangle on the specified page.
 *
 * @discussion This allows you to scroll the CPDFView object to a specific CPDFAnnotation or CPDFSelection object,
 * because both of these objects have bounds methods that return an annotation or selection position in page space.
 * Note that rect is specified in page-space coordinates. Page space is a coordinate system with the origin at the lower-left corner of the current page.
 */
- (void)goToRect:(CGRect)rect onPage:(CPDFPage *)page animated:(BOOL)animated;

/**
 * Returns an array of CPDFPage objects that represent the currently visible pages.
 */
@property (nonatomic,readonly) NSArray<CPDFPage *> *visiblePages;

#pragma mark - Selection

/**
 * Enter text selection mode.
 *
 * @discussion The scrollEnabled is NO in the text selection mode.
 */
@property (nonatomic,assign) BOOL textSelectionMode;

/**
 * Returns actual instance of the current CPDFSelection object.
 *
 * @discussion The view redraws as necessary but does not scroll.
 */
@property (nonatomic,readonly) CPDFSelection *currentSelection;

/**
 * Clears the selection.
 *
 * @discussion The view redraws as necessary but does not scroll.
 */
- (void)clearSelection;

/**
 * Goes to the first character of the specified selection.
 */
- (void)goToSelection:(CPDFSelection *)selection animated:(BOOL)animated;

/**
 * The following calls allow you to associate a CPDFSelection with a CPDFView.
 *
 * @discussion The selection do not go away when the user clicks in the CPDFView, etc. You must explicitly remove them by passing nil to -[setHighlightedSelection:animated:].
 * This method allow you to highlight text perhaps to indicate matches from a text search. Commonly used for highlighting search results.
 */
- (void)setHighlightedSelection:(CPDFSelection *)selection animated:(BOOL)animated;

#pragma mark - Display

/**
 * The innermost view used by CPDFView or by your CPDFView subclass.
 *
 * @discussion The innermost view is the one displaying the visible document pages.
 */
- (UIScrollView *)documentView;

/**
 * Performs layout of the inner views.
 *
 * @discussion The CPDFView actually contains several subviews. Changes to the PDF content may require changes to these inner views,
 * so you must call this method explicitly if you use PDF Kit utility classes to add or remove a page, rotate a page, or perform other operations affecting visible layout.
 * This method is called automatically from CPDFView methods that affect the visible layout (such as setDocument:).
 */
- (void)layoutDocumentView;

/**
 * Draw and render of the currently visible pages.
 */
- (void)setNeedsDisplayForVisiblePages;

/**
 * Draw and render of the specified page.
 */
- (void)setNeedsDisplayForPage:(CPDFPage *)page;

#pragma mark - Rendering

/**
 * Draw and render a visible page to a context.
 *
 * @discussion For subclasses. This method is called for each visible page requiring rendering. By subclassing you can draw on top of the PDF page.
 */
- (void)drawPage:(CPDFPage *)page toContext:(CGContextRef)context;

#pragma mark - Menu

- (NSArray<UIMenuItem *> *)menuItemsAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

#pragma mark - Touch

- (void)touchBeganAtPoint:(CGPoint)point forPage:(CPDFPage *)page;
- (void)touchMovedAtPoint:(CGPoint)point forPage:(CPDFPage *)page;
- (void)touchEndedAtPoint:(CGPoint)point forPage:(CPDFPage *)page;
- (void)touchCancelledAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

#pragma mark - Conversion

/**
 * Converts a point from view space to page space.
 *
 * @discussion Page space is a coordinate system with the origin at the lower-left corner of the current page.
 * View space is a coordinate system with the origin at the upper-left corner of the current PDF view.
 */
- (CGPoint)convertPoint:(CGPoint)point toPage:(CPDFPage *)page;
/**
 * Converts a rectangle from view space to page space.
 *
 * @discussion Page space is a coordinate system with the origin at the lower-left corner of the current page.
 * View space is a coordinate system with the origin at the upper-left corner of the current PDF view.
 */
- (CGRect)convertRect:(CGRect)rect toPage:(CPDFPage *)page;
/**
 * Converts a point from page space to view space.
 *
 * @discussion Page space is a coordinate system with the origin at the lower-left corner of the current page.
 * View space is a coordinate system with the origin at the upper-left corner of the current PDF view.
 */
- (CGPoint)convertPoint:(CGPoint)point fromPage:(CPDFPage *)page;
/**
 * Converts a rectangle from page space to view space.
 *
 * @discussion Page space is a coordinate system with the origin at the lower-left corner of the current page.
 * View space is a coordinate system with the origin at the upper-left corner of the current PDF view.
 */
- (CGRect)convertRect:(CGRect)rect fromPage:(CPDFPage *)page;

#pragma mark - Edit
/**
 * This method is about configuring of editing content.
 */
@property (nonatomic,retain) CPDFEditingConfig *editingConfig;

/**
 * Begins editing content.
 */
- (void)beginEditingLoadType:(CEditingLoadType)editingLoadType;

/**
 * Ends editing content.
 */
- (void)endOfEditing;

/**
 * Submits the edited content.
 */
- (void)commitEditing;

/**
 * Gets whether to enter the editing mode.
 */
- (BOOL)isEditing;

/**
 * Whether the content is modified.
 */
- (BOOL)isEdited;

/**
 * The selected block.
 */
- (CPDFEditArea *)editingArea;

/**
 * Clicks the context menu of block.
 */
- (NSArray<UIMenuItem *> *)menuItemsEditingAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

/**
 * Gets the font size of a text block or a piece of text.
 */
- (CGFloat)editingSelectionFontSize;

/**
 * Sets the font size of a text block or a piece of text.
 */
- (void)setEditingSelectionFontSize:(CGFloat)fontSize;

/**
 * Gets the font color of a text block or a piece of text.
 */
- (CPDFKitPlatformColor *)editingSelectionFontColor;

/**
 * Sets the font color of a text block or a piece of text.
 */
- (void)setEditingSelectionFontColor:(CPDFKitPlatformColor *)fontColor;

/**
 * Gets the alignment of a text block or a piece of text.
 */
- (NSTextAlignment)editingSelectionAlignment;

/**
 * Sets the alignment of a text block or a piece of text.
 */
- (void)setCurrentSelectionAlignment:(NSTextAlignment)alignment;

/**
 * The statuses when editing.
 *
 * @see CEditingSelectState
 */
- (CEditingSelectState )editStatus;

/**
 * Whether to support undo on current page.
 */
- (BOOL)canEditTextUndo;

/**
 * Whether to support redo on current page.
 */
- (BOOL)canEditTextRedo;

/**
 * Undo on current page.
 */
- (void)editTextUndo;

/**
 * Redo on current page.
 */
- (void)editTextRedo;

/**
 * The font name of the currently selected text block.
 */
- (NSString *)editingSelectionFontName;

/**
 * Sets the font name of the selected text block. (Several standard fonts are currently supported)
 */
- (void)setEditingSelectionFontName:(NSString *)fontName;

/**
 * Sets the currently selected text is italic.
 */
- (void)setCurrentSelectionIsItalic:(BOOL)isItalic;

/**
 * Whether the font of the currently selected text block is italic.
 */
- (BOOL)isItalicCurrentSelection;

/**
 * Sets the currently selected text is bold.
 */
- (void)setCurrentSelectionIsBold:(BOOL)isBold;

/**
 * Whether the font of the currently selected text block is bold.
 */
- (BOOL)isBoldCurrentSelection;

/**
 * Create a blank text block.
 * @param rect The area of the text box.
 * @param attributes The text font properties.
 * @param page The created page number.
 * @return Returns whether the creation is successful.
 */
- (BOOL)createEmptyStringBounds:(CGRect)rect withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes page:(CPDFPage *)page;

@end
