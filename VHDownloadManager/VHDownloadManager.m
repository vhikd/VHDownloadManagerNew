//
//  VHDownloadManager.m
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/10/30.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import "VHDownloadManager.h"

#import "VHDownload.h"
#import "VHDownloadUnArchive.h"


@interface VHDownloadManager () <VHDownloadDelegate>{
    
    NSString *strRequestUrl;
    NSString *fileName;
    
    unsigned long long downloadedSize;
    //    unsigned long long totalSize;
    
    NSMutableArray *arrDownload;
    NSMutableDictionary *downloadPath;
    
    NSString *desFilePath;
    
    NSString *taskID;
    
    CGFloat downloadSpeed;
    CFTimeInterval timeStart;
    
    NSString *strConnection;
}


@end


@implementation VHDownloadManager


#pragma mark - VHDownloadDelegate

//download did start
- (void)download:(VHDownload *)download didStart:(NSHTTPURLResponse *)response{
    
    
    if (download.isTest) {
        
        if (response.statusCode == 206 && !fileName) {//can be split
            
            
            strConnection = @"Close";
            
            if ([response allHeaderFields][@"Connection"]) {
                strConnection = [NSString stringWithFormat:@"%@",[response allHeaderFields][@"Connection"]];
            }
            
            const char *byte = NULL;
            byte = [response.suggestedFilename cStringUsingEncoding:NSISOLatin1StringEncoding];
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
            NSString *tmp_name = [[NSString alloc] initWithCString:byte encoding: enc];
            
            fileName = [self URLDecodedString:tmp_name];
            
            NSString *str = response.allHeaderFields[@"Content-Range"];
            NSRange ran = [str rangeOfString:@"/"];
            self.dTotalSize = [[str substringFromIndex:ran.location+1] longLongValue];
            downloadedSize = 0;
            
            [self splitDownloadWithFileUrl:response.URL.absoluteString];
            
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
        
        if (timeStart == 0) {
            timeStart = CFAbsoluteTimeGetCurrent();
        }
        
        downloadedSize+=length;
        
        _dProgress = (double)downloadedSize/_dTotalSize;
        if (_dProgress>=1.0) {
            _dProgress = 0.999;
        }
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
    
    if (!downloadPath) {
        downloadPath = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    NSInteger index = download.index;
    NSString *sk = [NSString stringWithFormat:@"%td",index];
    downloadPath[sk] = [NSString stringWithFormat:@"%@",location];
    
    [arrDownload removeObject:download];
    
    NSLog(@"download cnt : %td",arrDownload.count);
    [download cancel];
    download = nil;
    
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
        
        if ([[[fileName pathExtension] uppercaseString] isEqualToString:@"ZIP"] ||
            [[[fileName pathExtension] uppercaseString] isEqualToString:@"RAR"] ||
            [[[fileName pathExtension] uppercaseString] isEqualToString:@"7Z"] ) {//解压
            
            NSString *zip_path = [FILEPATH stringByAppendingPathComponent:fileName];
            [m_data writeToFile:zip_path atomically:YES];
            
            
            VHDownloadUnArchive *downloadUnarchive = [[VHDownloadUnArchive alloc] init];
            [downloadUnarchive unarchiveWithZipFile:zip_path andDesPath:FILEPATH];
            NSArray *arrUnzipFile = [NSArray arrayWithArray:[downloadUnarchive getUnzipFile]];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadManager:didFinishLoadAndUnZipInDirectory:)]) {
                
                [self.delegate downloadManager:self
              didFinishLoadAndUnZipInDirectory:arrUnzipFile];
            }
            downloadUnarchive = nil;
            
            [[NSFileManager defaultManager] removeItemAtPath:zip_path
                                                       error:nil];
        }
        else {
            NSString *des_file = [desFilePath stringByAppendingPathComponent:fileName];
            [m_data writeToFile:des_file atomically:YES];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLoadInDirectory:)]) {
                [self.delegate didFinishLoadInDirectory:des_file];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadManager:didFinishLoadInDirectory:)]) {
                [self.delegate downloadManager:self didFinishLoadInDirectory:des_file];
            }
        }
        
        
        [m_data resetBytesInRange:NSMakeRange(0, [m_data length])];
        [m_data setLength:0];
        m_data = nil;
        
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

