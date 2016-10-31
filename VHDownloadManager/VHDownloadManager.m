//
//  VHDownloadManager.m
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/10/30.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import "VHDownloadManager.h"

#import "VHDownload.h"

@interface VHDownloadManager () <VHDownloadDelegate>{
    
    NSString *strRequestUrl;
    NSString *fileName;
    
    unsigned long long downloadedSize;
    //    unsigned long long totalSize;
    
    NSMutableArray *arrDownload;
    NSMutableDictionary *downloadPath;
    
    NSString *desFilePath;
}

@end


@implementation VHDownloadManager


#pragma mark - VHDownloadDelegate

//download did start
- (void)download:(VHDownload *)download didStart:(NSHTTPURLResponse *)response{
    
    
    if (download.isTest) {
        
        if (response.statusCode == 206 && !fileName) {//can be split
            
            fileName = [self URLDecodedString:response.suggestedFilename];
            
            NSString *str = response.allHeaderFields[@"Content-Range"];
            NSRange ran = [str rangeOfString:@"/"];
            self.dTotalSize = [[str substringFromIndex:ran.location+1] longLongValue];
            downloadedSize = 0;
            
            [self splitDownload];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didStartDownloadWithFileName:andTotalSize:)]) {
                
                [self.delegate didStartDownloadWithFileName:fileName
                                               andTotalSize:_dTotalSize];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadManager:didStartDownload:)]) {
                
                [self.delegate downloadManager:self didStartDownload:fileName];
            }
        }
        return;
    }
    
    
    
}

//download write data
- (void)download:(VHDownload *)download didWriteData:(unsigned long long)length andTotalData:(unsigned long long)total{
    
    if (!download.isTest) {
        downloadedSize+=length;
        //        if(totalSize != total)
        //            totalSize = total;
        
        _dProgress = (double)downloadedSize/_dTotalSize;
        if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadData:andProgress:)]) {
            [self.delegate didLoadData:length andProgress:_dProgress];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadManager:didLoadData:)]) {
            [self.delegate downloadManager:self didLoadData:downloadedSize];
        }
    }
    
}

//download finish
- (void)download:(VHDownload *)download didFinishDownload:(NSString *)location {
    
    [arrDownload removeObject:download];
    
    if (!downloadPath) {
        downloadPath = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    NSString *sk = [NSString stringWithFormat:@"%td",download.index];
    downloadPath[sk] = location;
    
    NSLog(@"download cnt : %td",arrDownload.count);
    
    if (arrDownload.count <= 0) {
        
        NSMutableData *m_data = [NSMutableData dataWithCapacity:3];
        for (int i=0; i<[[downloadPath allKeys] count]; i++) {
            NSString *sk = [NSString stringWithFormat:@"%d",i];
            NSString *file_path = downloadPath[sk];
            NSData *data = [NSData dataWithContentsOfFile:file_path];
            [m_data appendData:data];
            
            [[NSFileManager defaultManager] removeItemAtPath:file_path
                                                       error:nil];
        }
        
        NSString *des_file = [desFilePath stringByAppendingPathComponent:fileName];
        [m_data writeToFile:des_file atomically:YES];
        [m_data resetBytesInRange:NSMakeRange(0, [m_data length])];
        [m_data setLength:0];
        m_data = nil;
        
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLoadInDirectory:)]) {
            [self.delegate didFinishLoadInDirectory:des_file];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadManager:didFinishLoadInDirectory:)]) {
            [self.delegate downloadManager:self didFinishLoadInDirectory:des_file];
        }
        
    }
}


#pragma mark - Private Methods

-(NSString *)URLDecodedString:(NSString *)str
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return decodedString;
}


- (void)startAllDownload {
    
    for (int i=0; i<arrDownload.count; i++) {
        VHDownload *download = arrDownload[i];
        [download startDownload];
    }
}

- (void)splitDownload {
    
    if (!arrDownload) {
        arrDownload = [NSMutableArray arrayWithCapacity:3];
    }
    [arrDownload removeAllObjects];
    
    unsigned long long per_size = _dTotalSize/self.maxDownloadThread;
    
    for (int i=0; i<self.maxDownloadThread; i++) {
        
        VHRequestRange *ran;
        if (i== self.maxDownloadThread-1) {//最后一个
            ran = [[VHRequestRange alloc] initWithLocation:i*(per_size+1)
                                                 andLength:_dTotalSize-i*per_size];
        }
        else {
            ran = [[VHRequestRange alloc] initWithLocation:i*(per_size+1)
                                                 andLength:per_size];
        }
        
        VHDownload *down = [VHDownload startDownloadWithUrl:strRequestUrl
                                                   andRange:ran
                                                 andDesPath:desFilePath];
        down.index = i;
        down.delegate = self;
        [arrDownload addObject:down];
    }
    
    [self startAllDownload];
}


#pragma mark - Public Method

- (NSString *)getFileName {
    
    if (fileName) {
        return fileName;
    }
    
    return @"--";
}

- (void)startDownload {
    
    VHRequestRange *range = [[VHRequestRange alloc] initWithLocation:0 andLength:1024];
    VHDownload *download = [VHDownload startDownloadWithUrl:strRequestUrl
                                                   andRange:range
                                                 andDesPath:desFilePath];
    download.isTest = YES;
    download.delegate = self;
    [download startDownload];
}

#pragma mark - Initinal

- (void)initinal {
    
    self.maxDownloadThread = 10;
    
}

#pragma mark - SYS

- (id)initWithDownloadUrl:(NSString *)surl andDownloadPath:(NSString *)path {
    
    self = [super init];
    if (self) {
        _dTotalSize = 0;
        strRequestUrl = [NSString stringWithString:surl];
        desFilePath = [NSString stringWithString:path];
        [self initinal];
    }
    
    return self;
}

@end
