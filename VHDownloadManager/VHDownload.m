//
//  VHDownload.m
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/10/30.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import "VHDownload.h"

#import "AppDelegate.h"

#import <CFNetwork/CFNetwork.h>


@interface VHDownload () <NSURLSessionDelegate>{
    
    
    NSString        *strRequestURL;        //request url in NSString
    VHRequestRange  *requestRange;         //request range
    
    NSString        *fileName;             //download file name
    
    NSMutableURLRequest *urlRequest;
    NSString *desPath;
    NSString *taskID;                      //download session id
    
    BOOL  isCancel;
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
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    if([challenge.protectionSpace.authenticationMethod  isEqual: @"NSURLAuthenticationMethodServerTrust"]){
        
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge:challenge];
        
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        NSURLCredential *cre = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        // 调用block
        completionHandler(NSURLSessionAuthChallengeUseCredential,cre);
    }
    
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    
    if (task.state == NSURLSessionTaskStateCanceling) {
        return;
    }
    
    if (error && !isCancel ) {
        
        if ([task respondsToSelector:@selector(downloadFile)]) {
            
            id download_file = [task performSelector:@selector(downloadFile)];
            NSString *path = [download_file performSelector:@selector(path)];
            NSData *data = [NSData dataWithContentsOfFile:path];
            unsigned long long length = [data length];
            data = nil;
            
            NSLog(@"index : %td  -----   %lld    ----  %lld",
                  self.index,length,requestRange.length);
            
            if (length-requestRange.length <= 3 ||
                requestRange.length-length <= 3) {
                [self URLSession:self.session
                    downloadTask:_downloadTask
       didFinishDownloadingToURL:[NSURL fileURLWithPath:path]];
                
                NSLog(@"download success with error");
                
                
                return;
            }
        }
        
        NSLog(@"NSURLSessionTaskDelegate finish with error %@",error.description);
        
        NSData* resume_data = error.userInfo[NSURLSessionDownloadTaskResumeData];
        self.downloadTask = nil;
        if (resume_data) {
            _downloadTask = [self.session downloadTaskWithResumeData:resume_data];
        }
        else {
            _downloadTask = [self.session downloadTaskWithRequest:urlRequest];
        }
        [self.downloadTask performSelector:@selector(resume)
                                withObject:nil
                                afterDelay:1.0];
        resume_data = nil;
    }
    //    else {
    //        NSLog(@"-->>  complete");
    //        [session.configuration.URLCache getCachedResponseForDataTask:task
    //                                                   completionHandler:^(NSCachedURLResponse * _Nullable cachedResponse) {
    //
    //                                                   }];
    //    }
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

//- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
//
//    if (self.downloadTask.state == NSURLSessionTaskStateCanceling) {
//        return;
//    }
//    NSLog(@"index : %td ",self.index);
//    NSLog(@"NSURLSessionDelegate finish with error %@",error.description);
//}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    if (!self.isTest && !isCancel) {
        
        if (downloadTask.state == NSURLSessionTaskStateCanceling) {
            return;
        }
        
        /* some time the data we get is not the real data
         
         NSString *path = [desPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%02td",
         fileName,self.index]];
         [[NSFileManager defaultManager] moveItemAtURL:location
         toURL:[NSURL fileURLWithPath:path]
         error:nil];
         if (self.delegate && [self.delegate respondsToSelector:@selector(download:didFinishDownload:)]) {
         [self.delegate download:self didFinishDownload:path];
         }
         */
        
        /* some time the data we get is not the real data. eg. baidu.pcs*/
        //        NSData *data = [NSData dataWithContentsOfURL:location];
        NSHTTPURLResponse *rep = (NSHTTPURLResponse *)downloadTask.response;
        if ([[rep allHeaderFields][@"Content-Type"] rangeOfString:@"html"].location == NSNotFound ||
            [[rep allHeaderFields][@"Content-Type"] rangeOfString:@"txt"].location == NSNotFound ||
            [[rep allHeaderFields][@"Content-Type"] rangeOfString:@"text"].location == NSNotFound) {
            
            NSLog(@"download size - %lld  type:%@",rep.expectedContentLength,
                  [rep allHeaderFields][@"Content-Type"]);
            
            NSString *path = [desPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%02td",
                                                                      fileName,self.index]];
            [[NSFileManager defaultManager] moveItemAtURL:location
                                                    toURL:[NSURL fileURLWithPath:path]
                                                    error:nil];
            if (self.delegate && [self.delegate respondsToSelector:@selector(download:didFinishDownload:)]) {
                [self.delegate download:self didFinishDownload:path];
            }
            
            [self cancel];
        }
        else {
            //            [self.downloadTask cancel];
            
            NSLog(@"error download size - %lld  type:%@",rep.expectedContentLength,
                  [rep allHeaderFields][@"Content-Type"]);
            self.downloadTask = nil;
            self.downloadTask = [self.session downloadTaskWithRequest:urlRequest];
            [self.downloadTask performSelector:@selector(resume)
                                    withObject:nil
                                    afterDelay:1.0];
        }
        
    }
    
    
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (downloadTask.state == NSURLSessionTaskStateCanceling) {
        return;
    }
    
    if (!fileName) {
        
        //only exectue first time
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)self.downloadTask.response;
        
        const char *byte = NULL;
        byte = [resp.suggestedFilename cStringUsingEncoding:NSISOLatin1StringEncoding];
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
        NSString *tmp_name = [[NSString alloc] initWithCString:byte encoding: enc];
        
        fileName = [self URLDecodedString:tmp_name];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(download:didStart:)]) {
            [self.delegate download:self didStart:resp];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(download:didWriteData:andTotalData:)]) {
        [self.delegate download:self didWriteData:bytesWritten andTotalData:totalBytesExpectedToWrite];
    }
    
}

