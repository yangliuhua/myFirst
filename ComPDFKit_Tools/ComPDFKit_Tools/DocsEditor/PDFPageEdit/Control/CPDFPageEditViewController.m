//
//  CPDFPageEditViewController.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFPageEditViewController.h"
#import "UIViewController+LeftItem.h"
#import "CPDFColorUtils.h"
#import "CPDFPageEditViewCell.h"
#import "CPageEditToolBar.h"
#import "CBlankPageModel.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFPageEditViewController () <CPageEditToolBarDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UIButton *doneBtn;

@property (nonatomic, strong) UIButton *selectAllBtn;

@property (nonatomic, strong) UIButton *editBtn;

@property (nonatomic, strong) CPageEditToolBar *pageEditToolBar;

@property (nonatomic, assign) BOOL isSelecAll;

@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, assign) BOOL isPageEdit;

@property (nonatomic, strong) CPDFPage *currentPage;

@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation CPDFPageEditViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.headerView = [[UIView alloc] init];
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    self.titleLabel.text =  NSLocalizedString(@"Page Edit", nil);
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 65, 120, 50);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.backBtn setImage:[UIImage imageNamed:@"CPDFPageEitImageBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.navigationItem.titleView = self.titleLabel;
    
    [self.headerView addSubview:self.titleLabel];
    [self.headerView addSubview:self.backBtn];
    
    self.editBtn = [[UIButton alloc] init];
    self.editBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.editBtn setImage:[UIImage imageNamed:@"CPDFPageEitImageEdit" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.editBtn addTarget:self action:@selector(buttonItemClicked_edit:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.editBtn];
    
    self.isEdit = NO;
    
    [self.collectionView registerClass:[CPDFPageEditViewCell class] forCellWithReuseIdentifier:@"pageEditCell"];
    self.collectionView.userInteractionEnabled = YES;
    self.collectionView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    [self.view addSubview:self.collectionView];
        
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneBtn setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(buttonItemClicked_done:) forControlEvents:UIControlEventTouchUpInside];
    [self.doneBtn setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.headerView addSubview:self.doneBtn];
    
    self.selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectAllBtn setImage:[UIImage imageNamed:@"CPDFPageEitImageSelectAll" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.selectAllBtn addTarget:self action:@selector(buttonItemClicked_selectAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.selectAllBtn];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.collectionView addGestureRecognizer:longPress];
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    self.pageEditToolBar.hidden = YES;
    self.doneBtn.hidden = YES;
    self.selectAllBtn.hidden = YES;
    self.isPageEdit = NO;
    
    self.currentPage = [self.pdfView.document pageAtIndex:self.pdfView.currentPageIndex];
}

- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
    CGFloat height = 50.0;
    if (@available(iOS 11.0, *))
        height += self.view.safeAreaInsets.bottom;
    self.pageEditToolBar.frame = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height);
    if (@available(iOS 11.0, *)) {
        self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.safeAreaInsets.top + 50);
        self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, self.view.safeAreaInsets.top, 120, 50);
        if (self.isEdit) {
            self.collectionView.frame = CGRectMake(self.view.safeAreaInsets.left, self.view.safeAreaInsets.top + 60, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height - 110 - self.view.safeAreaInsets.top-self.view.safeAreaInsets.bottom);
        } else {
            self.collectionView.frame = CGRectMake(self.view.safeAreaInsets.left, self.view.safeAreaInsets.top + 60, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height - 60 - self.view.safeAreaInsets.top-self.view.safeAreaInsets.bottom);
        }
        
        self.backBtn.frame = CGRectMake(self.view.safeAreaInsets.left, self.view.safeAreaInsets.top, 50, 50);
        self.editBtn.frame = CGRectMake(self.view.frame.size.width - self.view.safeAreaInsets.right - 70, self.view.safeAreaInsets.top, 50, 50);
        self.doneBtn.frame = CGRectMake(self.view.frame.size.width - self.view.safeAreaInsets.right - 70, self.view.safeAreaInsets.top, 50, 50);
        self.selectAllBtn.frame = CGRectMake(self.view.frame.size.width - self.view.safeAreaInsets.right - 130, self.view.safeAreaInsets.top, 50, 50);
    } else {
        self.headerView.frame = CGRectMake(0, 5, self.view.frame.size.width, 50);
        self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
        if (self.isEdit) {
            self.collectionView.frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height - 110);
        } else {
            self.collectionView.frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height - 50);
        }
        self.backBtn.frame = CGRectMake(20, 5, 50, 50);
        self.editBtn.frame = CGRectMake(self.view.frame.size.width - 70, 5, 50, 50);
        self.doneBtn.frame = CGRectMake(self.view.frame.size.width - 70, 0, 50, 50);
        self.selectAllBtn.frame = CGRectMake(self.view.frame.size.width - 120, 0, 50, 50);
    }
}

