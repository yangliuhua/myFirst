//
//  CPDFViewBaseController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFViewBaseController.h"
#import "CDocumentPasswordViewController.h"
#import "CPDFListView+UndoManager.h"

#import <ComPDFKit/ComPDFKit.h>
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>

@interface CPDFViewBaseController ()<UISearchBarDelegate,CPDFViewDelegate,CPDFListViewDelegate, CSearchToolbarDelegate, CPDFDisplayViewDelegate, CPDFBOTAViewControllerDelegate,CPDFSearchResultsDelegate, CPDFThumbnailViewControllerDelegate,CPDFPopMenuViewDelegate,UIDocumentPickerDelegate,CPDFPopMenuDelegate,CDocumentPasswordViewControllerDelegate,CPDFPageEditViewControllerDelegate>

@property(nonatomic, strong) NSString *filePath;

@property(nonatomic, strong) CPDFListView *pdfListView;

@property(nonatomic, strong) CNavigationRightView *rightView;

@property(nonatomic, strong) CSearchToolbar *searchToolbar;

@property(nonatomic, strong) CActivityIndicatorView *loadingView;

@property(nonatomic, strong)  CPDFPopMenu *popMenu;

@property(nonatomic, strong) UIBarButtonItem * leftBarButtonItem;

@property(nonatomic, strong) NSString *password;

@end

@implementation CPDFViewBaseController

#pragma mark - Initializers

- (instancetype)initWithFilePath:(NSString *)filePath password:(nullable NSString *)password{
    if(self = [super init]) {
        self.filePath = filePath;
        self.password = password;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    
    [self initWitPDFListView];
    
    [self initWitNavigation];
    
    [self initWitNavigationTitle];
    
    [self initWithSearchTool];
            
    [self reloadDocumentWithFilePath:self.filePath password:self.password completion:^(BOOL result) {
        
    }];
}

#pragma mark - Private method

-(void)updatePDFViewDocumentView {
    UIScrollView * documentView = [self.pdfListView documentView];
    if (CPDFDisplayDirectionVertical == [CPDFKitConfig  sharedInstance].displayDirection) {
        if (self.pdfListView.currentPageIndex != 0) {
            if (@available(iOS 11.0, *)) {
                documentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            } else {
                self.automaticallyAdjustsScrollViewInsets = NO;
            }
        } else {
            if (@available(iOS 11.0, *)) {
                documentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
            } else {
                self.automaticallyAdjustsScrollViewInsets = YES;
            }
        }
    } else {
        if (@available(iOS 11.0, *)) {
            documentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
}

- (void)initWitPDFListView {
    self.pdfListView = [[CPDFListView alloc] initWithFrame:self.view.bounds];
    self.pdfListView.performDelegate = self;
    self.pdfListView.delegate = self;
    self.pdfListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.pdfListView];
}

- (void)initWitNavigation {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CPDFThunbnailImageEnter" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(buttonItemClicked_thumbnail:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.leftBarButtonItem = leftItem;
    
    __block typeof(self) blockSelf = self;
    
    self.rightView = [[CNavigationRightView alloc] initWithDefaultItemsClickBack:^(NSUInteger tag) {
        switch (tag) {
            case CNavigationRightTypeSearch:
                [blockSelf navigationRightItemSearch];
                break;
            case CNavigationRightTypeBota:
                [blockSelf navigationRightItemBota];
                break;
            default:
            case CNavigationRightTypeMore:
                [blockSelf navigationRightItemMore];
                break;
        }
    }];
}

- (void)initWithSearchTool {
    self.searchToolbar = [[CSearchToolbar alloc] initWithPDFView:self.pdfListView];
    self.searchToolbar.delegate = self;
}

- (void)enterPDFSetting  {
    [self.popMenu hideMenu];
    CPDFDisplayViewController *displayVc = [[CPDFDisplayViewController alloc] initWithPDFView:self.pdfListView];
    displayVc.delegate = self;
    
    
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:displayVc presentingViewController:self];
    displayVc.transitioningDelegate = presentationController;
    [self presentViewController:displayVc animated:YES completion:nil];
}

- (void)enterPDFInfo  {
    [self.popMenu hideMenu];
    CPDFInfoViewController * infoVc = [[CPDFInfoViewController alloc] initWithPDFView:self.pdfListView];
    
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:infoVc presentingViewController:self];
    infoVc.transitioningDelegate = presentationController;
    [self presentViewController:infoVc animated:YES completion:nil];
}

