//
//  CPDFListView+Form.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
///

#import <ComPDFKit_Tools/ComPDFKit_Tools.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPDFListView (Form)

- (void)formTouchBeganAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

- (void)formTouchMovedAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

- (void)formTouchEndedAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

- (void)formTouchCancelledAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

- (void)formDrawPage:(CPDFPage *)page toContext:(CGContextRef)context;

- (NSArray<UIMenuItem *> *)formMenuItemsAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

@end

NS_ASSUME_NONNULL_END
