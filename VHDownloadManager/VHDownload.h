//
//  VHDownload.h
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/10/30.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol VHDownloadDelegate ;

#import "VHRequestRange.h"

@interface VHDownload : NSObject


/***
 *  request index
 ***
 */
@property (assign) NSUInteger index;

/***
 *  download delegate
 ***
 */

@property (nonatomic, strong) id<VHDownloadDelegate> delegate;

/*
 * download test info
 */

@property (assign) BOOL isTest;



+ (VHDownload *)startDownloadWithUrl:(NSString *)surl andRange:(VHRequestRange *)range;

- (void)startDownload;

@end



@protocol VHDownloadDelegate <NSObject>

//download did start
- (void)download:(VHDownload *)download didStart:(NSHTTPURLResponse *)response;

//download write data
- (void)download:(VHDownload *)download didWriteData:(unsigned long long)length andTotalData:(unsigned long long)total;

//download finish
- (void)download:(VHDownload *)download didFinishDownload:(NSString *)location;

@end









