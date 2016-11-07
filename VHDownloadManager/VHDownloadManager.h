//
//  VHDownloadManager.h
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/10/30.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

/*
 * tag
 */
@property (assign) NSInteger tag;

/*
 * download progress
 */
@property (assign) CGFloat dProgress;

/*
 * total size in bytes
 */
@property (assign) unsigned long long dTotalSize;


- (id)initWithDownloadUrl:(NSString *)surl andDownloadPath:(NSString *)path;

- (void)startDownload;
- (void)stopDownload;

- (NSString *)getFileName;
- (NSString *)getAveSpeed;

//- (void)testUnzip;

@end


@protocol VHDownloadManagerDelegate <NSObject>

@optional

/*
 * start download
 * file_name : download file name
 */
- (void)downloadManager:(VHDownloadManager *)manager didStartDownload:(NSString *)file_name;

/*
 * size : the length of load data at this time
 */
- (void)downloadManager:(VHDownloadManager *)manager didLoadData:(unsigned long long)size;

/*
 * path : downloaded file path
 */
- (void)downloadManager:(VHDownloadManager *)manager didFinishLoadInDirectory:(NSString *)path;

/*
 * path : downloaded and unzip files with path array
 */
- (void)downloadManager:(VHDownloadManager *)manager didFinishLoadAndUnZipInDirectory:(NSArray *)paths;

/*
 * start download
 * file_name : download file name
 * size : total size to download
 */
- (void)didStartDownloadWithFileName:(NSString *)file_name andTotalSize:(unsigned long long)size;

/*
 * receive data
 * progress : download progress
 * size : the length of load data at this time
 */
- (void)didLoadData:(unsigned long long)size andProgress:(double)progress;

/*
 * finish download
 * path : download file path , you can manage the file as you can. Such as decompress or move it to another path and so on.
 */
- (void)didFinishLoadInDirectory:(NSString *)path;

@end