- (void)enterPDFShare  {
    [self.popMenu hideMenu];
    
    if (self.pdfListView.isEditing && self.pdfListView.isEdited) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.pdfListView commitEditing];
            
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingFormat:@"/%@/%@", @"Documents", self.pdfListView.document.documentURL.lastPathComponent];
            NSURL *url = [NSURL fileURLWithPath:documentFolder];
            
            if(self.pdfListView.document.isModified) {
                [self.pdfListView.document writeToURL:url];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self shareAction];
            });

        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingFormat:@"/%@/%@", @"Documents", self.pdfListView.document.documentURL.lastPathComponent];
            NSURL *url = [NSURL fileURLWithPath:documentFolder];
            
            if(self.pdfListView.document.isModified) {
                [self.pdfListView.document writeToURL:url];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self shareAction];
            });
        });

    }
    
}

- (void)enterPDFAddFile  {
    [self.popMenu hideMenu];
    
    NSArray *documentTypes = @[@"com.adobe.pdf"];
    UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
            documentPickerViewController.delegate = self;
    [self presentViewController:documentPickerViewController animated:YES completion:nil];
}

- (void)enterPDFPageEdit{
    [self.popMenu hideMenu];
    
    CPDFPageEditViewController *pageEditViewcontroller = [[CPDFPageEditViewController alloc] initWithPDFView:self.pdfListView];
    pageEditViewcontroller.pageEditDelegate = self;
    pageEditViewcontroller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:pageEditViewcontroller animated:YES completion:nil];
    [pageEditViewcontroller beginEdit];
}

#pragma mark - CPDFPageEditViewControllerDelegate

- (void)pageEditViewControllerDone:(CPDFPageEditViewController *)pageEditViewController {
    __weak typeof(self) weakSelf = self;
    [weakSelf reloadDocumentWithFilePath:self.filePath password:nil completion:^(BOOL result) {
        [weakSelf.pdfListView reloadInputViews];
    }];

    [weakSelf.pdfListView reloadInputViews];
}

- (void)pageEditViewController:(CPDFPageEditViewController *)pageEditViewController pageIndex:(NSInteger)pageIndex isPageEdit:(BOOL)isPageEdit {
    if (isPageEdit) {
        __weak typeof(self) weakSelf = self;
        [weakSelf reloadDocumentWithFilePath:self.filePath password:nil completion:^(BOOL result) {
            [weakSelf.pdfListView reloadInputViews];
        }];
        
        [weakSelf.pdfListView reloadInputViews];
    }
   
    [self.pdfListView goToPageIndex:pageIndex animated:NO];
}

#pragma mark - Public method

- (void)initWitNavigationTitle {
    CNavigationBarTitleButton * navTitleButton = [[CNavigationBarTitleButton alloc] init];
    self.titleButton = navTitleButton;
    self.navigationTitle = NSLocalizedString(@"Viewer", nil);
    [navTitleButton setTitle:self.navigationTitle forState:UIControlStateNormal];
    [navTitleButton setTitleColor:[CPDFColorUtils CAnyReverseBackgooundColor] forState:UIControlStateNormal];
    self.titleButton.frame = CGRectMake(0, 0, 100, 30);
    self.navigationItem.titleView = self.titleButton;
}

- (void)reloadDocumentWithFilePath:(NSString *)filePath password:(nullable NSString *)password completion:(void (^)(BOOL result))completion {
    
    [self.navigationController.view setUserInteractionEnabled:NO];
    
    if (![self.loadingView superview]) {
        [self.view addSubview:self.loadingView];
    }
    [self.loadingView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL fileURLWithPath:filePath];
        CPDFDocument *document = [[CPDFDocument alloc] initWithURL:url];
        if([document isLocked]) {
            [document unlockWithPassword:password];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController.view setUserInteractionEnabled:YES];
            [self.loadingView stopAnimating];
            [self.loadingView removeFromSuperview];
            
            if (document.error && document.error.code != CPDFDocumentPasswordError) {
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:NSLocalizedString(@"Sorry PDF Reader Can't open this pdf file!", nil)
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:okAction];
                if (completion) {
                    completion(NO);
                }
            } else {
                self.pdfListView.document = document;
                if (completion) {
                    completion(YES);
                }
            }
        });
    });
}

- (void)setTitleRefresh {
    
}

- (void)selectDocumentRefresh {
    
}

- (void)shareRefresh {
    
}

#pragma mark - Action

- (void)navigationRightItemSearch {
    [self.searchToolbar showInView:self.navigationController.navigationBar];
    self.navigationTitle = @"";
    self.titleButton.hidden = YES;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)navigationRightItemBota {
    CPDFBOTAViewController *botaViewController = [[CPDFBOTAViewController alloc] initWithPDFView:self.pdfListView];
    botaViewController.delegate = self;
    
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
   
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:botaViewController presentingViewController:self];
    botaViewController.transitioningDelegate = presentationController;
    
    [self presentViewController:botaViewController animated:YES completion:nil];
}

