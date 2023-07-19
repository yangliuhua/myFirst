//
//  CPDFSearchResultsViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSearchResultsViewController.h"
#import "CPDFSearchViewCell.h"

#import <ComPDFKit/ComPDFKit.h>
#import <CoreText/CoreText.h>
#import "UIViewController+LeftItem.h"
#import "CPDFColorUtils.h"

#define kTextSearch_Content_Length_Max 100

@interface CPDFSearchResultsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *resultArray;
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) CPDFDocument *document;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView * searchResultView;
@property (nonatomic, strong) UILabel * searchResultLabel;
@property (nonatomic, strong) UILabel * pageLabel;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation CPDFSearchResultsViewController

#pragma mark - Initializers

- (instancetype)initWithResultArray:(NSArray *)resultArray keyword:(NSString *) keyword document:(CPDFDocument *) document {
    if (self = [super init]) {
        _resultArray = resultArray;
        _keyword = keyword;
        _document = document;
    }
    
    return self;
}

#pragma mark - Accessors

#pragma mark - UIViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self changeleftItem];
//    self.title = NSLocalizedString(@"Search Results", nil);
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[CPDFSearchViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self.view addSubview:self.tableView];
    
    self.searchResultView = [[UIView alloc] init];
    self.searchResultLabel = [[UILabel alloc] init];
    self.pageLabel = [[UILabel alloc] init];
    
    self.searchResultView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    self.pageLabel.font = [UIFont systemFontOfSize:14];
    self.pageLabel.text = NSLocalizedString(@"Page",nil);
    self.pageLabel.textAlignment = NSTextAlignmentRight;
    self.pageLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    self.searchResultLabel.font = [UIFont systemFontOfSize:14];
    self.searchResultLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    [self.searchResultView addSubview:self.searchResultLabel];
    [self.searchResultView addSubview:self.pageLabel];
    [self.view addSubview:self.searchResultView];
    
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
  
    self.titleLabel.text =  NSLocalizedString(@"Results", nil);
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
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
    [super viewWillLayoutSubviews];
    
    if (@available(iOS 11.0, *)) {
        self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
        self.tableView.frame = CGRectMake(self.view.safeAreaInsets.left, self.view.safeAreaInsets.top +28 + 50, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height - self.view.safeAreaInsets.bottom- self.view.safeAreaInsets.top - 50);
        self.searchResultView.frame = CGRectMake(self.view.safeAreaInsets.left, self.view.safeAreaInsets.top + 50, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 28);
        self.searchResultLabel.frame = CGRectMake(70, 4, 200, 20);
        self.searchResultLabel.text = [NSString stringWithFormat:@"%zd Results",self.resultArray.count];
        self.pageLabel.frame = CGRectMake(self.view.frame.size.width - 50, 4, 40, 20);
    } else {
        self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
        self.searchResultView.frame = CGRectMake(10, 64, self.view.frame.size.width-20, 28);
        self.searchResultLabel.frame = CGRectMake(20, 4, 200, 20);
        self.searchResultLabel.text = [NSString stringWithFormat:@"%zd Results",self.resultArray.count];
        self.pageLabel.frame = CGRectMake(self.view.frame.size.width - 50, 4, 40, 20);
        self.tableView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 50 + 36, self.view.bounds.size.width, self.view.bounds.size.height - 50 - 36);
      
    }
}


#pragma mark - Button Actions

- (void)buttonItemClicked_Back:(id)sender {
    if([self.delegate respondsToSelector:@selector(searchResultsViewControllerDismiss:)])
        [self.delegate searchResultsViewControllerDismiss:self];
}

#pragma mark - Private Methods

- (NSMutableAttributedString *)getAttributedStringWithSelection:(CPDFSelection *)selection {
    CPDFPage * currentPage = selection.page;
    NSRange range = selection.range;
    NSUInteger startLocation = 0;
    NSUInteger maxLocation = 20;
    NSInteger keyLocation = 0;
    NSUInteger maxEndLocation = 80;
    if (range.location > maxLocation) {
        startLocation = range.location - maxLocation;
        keyLocation = maxLocation;
    } else {
        startLocation = 0;
        keyLocation = range.location;
    }
    NSUInteger endLocation = 0;
    if (range.location + maxEndLocation > currentPage.numberOfCharacters) {
        endLocation = currentPage.numberOfCharacters;
    } else {
        endLocation = range.location + maxEndLocation;
    }
    
    
    NSMutableAttributedString * attributed  = nil;
    if (endLocation> startLocation) {
        NSString * currentString = [currentPage stringForRange:NSMakeRange(startLocation, endLocation - startLocation)];
        
        NSRange tRange = NSMakeRange(keyLocation, self.keyword.length);
        if (tRange.location != NSNotFound) {
            attributed = [[NSMutableAttributedString alloc] initWithString:currentString];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.firstLineHeadIndent = 10.0;
            paragraphStyle.headIndent = 10.0;
            paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0],NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName,nil];
            
            NSRange range = [[attributed string] rangeOfString:[attributed string]];
            [attributed setAttributes:dic range:range];
            
            dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:102./255. green:102/255. blue:102/255. alpha:1.],NSForegroundColorAttributeName,nil];
            [attributed addAttributes:dic range:NSMakeRange(0, currentString.length)];
            
            //hightlight string
            dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:1.0 green:220.0/255.0 blue:27.0/255.0 alpha:1.0],NSBackgroundColorAttributeName,nil];
            
            if (attributed.length > tRange.length + tRange.location) {
                [attributed addAttributes:dic range:tRange];
            }
        }
    }
    return attributed;
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.resultArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = [self.resultArray objectAtIndex:section];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPDFSearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell =  [[CPDFSearchViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    CPDFSelection *selection = self.resultArray[indexPath.section][indexPath.row];
    cell.contentLabel.attributedText = [self getAttributedStringWithSelection:selection];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPDFSelection *selection = self.resultArray[indexPath.section][indexPath.row];
    NSAttributedString *attributeText = [self getAttributedStringWithSelection:selection];
    
    CGFloat cellWidth = tableView.frame.size.width;
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributeText);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(cellWidth - padding.left - padding.right, CGFLOAT_MAX), NULL);
    CGFloat cellHeight = suggestedSize.height + padding.top + padding.bottom;
    CFRelease(framesetter);
    
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *array = [self.resultArray objectAtIndex:section];
    CPDFSelection *selection = array.firstObject;
    NSInteger pageIndex = [self.document indexForPage:selection.page];
    NSString *countStr = [NSString stringWithFormat:NSLocalizedString(@"%ld",nil), (long)(pageIndex+1)];
    
    UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor colorWithRed:250./255. green:252/255. blue:255/255. alpha:1];
    
    UILabel *sublabel = [[UILabel alloc] init];
    sublabel.font = [UIFont systemFontOfSize:14];
    sublabel.text = countStr;
    sublabel.textColor = [UIColor colorWithRed:67./255. green:71.0/255.0 blue:77./255.0 alpha:1.0];
    [sublabel sizeToFit];
    sublabel.frame = CGRectMake(view.bounds.size.width-sublabel.bounds.size.width-10, 0,
                                sublabel.bounds.size.width, view.bounds.size.height);
    sublabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [view.contentView addSubview:sublabel];
    
    return view;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CPDFSelection *selection = self.resultArray[indexPath.section][indexPath.row];
    if([self.delegate respondsToSelector:@selector(searchResultsView:forSelection:indexPath:)]) {
        [self.delegate searchResultsView:self forSelection:selection indexPath:indexPath];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
