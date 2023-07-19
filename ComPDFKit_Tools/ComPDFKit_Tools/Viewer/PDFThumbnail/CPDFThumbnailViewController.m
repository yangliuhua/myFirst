//
//  PDFThumbnailViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFThumbnailViewController.h"
#import "CPDFThumbnailViewCell.h"
#import "UIViewController+LeftItem.h"
#import "CPDFColorUtils.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFThumbnailViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation CPDFThumbnailViewController

#pragma mark - Initializers

- (instancetype)initWithPDFView:(CPDFView *)pdfView {
    if (self = [super init]) {
        _pdfView = pdfView;
    }
    return self;
}

#pragma mark - Accessors

#pragma mark - UIViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self changeleftItem];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(110, 185);
    layout.sectionInset = UIEdgeInsetsMake(10, 5, 5, 5);
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[CPDFThumbnailViewCell class] forCellWithReuseIdentifier:@"thumnailCell"];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor colorWithRed:0.804 green:0.804 blue:0.804 alpha:1];
    
    [self.view addSubview:self.collectionView];
    
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
  
    self.titleLabel.text =  NSLocalizedString(@"Thumbnails", nil);
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [CPDFColorUtils CAnyReverseBackgooundColor];
    [self.view addSubview:self.titleLabel];
    
    self.backBtn = [[UIButton alloc] init];
    self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.backBtn setImage:[UIImage imageNamed:@"CPDFEditClose" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
}

- (void)buttonItemClicked_back:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat mWidth = fmin(width, height);
    CGFloat mHeight = fmax(width, height);
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width,traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.9 : mHeight*0.9);

}

- (void)viewWillLayoutSubviews {
    
    if (@available(iOS 11.0, *)) {
        self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
        self.collectionView.frame = CGRectMake(self.view.safeAreaInsets.left, self.view.safeAreaInsets.top + 50, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height - 50 - self.view.safeAreaInsets.top);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
        
    } else {
        self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
        self.collectionView.frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height - 50);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];

    if(self.pdfView.document) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.pdfView.currentPageIndex inSection:0];
        [self.collectionView selectItemAtIndexPath:indexPath
                                          animated:NO
                                    scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if(self.pdfView.document) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.pdfView.currentPageIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                            animated:NO];
    }
}

#pragma mark - Class method

- (void)setCollectViewSize:(CGSize)size {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = size;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    self.collectionView.collectionViewLayout = layout;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pdfView.document.pageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPDFThumbnailViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumnailCell" forIndexPath:indexPath];
    CPDFPage *page = [self.pdfView.document pageAtIndex:indexPath.item];
    CGSize pageSize = [self.pdfView.document pageSizeAtIndex:indexPath.item];
    CGFloat multiple = MAX(pageSize.width / 110, pageSize.height / 173);
    cell.imageSize = CGSizeMake(pageSize.width / multiple, pageSize.height / multiple);
    [cell setNeedsLayout];
    cell.imageView.image = [page thumbnailOfSize:CGSizeMake(pageSize.width / multiple, pageSize.height / multiple)];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",@(indexPath.item+1)];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if([self.delegate respondsToSelector:@selector(thumbnailViewController:pageIndex:)]) {
        [self.delegate thumbnailViewController:self pageIndex:indexPath.row];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

@end