- (void)splitDownloadWithFileUrl:(NSString *)surl {
    
    if (!arrDownload) {
        arrDownload = [NSMutableArray arrayWithCapacity:3];
    }
    [arrDownload removeAllObjects];
    
    unsigned long long per_size = _dTotalSize/self.maxDownloadThread;
    
    if (!taskID) {
        taskID = [self createUuid];
    }
    
    for (int i=0; i<self.maxDownloadThread; i++) {
        
        VHRequestRange *ran;
        if (i== self.maxDownloadThread-1) {//最后一个
            ran = [[VHRequestRange alloc] initWithLocation:i*(per_size+1)
                                                 andLength:_dTotalSize-i*(per_size+1)+1];
        }
        else {
            ran = [[VHRequestRange alloc] initWithLocation:i*(per_size+1)
                                                 andLength:per_size];
        }
        
        VHDownload *down = [VHDownload startDownloadWithUrl:surl
                                                   andRange:ran
                                                 andDesPath:desFilePath
                                            andUniqueTaskID:taskID];
        down.index = i;
        down.delegate = self;
        [down setConnectionType:strConnection];
        [arrDownload addObject:down];
    }
    
    [self startAllDownload];
}

- (NSString*)createUuid;
{
    NSMutableString *string = [NSMutableString stringWithCapacity:4];
    for (int i = 0; i < 4; i++) {
        int number = arc4random() % 36;
        if (number < 10) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            [string appendString:tempString];
        }else {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            [string appendString:tempString];
        }
    }
    
    return string;
}

#pragma mark - Public Method

- (void)testUnzip {
    
    
}

- (NSString *)getAveSpeed {
    
    if (timeStart == 0) {
        return @"--KB/s";
    }
    
    NSString *unit = @"KB/s";
    CGFloat speed = 1.0*downloadedSize/1024.0/((CFAbsoluteTimeGetCurrent()-timeStart)*1.0);
    if (speed >= 1000) {
        unit = @"M/s";
        speed = speed/1024;
    }
    
    return [NSString stringWithFormat:@"%.2f%@",speed,unit];
    
}

- (NSString *)getFileName {
    
    if (fileName) {
        return fileName;
    }
    
    return @"--";
}

- (void)startDownload {
    
    if (!taskID) {
        taskID = [self createUuid];
    }
    
    VHRequestRange *range = [[VHRequestRange alloc] initWithLocation:0 andLength:100];
    VHDownload *download = [VHDownload startDownloadWithUrl:strRequestUrl
                                                   andRange:range
                                                 andDesPath:desFilePath
                                            andUniqueTaskID:taskID];
    download.isTest = YES;
    download.delegate = self;
    [download startDownload];
}

- (void)stopDownload {
    
    
    for (int i=0; i<arrDownload.count; i++) {
        VHDownload *download = arrDownload[i];
        [download cancel];
        download = nil;
    }
    [arrDownload removeAllObjects];
    
}

#pragma mark - Initinal

- (void)initinal {
    
    downloadSpeed = 0.0f;
    self.maxDownloadThread = 20;
    _dTotalSize = 0;
    timeStart = 0;
    
}

#pragma mark - SYS

- (id)initWithDownloadUrl:(NSString *)surl andDownloadPath:(NSString *)path {
    
    self = [super init];
    if (self) {
        strRequestUrl = [NSString stringWithString:surl];
        desFilePath = [NSString stringWithString:path];
        [self initinal];
        [self testUnzip];
    }
    
    return self;
}


@end
