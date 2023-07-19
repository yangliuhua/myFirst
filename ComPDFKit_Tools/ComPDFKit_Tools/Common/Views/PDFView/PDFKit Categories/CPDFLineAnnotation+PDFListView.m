//
//  CPDFLineAnnotation+PDFListView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFLineAnnotation+PDFListView.h"
#import "CPDFAnnotationHeader.h"

@implementation CPDFLineAnnotation (PDFListView)

- (NSSet *)keysForValuesToObserveForUndo {
    static NSSet *lineKeys = nil;
    if (lineKeys == nil) {
        NSMutableSet *mutableKeys = [[super keysForValuesToObserveForUndo] mutableCopy];
        [mutableKeys addObjectsFromArray:@[CPDFAnnotationStartPointKey,
                                           CPDFAnnotationEndPointKey,
                                           CPDFAnnotationInteriorOpacityKey,
                                           CPDFAnnotationInteriorColorKey]];
        lineKeys = [mutableKeys copy];
    }
    return lineKeys;
}

@end