- (void)navigationRightItemMore {
    CPDFPopMenuView * menuView = [[CPDFPopMenuView alloc] initWithFrame:CGRectMake(0, 0, 200, 250)];
    menuView.delegate = self;
    self.popMenu = [CPDFPopMenu popMenuWithContentView:menuView];
    self.popMenu.dimCoverLayer = YES;
    self.popMenu.delegate = self;
    
    if (@available(iOS 11.0, *)) {
        [self.popMenu showMenuInRect:CGRectMake(self.view.frame.size.width - self.view.safeAreaInsets.right - 250, CGRectGetMaxY(self.navigationController.navigationBar.frame), 250, 250)];
    } else {
        // Fallback on earlier versions
        [self.popMenu showMenuInRect:CGRectMake(self.view.frame.size.width - 250, CGRectGetMaxY(self.navigationController.navigationBar.frame), 250, 250)];
    }
}

- (void)buttonItemClicked_thumbnail:(id)sender {
    if(self.pdfListView.activeAnnotations.count > 0) {
        [self.pdfListView updateActiveAnnotations:@[]];
        [self.pdfListView setNeedsDisplayForVisiblePages];
    }
    CPDFThumbnailViewController *thumbnailViewController = [[CPDFThumbnailViewController alloc] initWithPDFView:self.pdfListView];
    thumbnailViewController.delegate = self;
    
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:thumbnailViewController presentingViewController:self];
    thumbnailViewController.transitioningDelegate = presentationController;
    [self presentViewController:thumbnailViewController animated:YES completion:nil];
}

#pragma mark - CPDFViewDelegate

- (void)PDFViewDocumentDidLoaded:(CPDFView *)pdfView {
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightView];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self updatePDFViewDocumentView];
}

- (void)PDFViewCurrentPageDidChanged:(CPDFListView *)pdfView {
    [self updatePDFViewDocumentView];
}


- (void)PDFViewPerformURL:(CPDFView *)pdfView withContent:(NSString *)content {
    if (content) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:content]];
    } else {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                       message:NSLocalizedString(@"The hyperlink is invalid.", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)PDFViewPerformReset:(CPDFView *)pdfView {
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self.pdfListView.document resetForm];
        [self.pdfListView setNeedsDisplayForVisiblePages];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:[NSString stringWithFormat:NSLocalizedString(@"Do you really want to reset the form?", nil)]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)PDFViewPerformPrint:(CPDFView *)pdfView {
    NSLog(@"Print");
}

#pragma mark - CSearchToolbarDelegate

- (void)searchToolbar:(CSearchToolbar *)searchToolbar onSearchQueryResults:(NSArray *)results {
    if ([results count] < 1) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:NSLocalizedString(@"your have‘t search result", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    CPDFSearchResultsViewController* searchResultController = [[CPDFSearchResultsViewController alloc] initWithResultArray:results keyword:searchToolbar.searchKeyString document:self.pdfListView.document];
    searchResultController.delegate = self;
    
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:searchResultController presentingViewController:self];
    searchResultController.transitioningDelegate = presentationController;
    [self presentViewController:searchResultController animated:YES completion:nil];
}

- (void)searchToolbarOnExitSearch:(CSearchToolbar *)searchToolbar {
    if([searchToolbar superview]) {
        [searchToolbar removeFromSuperview];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightView];
        self.navigationItem.rightBarButtonItem = rightItem;
        self.title = self.navigationTitle;
        
        self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    }
    self.navigationTitle = NSLocalizedString(@"Viewer",nil);
    self.titleButton.hidden = NO;
}

#pragma mark - CPDFDisplayViewDelegate

- (void)displayViewControllerDismiss:(CPDFDisplayViewController *)displayViewController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - CPDFBOTAViewControllerDelegate

- (void)botaViewControllerDismiss:(CPDFBOTAViewController *)botaViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CPDFSearchResultsDelegate

- (void)searchResultsView:(CPDFSearchResultsViewController *)resultVC forSelection:(CPDFSelection *)selection indexPath:(NSIndexPath *)indexPath {
    
    NSInteger pageIndex = [self.pdfListView.document indexForPage:selection.page];
    [self.pdfListView goToPageIndex:pageIndex animated:NO];
    [self.pdfListView setHighlightedSelection:selection animated:YES];
}