#pragma mark - Action

- (void)beginEdit {
    [self buttonItemClicked_edit:self.editBtn];
}

- (void)buttonItemClicked_edit:(UIButton *)button {
    self.isEdit = YES;
    self.editBtn.hidden = YES;
    self.isSelecAll = NO;
    
    self.pageEditToolBar = [[CPageEditToolBar alloc] init];
    self.pageEditToolBar.pdfView = self.pdfView;
    self.pageEditToolBar.currentPageIndex = -1;
    self.pageEditToolBar.delegate = self;
    self.pageEditToolBar.currentPageIndex = 1;
    [self.view addSubview:self.pageEditToolBar];
    
    self.pageEditToolBar.hidden = NO;
    self.doneBtn.hidden = NO;
    self.selectAllBtn.hidden = NO;
    
    if (self.isEdit) {
        self.collectionView.allowsMultipleSelection = YES;
    } else {
        self.collectionView.allowsMultipleSelection = NO;
    }
    
    [self.collectionView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.pdfView.currentPageIndex inSection:0];
    [self.collectionView selectItemAtIndexPath:indexPath
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    [self updateTitle];
    [self viewWillLayoutSubviews];
}

- (void)buttonItemClicked_done:(UIButton *)button {
    self.isEdit = NO;
    self.editBtn.hidden = NO;
    
    self.pageEditToolBar.hidden = YES;
    self.doneBtn.hidden = YES;
    self.selectAllBtn.hidden = YES;
    
    if (self.isEdit) {
        self.collectionView.allowsMultipleSelection = YES;
    } else {
        self.collectionView.allowsMultipleSelection = NO;
    }
    
    [self.collectionView reloadData];

    self.pageIndex = [self.pdfView.document indexForPage:self.currentPage];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.pageIndex inSection:0];

    [self.collectionView selectItemAtIndexPath:indexPath
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    
    [self updateTitle];
    [self viewWillLayoutSubviews];
}

- (void)buttonItemClicked_back:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.isPageEdit) {
            [self.pdfView.document writeToURL:self.pdfView.document.documentURL];
            [self.pdfView goToPageIndex:self.pageIndex animated:NO];
            if (self.pageEditDelegate && [self.pageEditDelegate respondsToSelector:@selector(pageEditViewControllerDone:)]) {
                [self.pageEditDelegate pageEditViewControllerDone:self];
            }
        }
    }];
}

