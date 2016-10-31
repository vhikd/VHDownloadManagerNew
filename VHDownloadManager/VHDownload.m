//
//  VHDownload.m
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/10/30.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import "VHDownload.h"

#import "AppDelegate.h"


@interface VHDownload () <NSURLSessionDelegate>{
    
    
    NSString        *strRequestURL;        //request url in NSString
    VHRequestRange  *requestRange;         //request range
    
    NSString        *fileName;             //download file name
    
    NSMutableURLRequest *urlRequest;
}

/**
 *  download task
 */
@property (nonatomic, strong) NSURLSessionDownloadTask* downloadTask;
/**
 *  record downloaded data
 */
@property (nonatomic, strong) NSData* resumeData;
/**
 *  session
 */
@property (nonatomic, strong) NSURLSession* session;

@end


@implementation VHDownload

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    
    if (error) {
        NSLog(@"NSURLSessionTaskDelegate finish with error %@",error.description);
        
        NSData* resume_data = error.userInfo[NSURLSessionDownloadTaskResumeData];
        [self.downloadTask cancel];
        self.downloadTask = nil;
        if (resume_data) {
            self.downloadTask = [self.session downloadTaskWithResumeData:resume_data];
        }
        else {
            self.downloadTask = [self.session downloadTaskWithRequest:urlRequest];
//            [self.downloadTask resume];
        }
        [self.downloadTask resume];
    }
    
}

#pragma mark - NSURLSessionDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    
    NSLog(@"NSURLSessionDelegate finish with error %@",error.description);
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    if (!self.isTest) {
        NSString *path = [FILEPATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%02td",
                                                                   fileName,self.index]];
        
        [[NSFileManager defaultManager] moveItemAtURL:location
                                                toURL:[NSURL fileURLWithPath:path]
                                                error:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(download:didFinishDownload:)]) {
            [self.delegate download:self didFinishDownload:path];
        }
    }
    
    
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (!fileName) {
        
        //only exectue first time
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)self.downloadTask.response;
        fileName = [self URLDecodedString:resp.suggestedFilename];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(download:didStart:)]) {
            [self.delegate download:self didStart:(NSHTTPURLResponse *)self.downloadTask.response];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(download:didWriteData:andTotalData:)]) {
        [self.delegate download:self didWriteData:bytesWritten andTotalData:totalBytesExpectedToWrite];
    }
    
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    
    
}

#pragma mark - Private Method

-(NSString *)URLDecodedString:(NSString *)str
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return decodedString;
}

#pragma mark - Public Method

+ (VHDownload *)startDownloadWithUrl:(NSString *)surl andRange:(VHRequestRange *)range {
    
    VHDownload *download = [[self alloc] init];
    [download startWithUrl:surl andRange:range];
    download.isTest = NO;
    return download;
}

- (void)startWithUrl:(NSString *)surl andRange:(VHRequestRange *)range {
    
    strRequestURL = [NSString stringWithString:surl];
    requestRange = [[VHRequestRange alloc] initWithLocation:range.location
                                                  andLength:range.length];
}

- (void)startDownload {
    
    NSURL* url = [NSURL URLWithString:strRequestURL];
    urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSString *str_range = [NSString stringWithFormat:@"bytes=%llu-%llu",
                           requestRange.location,
                           requestRange.location+requestRange.length];
    NSString *ua = @"netdisk;6.12.3;iPhone 6Plus;ios-iphone;10.0.2;zh_CN";
    
    [urlRequest setValue:@"close" forHTTPHeaderField:@"Connection"];
    [urlRequest setValue:@"X-Download-From" forHTTPHeaderField:@"baiduyun"];
    [urlRequest setValue:ua forHTTPHeaderField:@"User-Agent"];
    [urlRequest setValue:@"close" forHTTPHeaderField:@"Proxy-Connection"];
    [urlRequest setValue:str_range forHTTPHeaderField:@"Range"];
    [urlRequest setTimeoutInterval:1000];
    
    
    
    self.downloadTask = [self.session downloadTaskWithRequest:urlRequest];
    
    [self.downloadTask resume];
    
    
}


#pragma mark - Initinal

/**
 *  session lazy load
 */
- (NSURLSession *)session
{
    if (nil == _session) {

        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        
        
        if (!self.isTest) {

            NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
            NSString *sid = [NSString stringWithFormat:@"%@.%@.%d",identifier,fileName,self.index];
            cfg = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:sid];
//            cfg.HTTPMaximumConnectionsPerHost = 5;
        }
        
        
        self.session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    }
    return _session;
}














@end
