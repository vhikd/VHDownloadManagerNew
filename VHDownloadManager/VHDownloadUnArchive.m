//
//  VHDownloadUnArchive.m
//  MusicProjMac
//
//  Created by 刁志远 on 2016/11/5.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import "VHDownloadUnArchive.h"

#import "XADSimpleUnarchiver.h"

@interface VHDownloadUnArchive ()  {
    
    NSMutableArray *arrUnzipFile;
}

@end

@implementation VHDownloadUnArchive


#pragma mark - XADSimpleUnarchiverDelegate

-(void)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver didExtractEntryWithDictionary:(NSDictionary *)dict to:(NSString *)path error:(XADError)error {
    
    
    if (!arrUnzipFile) {
        arrUnzipFile = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    [arrUnzipFile addObject:path];
}



#pragma mark - Public

- (NSArray *)getUnzipFile {
    
    return arrUnzipFile;
}

- (void)unarchiveWithZipFile:(NSString *)zip_path andDesPath:(NSString *)des_path {
    
    XADSimpleUnarchiver *unarchiver = [XADSimpleUnarchiver simpleUnarchiverForPath:zip_path
                                                                             error:NULL];
    unarchiver.delegate = self;
    [unarchiver setAlwaysOverwritesFiles:YES];
    [unarchiver setDestination:des_path];
    
    XADError error=[unarchiver parse];
    if(error==XADBreakError)
    {
        NSLog(@"error %d",error);
        return;
    }
    else if(error)
    {
        NSLog(@"error %d",error);
    }
    
    error=[unarchiver unarchive];
    if(error)
    {
        NSLog(@"error %d",error);
        return;
    }
    
//    [unarchiver release];
//    unarchiver = nil;
}

#pragma mark - SYS

- (void)dealloc {
    
    if (arrUnzipFile) {
        [arrUnzipFile removeAllObjects];
        [arrUnzipFile release];
        arrUnzipFile = nil;
    }
    
    [super dealloc];
}

@end