- (void)buttonItemClicked_selectAll:(UIButton *)button {
    self.isSelecAll = !self.isSelecAll;
    if (self.isSelecAll) {
        [self.selectAllBtn setImage:[UIImage imageNamed:@"CPDFPageEitImageSelectNoAll" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    } else {
        [self.selectAllBtn setImage:[UIImage imageNamed:@"CPDFPageEitImageSelectAll" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    }
    
    if (self.isSelecAll) {
        for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
            for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
        }
    } else {
        for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
            for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            }
        }
    }
    [self updateTitle];
}

#pragma mark - Private Methods

- (void)updateTitle {
    if (self.isEdit) {
        NSInteger count = [self.collectionView indexPathsForSelectedItems].count;
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %ld",NSLocalizedString(@"Selected:", nil), (long)count];
        self.pageEditToolBar.isSelect = [self getIsSelect];
        self.pageEditToolBar.currentPageIndex = [self getMaxSelectIndex];
    } else {
        self.titleLabel.text = NSLocalizedString(@"Page Edit", nil);
    }
}

- (NSInteger)getMinSelectIndex {
    NSInteger min = self.pdfView.document.pageCount;
    
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
        if (indexPath.item < min) {
            min = indexPath.item;
        }
    }
    return min;
}

- (NSInteger)getMaxSelectIndex {
    NSInteger max = -1;
    
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
        if (indexPath.item > max) {
            max = indexPath.item;
        }
    }
    return max+1;
}

- (BOOL)getIsSelect {
    if ([self.collectionView indexPathsForSelectedItems].count > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)refreshPageIndex {
   NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        CPDFPageEditViewCell *cell = (CPDFPageEditViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"%lu", i+1];
    }
}

- (NSString *)fileNameWithSelectedPages {
    NSArray * selectPages = [self selectedPages];
    NSString *fileName = nil;
    if (selectPages.count > 0) {
        if (selectPages.count == 1) {
            NSInteger idx = [self.pdfView.document indexForPage:selectPages.firstObject] + 1;
            return [NSString stringWithFormat:@"%ld",idx];
        }
        
        NSMutableSet *sortIndex = [NSMutableSet set];
        for (CPDFPage * page in selectPages) {
            NSInteger idx = [self.pdfView.document indexForPage:page] + 1;
            [sortIndex addObject:@(idx)];
        }
        NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        NSArray *sortDesc = @[sort];
        NSArray *sortArray = [sortIndex sortedArrayUsingDescriptors:sortDesc];
        
        NSInteger a = 0;
        NSInteger b = 0;
        
        for (NSNumber *num in sortArray) {
            if (fileName) {
                if (num.integerValue == b+1) {
                    b = num.integerValue;
                    if (num == sortArray.lastObject) {
                        fileName = [fileName stringByAppendingString:[NSString stringWithFormat:@"%ld-%ld",a,b]];
                    }
                } else {
                    if (a == b) {
                        fileName = [fileName stringByAppendingString:[NSString stringWithFormat:@"%ld,",a]];
                    } else {
                        fileName = [fileName stringByAppendingString:[NSString stringWithFormat:@"%ld-%ld,",a,b]];
                    }
                    a = b = num.integerValue;
                    if (num == sortArray.lastObject) {
                        fileName = [fileName stringByAppendingString:[NSString stringWithFormat:@"%ld",a]];
                    }
                }
            } else {
                fileName = @"";
                a = b = num.integerValue;
            }
        }
        return fileName;
    }
    return @"";
}

- (NSArray<CPDFPage *> *)selectedPages {
    NSMutableArray *pages = [NSMutableArray array];
    [[self.collectionView indexPathsForSelectedItems] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < self.pdfView.document.pageCount) {
            [pages addObject:[self.pdfView.document pageAtIndex:obj.item]];
        }
    }];
    return pages;
}

