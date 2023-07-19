//
//  CBlankPageIModel.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CPDFPage;

@interface CBlankPageModel : NSObject

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) NSInteger rotation;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, strong) NSArray<UIImage *> *images;

@property (nonatomic, strong) NSIndexSet *indexSet;

@end

NS_ASSUME_NONNULL_END