//
//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
// didResumeAtOffset:(int64_t)fileOffset
//expectedTotalBytes:(int64_t)expectedTotalBytes {
//
//
//
//}

#pragma mark - Private Method

-(NSString *)URLDecodedString:(NSString *)str
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return decodedString;
}

#pragma mark - Public Method

+ (VHDownload *)startDownloadWithUrl:(NSString *)surl andRange:(VHRequestRange *)range andDesPath:(NSString *)des_path andUniqueTaskID:(NSString *)task_id {
    
    VHDownload *download = [[self alloc] init];
    [download startWithUrl:surl andRange:range andPath:des_path andTaskID:task_id];
    download.isTest = NO;
    
    return download;
}

- (void)startWithUrl:(NSString *)surl andRange:(VHRequestRange *)range andPath:(NSString *)path andTaskID:(NSString *)tid{
    
    taskID = [NSString stringWithString:tid];
    desPath = [NSString stringWithString:path];
    strRequestURL = [NSString stringWithString:surl];
    requestRange = [[VHRequestRange alloc] initWithLocation:range.location
                                                  andLength:range.length];
    self.isTest = NO;
}

- (void)startDownload {
    
    isCancel = NO;
    
    if (!urlRequest) {
        NSURL* url = [NSURL URLWithString:strRequestURL];
        urlRequest = [NSMutableURLRequest requestWithURL:url];
    }
    
    
    NSString *str_range = [NSString stringWithFormat:@"bytes=%llu-%llu",
                           requestRange.location,
                           requestRange.location+requestRange.length];
    NSString *ua = @"netdisk;6.12.3;";
    
    //    [urlRequest setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    //    [urlRequest setValue:@"Close" forHTTPHeaderField:@"Connection"];
    [urlRequest setValue:@"X-Download-From" forHTTPHeaderField:@"baiduyun"];
    [urlRequest setValue:ua forHTTPHeaderField:@"User-Agent"];
    [urlRequest setValue:str_range forHTTPHeaderField:@"Range"];
    //    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setTimeoutInterval:60*5];
    
    self.downloadTask = [self.session downloadTaskWithRequest:urlRequest];
    [self.downloadTask resume];
}

- (void)setConnectionType:(NSString *)connection {
    
    if (!urlRequest) {
        NSURL* url = [NSURL URLWithString:strRequestURL];
        urlRequest = [NSMutableURLRequest requestWithURL:url];
    }
    [urlRequest setValue:connection forHTTPHeaderField:@"Connection"];
}

- (void)cancel {
    
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        for (NSURLSessionTask *_task in downloadTasks)
        {
            [_task cancel];
        }
        for (NSURLSessionTask *_task in dataTasks)
        {
            [_task cancel];
        }
        
    }];
    
    [self.downloadTask suspend];
    [[self.session delegateQueue] setSuspended:YES];
    [self.session invalidateAndCancel];
    [self.session flushWithCompletionHandler:^{
        
    }];
    isCancel = YES;
}

#pragma mark - Initinal

/**
 *  session lazy load
 */
- (NSURLSession *)session
{
    if (nil == _session) {
        
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        
#ifdef MAC_OS_X_VERSION_10_0
        
        
#else
        
#endif
        
        if (!self.isTest) {
            
            NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
            NSString *sid = [NSString stringWithFormat:@"%@.%@.%td",identifier,taskID,self.index];
            cfg = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:sid];
        }
        
        cfg.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        cfg.timeoutIntervalForRequest = 60*5;//60*60*5;
        cfg.timeoutIntervalForResource = 60*5;//60*60*5;
        cfg.HTTPMaximumConnectionsPerHost = 1024;
        
        
        self.session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
    }
    return _session;
}














@end
