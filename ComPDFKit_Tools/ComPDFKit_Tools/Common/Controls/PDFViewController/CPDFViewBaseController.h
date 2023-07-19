//
//  CPDFViewBaseController.h
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

@class CPDFListView;
@class CPDFPopMenu;
@class CNavigationBarTitleButton;

NS_ASSUME_NONNULL_BEGIN

@interface CPDFViewBaseController : UIViewController

@property(nonatomic, readonly) NSString *filePath;

@property(nonatomic, readonly) CPDFListView *pdfListView;

@property(nonatomic, readonly) CPDFPopMenu *popMenu;

@property(nonatomic, strong) NSString *navigationTitle;

@property(nonatomic, strong) CNavigationBarTitleButton * titleButton;

- (instancetype)initWithFilePath:(NSString *)filePath password:(nullable NSString *)password;

- (void)reloadDocumentWithFilePath:(NSString *)filePath password:(nullable NSString *)password completion:(void (^)(BOOL result))completion;

- (void)initWitNavigationTitle;

- (void)enterPDFShare;

- (void)enterPDFAddFile;

- (void)enterPDFPageEdit;

- (void)setTitleRefresh;

- (void)selectDocumentRefresh;

- (void)shareRefresh;

- (void)PDFViewCurrentPageDidChanged:(CPDFListView *)pdfView;

@end

NS_ASSUME_NONNULL_END
