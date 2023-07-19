//
//  CPDFToolsViewController.h
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
#import <ComPDFKit_Tools/CPDFListView.h>

NS_ASSUME_NONNULL_BEGIN

@class CPDFToolsViewController;

@protocol CPDFToolsViewControllerDelegate <NSObject>

@required

- (void)CPDFToolsViewControllerDismiss:(CPDFToolsViewController *) viewController selectItemAtIndex:(CToolModel)selectIndex;

@end

@interface CPDFToolsViewController : UIViewController

@property (nonatomic, weak) id<CPDFToolsViewControllerDelegate> delegate;

- (instancetype)initCustomizeWithToolArrays:(NSArray *)toolsTypes;

@end

NS_ASSUME_NONNULL_END
