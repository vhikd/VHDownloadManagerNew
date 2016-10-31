//
//  VHDownloadManager.h
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/10/30.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VHDownloadManagerDelegate ;

@interface VHDownloadManager : NSObject


/*
 * max download thread
 */

@property (assign) NSInteger maxDownloadThread;

/*
 * download manager delegate
 */

@property (nonatomic, strong) id<VHDownloadManagerDelegate> delegate;


- (id)initWithDownloadUrl:(NSString *)surl;

- (void)startDownload;

@end


@protocol VHDownloadManagerDelegate <NSObject>

- (void)didStartDownloadWithFileName:(NSString *)file_name andTotalSize:(unsigned long long)size;
- (void)didLoadData:(unsigned long long)size andProgress:(double)progress;
- (void)didFinishLoadInDirectory:(NSString *)path;

@end