#pragma mark - GestureRecognized

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:self.collectionView]];
            if (indexPath == nil) {
                break;
            }
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            [UIView animateWithDuration:0.2 animations:^{
                [self.collectionView updateInteractiveMovementTargetPosition:[gestureRecognizer locationInView:self.collectionView]];
            }];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self.collectionView updateInteractiveMovementTargetPosition:[gestureRecognizer locationInView:self.collectionView]];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.collectionView endInteractiveMovement];
            [self refreshPageIndex];
        }
            break;
        default:
        {
            [self.collectionView cancelInteractiveMovement];
        }
            break;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pdfView.document.pageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPDFPageEditViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"pageEditCell" forIndexPath:indexPath];
    CPDFPage *page = [self.pdfView.document pageAtIndex:indexPath.item];
    CGSize pageSize = [self.pdfView.document pageSizeAtIndex:indexPath.item];
    CGFloat multiple = MAX(pageSize.width / 110, pageSize.height / 173);
    
    cell.imageSize = CGSizeMake(pageSize.width / multiple, pageSize.height / multiple);
    [cell setNeedsLayout];
    cell.imageView.image = [page thumbnailOfSize:CGSizeMake(pageSize.width / multiple, pageSize.height / multiple)];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",@(indexPath.item+1)];
    [cell setEdit:self.isEdit];
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    if (sourceIndexPath.item != destinationIndexPath.item) {
        [self.pdfView.document movePageAtIndex:sourceIndexPath.item withPageAtIndex:destinationIndexPath.item];
        self.isPageEdit = YES;
        [self updateTitle];
    }
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEdit) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        self.pageEditToolBar.currentPageIndex = indexPath.item;
        self.pageEditToolBar.isSelect = [self getIsSelect];
        [self updateTitle];
        [cell setSelected:YES];
    } else {
        if (self.isPageEdit) {
            [self.pdfView.document writeToURL:self.pdfView.document.documentURL];
        }

        if(self.pageEditDelegate && [self.pageEditDelegate respondsToSelector:@selector(pageEditViewController:pageIndex:isPageEdit:)]) {
            [self.pageEditDelegate pageEditViewController:self pageIndex:indexPath.item isPageEdit:self.isPageEdit];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self updateTitle];
    [cell setSelected:NO];
}

#pragma mark - CPageEditToolBarDelegate

- (void)pageEditToolBarBlankPageInsert:(CPageEditToolBar *)pageEditToolBar pageModel:(CBlankPageModel *)pageModel {
    CGSize size = pageModel.size;
    
    if (pageModel.rotation == 1) {
        size = CGSizeMake(pageModel.size.height, pageModel.size.width);
    }
    
    NSInteger pageIndex = pageModel.pageIndex;
    if (pageModel.pageIndex == -2) {
        pageIndex = self.pdfView.document.pageCount;
    }
    
    [self.pdfView.document insertPage:size atIndex:pageIndex];
    [self.collectionView reloadData];
    [self.pageEditToolBar reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:pageIndex inSection:0];
    [self.collectionView selectItemAtIndexPath:indexPath
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    [self updateTitle];
    self.isPageEdit = YES;
}

- (void)pageEditToolBarPDFInsert:(CPageEditToolBar *)pageEditToolBar pageModel:(CBlankPageModel *)pageModel document:(nonnull CPDFDocument *)document {
    [self.pdfView.document importPages:pageModel.indexSet fromDocument:document atIndex:pageModel.pageIndex];
    [self.collectionView reloadData];
    
    for (int i = 0; i < pageModel.indexSet.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i+pageModel.pageIndex inSection:0];
        [self.collectionView selectItemAtIndexPath:indexPath
                                          animated:NO
                                    scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    }
    [self updateTitle];
    self.isPageEdit = YES;
}

- (void)pageEditToolBarExtract:(CPageEditToolBar *)pageEditToolBar {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = self.pdfView.document.documentURL.lastPathComponent.stringByDeletingPathExtension;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@_%@.pdf",path,fileName,[self fileNameWithSelectedPages]];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
        [indexSet addIndex:indexPath.item];
    }
    
    CPDFDocument *document = [[CPDFDocument alloc] init];
    [document importPages:indexSet fromDocument:self.pdfView.document atIndex:0];
    [document writeToURL:[NSURL fileURLWithPath:filePath]];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:@[[NSURL fileURLWithPath:filePath]] applicationActivities:nil];
        activityVC.definesPresentationContext = YES;
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        activityVC.popoverPresentationController.sourceView = (UIButton *)self.pageEditToolBar.pageEditBtns[2];
        activityVC.popoverPresentationController.sourceRect = ((UIButton *)self.pageEditToolBar.pageEditBtns[2]).bounds;
    }
    [self presentViewController:activityVC animated:YES completion:nil];
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

        if (completed) {
            NSLog(@"Success!");
        } else {
            NSLog(@"Failed Or Canceled!");
        }
    };

    [self.pageEditToolBar reloadData];
    
    self.isPageEdit = YES;
    [self updateTitle];
}