- (void)searchResultsViewControllerDismiss:(CPDFSearchResultsViewController *)searchResultsViewController {
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - CPDFPopMenuDelegate

- (void)menuDidClosedIn:(CPDFPopMenu *)menu isClosed:(BOOL)isClosed {
    
}

#pragma mark - CPDFThumbnailViewControllerDelegate

- (void)thumbnailViewController:(CPDFThumbnailViewController *)thumbnailViewController pageIndex:(NSInteger)pageIndex {
    [self.pdfListView goToPageIndex:pageIndex animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CPDFMenuViewdelegate

- (void)menuDidClickAtView:(CPDFPopMenuView *)view clickType:(CPDFPopMenuViewType)viewType {
    switch (viewType) {
        case CPDFPopMenuViewTypeSetting: {
            [self enterPDFSetting];
        }
            break;
            
        case CPDFPopMenuViewTypePageEdit: {
            [self enterPDFPageEdit];
        }
            break;
            
        case CPDFPopMenuViewTypeInfo:{
            [self enterPDFInfo];
        }
            break;
            
        case CPDFPopMenuViewTypeShare: {
            [self enterPDFShare];
        }
            break;
            
        case CPDFPopMenuViewTypeAddFile: {
            [self enterPDFAddFile];
            break;
        }
            
        default:
            break;
    }
}

- (void)shareAction {
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingFormat:@"/%@/%@", @"Documents", self.pdfListView.document.documentURL.lastPathComponent];
    NSURL *url = [NSURL fileURLWithPath:documentFolder];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:@[url] applicationActivities:nil];
        activityVC.definesPresentationContext = YES;
        if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
            activityVC.popoverPresentationController.sourceView = self.rightView;
            activityVC.popoverPresentationController.sourceRect = CGRectMake(self.rightView.bounds.origin.x + (self.rightView.bounds.size.width)/3*2 + 10, CGRectGetMaxY(self.rightView.bounds), 1, 1);
        }
        [self presentViewController:activityVC animated:YES completion:nil];
        activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

            if (completed) {
                NSLog(@"Success!");
            } else {
                NSLog(@"Failed Or Canceled!");
            }
        };
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls{
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if(fileUrlAuthozied){
        if (self.pdfListView.isEditing) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if(self.pdfListView.isEdited)
                    [self.pdfListView commitEditing];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pdfListView endOfEditing];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        if(self.pdfListView.document.isModified)
                            [self.pdfListView.document writeToURL:self.pdfListView.document.documentURL];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self openFileWithUrls:urls];
                        });
                    });
                });
            });
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if(self.pdfListView.document.isModified) {
                    [self.pdfListView.document writeToURL:self.pdfListView.document.documentURL];
                }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self openFileWithUrls:urls];
                    });
                
            });
        }
        
    }
}

- (void)openFileWithUrls:(NSArray<NSURL *> *)urls {
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
    NSError *error;
    [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
        
        NSString *documentFolder = [NSHomeDirectory() stringByAppendingFormat:@"/%@/%@", @"Documents",@"Files"];

        if (![[NSFileManager defaultManager] fileExistsAtPath:documentFolder])
            [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:documentFolder] withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString * documentPath = [documentFolder stringByAppendingPathComponent:[newURL lastPathComponent]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
           [[NSFileManager defaultManager] copyItemAtPath:newURL.path toPath:documentPath error:NULL];

        }
        NSURL *url = [NSURL fileURLWithPath:documentPath];
        CPDFDocument *document = [[CPDFDocument alloc] initWithURL:url];
        self.filePath = documentPath;
        
        if (document.error && document.error.code != CPDFDocumentPasswordError) {
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:NSLocalizedString(@"Sorry PDF Reader Can't open this pdf file!", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:okAction];
            UIViewController *tRootViewControl = [UIApplication sharedApplication].keyWindow.rootViewController;
            if ([tRootViewControl presentedViewController]) {
                tRootViewControl = [tRootViewControl presentedViewController];
            }
            [tRootViewControl presentViewController:alert animated:YES completion:nil];
        } else {
            if([document isLocked]) {
                CDocumentPasswordViewController *documentPasswordVC = [[CDocumentPasswordViewController alloc] initWithDocument:document];
                documentPasswordVC.delegate = self;
                documentPasswordVC.modalPresentationStyle = UIModalPresentationFullScreen;
                
                UIViewController *tRootViewControl = [UIApplication sharedApplication].keyWindow.rootViewController;
                if ([tRootViewControl presentedViewController]) {
                    tRootViewControl = [tRootViewControl presentedViewController];
                }
                [tRootViewControl presentViewController:documentPasswordVC animated:YES completion:nil];
            } else {
                [self.pdfListView updateActiveAnnotations:[NSMutableArray array]];
                self.pdfListView.document = document;
                [self.pdfListView registerAsObserver];
                [self selectDocumentRefresh];
                [self setTitleRefresh];
            }
            
        }
        
    }];
    [urls.firstObject stopAccessingSecurityScopedResource];

}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
}

#pragma mark - CDocumentPasswordViewControllerDelegate

- (void)documentPasswordViewControllerOpen:(CDocumentPasswordViewController *)documentPasswordViewController document:(nonnull CPDFDocument *)document {
    self.pdfListView.document = document;
    [self selectDocumentRefresh];
    [self setTitleRefresh];
}

@end
