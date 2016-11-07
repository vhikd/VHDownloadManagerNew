//
//  VHDownloadUnArchive.h
//  MusicProjMac
//
//  Created by 刁志远 on 2016/11/5.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VHDownloadUnArchive : NSObject

- (void)unarchiveWithZipFile:(NSString *)zip_path andDesPath:(NSString *)des_path;
- (NSArray *)getUnzipFile;

@end
