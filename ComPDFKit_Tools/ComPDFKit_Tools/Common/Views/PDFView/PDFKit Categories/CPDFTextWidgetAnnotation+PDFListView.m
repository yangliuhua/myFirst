//
//  CPDFTextWidgetAnnotation+PDFListView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFTextWidgetAnnotation+PDFListView.h"
#import "CPDFAnnotationHeader.h"

@implementation CPDFTextWidgetAnnotation (PDFListView)

- (NSSet *)keysForValuesToObserveForUndo {
    static NSSet *widgetKeys = nil;
    if (widgetKeys == nil) {
        NSMutableSet *mutableKeys = [[super keysForValuesToObserveForUndo] mutableCopy];
        [mutableKeys addObjectsFromArray:@[CPDFAnnotationWidgetStringValueKey,
                                           CPDFAnnotationAlignmentKey,
                                           CPDFAnnotationWidgetIsMultilineKey
                                         ]];
        widgetKeys = [mutableKeys copy];
    }
    return widgetKeys;
}
@end
