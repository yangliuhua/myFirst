//
//  CPDFListViewAnnotationConfig.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFListViewAnnotationConfig.h"

#import <ComPDFKit/ComPDFKit.h>
@implementation CPDFListViewAnnotationConfig

+ (void)initializeAnnotationConfig {
    NSURL *initialUserDefaultsURL = [[NSBundle bundleForClass:self.class] URLForResource:@"AnnotationUserDefaults" withExtension:@"plist"];
    NSDictionary *initialUserDefaultsDict = [NSDictionary dictionaryWithContentsOfURL:initialUserDefaultsURL];
    NSDictionary *initialValuesDict = [initialUserDefaultsDict objectForKey:@"RegisteredDefaults"];
    
    if(![[NSUserDefaults standardUserDefaults] floatForKey:@"CInkNoteLineWidth"]) 
        [[CPDFKitConfig sharedInstance] setFreehandAnnotationBorderWidth:10.0];

    // set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:initialValuesDict];
}

@end