- (void)pageEditToolBarRotate:(CPageEditToolBar *)pageEditToolBar {
    NSArray<NSIndexPath *> *indexPathsForSelectedItems = [self.collectionView indexPathsForSelectedItems];
    for (NSIndexPath *indexPath in indexPathsForSelectedItems) {
        CPDFPage *pPage = [self.pdfView.document pageAtIndex:indexPath.item];
        pPage.rotation += 90;
        if (pPage.rotation == 360) {
            pPage.rotation = 0;
        }
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    [self updateTitle];
    [self.pageEditToolBar reloadData];
    self.isPageEdit = YES;
}

- (void)pageEditToolBarDelete:(CPageEditToolBar *)pageEditToolBar {
    NSInteger selectedCount = [self.collectionView indexPathsForSelectedItems].count;
    NSInteger totalCount = [self.collectionView numberOfItemsInSection:0];
    if (selectedCount == totalCount) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil)
                                                                       message:NSLocalizedString(@"Can not delete all pages.", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
        [indexSet addIndex:indexPath.item];
    }
    
    [self.pdfView.document removePageAtIndexSet:indexSet];
    [self.collectionView deleteItemsAtIndexPaths:[self.collectionView indexPathsForSelectedItems]];
    [self.pageEditToolBar reloadData];
    
    [self updateTitle];
    self.isPageEdit = YES;
}

- (void)pageEditToolBarReplace:(CPageEditToolBar *)pageEditToolBar document:(CPDFDocument *)document {
    NSInteger min = [self getMinSelectIndex];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (int i = 0; i < document.pageCount; i++) {
        [indexSet addIndex:i];
    }
    
    NSMutableIndexSet *deleteIndexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
        [deleteIndexSet addIndex:indexPath.item];
    }
    
    [self.pdfView.document removePageAtIndexSet:deleteIndexSet];
    [self.collectionView deleteItemsAtIndexPaths:[self.collectionView indexPathsForSelectedItems]];
    
    [self.pdfView.document importPages:indexSet fromDocument:document atIndex:min];
    [self.collectionView reloadData];
    [self.pageEditToolBar reloadData];
    
    for (int i = 0; i < document.pageCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i+min inSection:0];
        [self.collectionView selectItemAtIndexPath:indexPath
                                          animated:NO
                                    scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    }
    
    [self updateTitle];
    self.isPageEdit = YES;
}

- (void)pageEditToolBarCopy:(CPageEditToolBar *)pageEditToolBar {
    NSInteger max = [self getMaxSelectIndex];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
        [indexSet addIndex:indexPath.item];
    }
    
    CPDFDocument *document = [[CPDFDocument alloc] init];
    [document importPages:indexSet fromDocument:self.pdfView.document atIndex:0];
    
    NSMutableIndexSet *indexSetCopy = [NSMutableIndexSet indexSet];
    for (int i = 0; i < document.pageCount; i++) {
        [indexSet addIndex:i];
    }
    
    [self.pdfView.document importPages:indexSetCopy fromDocument:document atIndex:max];
    [self.collectionView reloadData];
    [self.pageEditToolBar reloadData];
    
    for (int i = 0; i < document.pageCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i+max inSection:0];
        [self.collectionView selectItemAtIndexPath:indexPath
                                          animated:NO
                                    scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    }
    
    [self updateTitle];
    self.isPageEdit = YES;
}

@end
