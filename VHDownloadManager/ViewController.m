//
//  ViewController.m
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/10/30.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import "ViewController.h"

#import "VHDownloadManager.h"

@interface ViewController () <VHDownloadManagerDelegate> {
    
    UILabel *labTitle,*labSpeed,*labProgress;
    
    UIProgressView *progressBar;
    
    VHDownloadManager *downloadManager;
    NSTimer *timerUpdate;
    
    NSString *sDownloadUrl;
    
}

@end

@implementation ViewController

#pragma mark - VHDownloadManagerDelegate

- (void)downloadManager:(VHDownloadManager *)manager didStartDownload:(NSString *)file_name {
    
    if (!timerUpdate) {
        timerUpdate = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                       target:self
                                                     selector:@selector(updateInfoUI)
                                                     userInfo:nil
                                                      repeats:YES];
    }
    
}

- (void)downloadManager:(VHDownloadManager *)manager didFinishLoadAndUnZipInDirectory:(NSArray *)paths {
    
    NSString *msg = @"";
    for (int i=0; i<paths.count; i++) {
        
        NSString *path = paths[i];
//        [[NSFileManager defaultManager] moveItemAtPath:path
//                                                toPath:file_des
//                                                 error:nil];
        if (msg.length == 0) {
            msg = [NSString stringWithFormat:@"%@",[path lastPathComponent]];
        }
        else {
            msg = [NSString stringWithFormat:@"%@\n%@",msg,[path lastPathComponent]];
        }
        
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Downloaf"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES
                     completion:^{
                         
                     }];
    
    if (timerUpdate) {
        [timerUpdate invalidate];
        timerUpdate = nil;
    }
    
}

- (void)downloadManager:(VHDownloadManager *)manager didFinishLoadInDirectory:(NSString *)path; {
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Downloaf"
                                                                   message:[path lastPathComponent]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES
                     completion:^{
                         
                     }];
    
//    [[NSFileManager defaultManager] moveItemAtPath:path
//                                            toPath:file_des
//                                             error:nil];
    
    if (timerUpdate) {
        [timerUpdate invalidate];
        timerUpdate = nil;
    }
    
}

#pragma mark - Private

- (void)updateInfoUI {
    
    labTitle.text = [NSString stringWithFormat:@"%@\n%.1fMB",
                     [downloadManager getFileName],
                     downloadManager.dTotalSize/1024.0/1024.0];
    
    if (downloadManager.dTotalSize == 0) {
        progressBar.progress = 0.0f;
    }
    else {
        progressBar.progress = downloadManager.dProgress;
    }
    labSpeed.text = [downloadManager getAveSpeed];
    
}

#pragma mark - Build UI

- (void)buildTitleLab {
    
    labTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    labTitle.numberOfLines = 2;
    labTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labTitle];
    
}

- (void)buildAveSpeedLab {
    
    float ori_y = labTitle.frame.origin.y+labTitle.frame.size.height+10;
    
    labSpeed = [[UILabel alloc] initWithFrame:CGRectMake(0, ori_y,
                                                         self.view.frame.size.width, 20)];
    labSpeed.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labSpeed];
}

- (void)buildProgressLab {
    
    float ori_y = labSpeed.frame.origin.y+labSpeed.frame.size.height+10;
    
    labProgress = [[UILabel alloc] initWithFrame:CGRectMake(0, ori_y,
                                                         self.view.frame.size.width, 20)];
    labProgress.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labProgress];
    
}

- (void)buildProgressBar {
    
    float ori_y = labProgress.frame.origin.y+labProgress.frame.size.height+10;
    
    progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(0, ori_y,
                                                                   self.view.frame.size.width,
                                                                   10)];
    progressBar.progress = .0f;
    [self.view addSubview:progressBar];
    
}

#pragma mark - SYS

- (id)initWithDownloadURL:(NSString *)surl {
    self = [super init];
    if (self) {
        
        sDownloadUrl = [NSString stringWithString:surl];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self buildTitleLab];
    [self buildAveSpeedLab];
    [self buildProgressLab];
    [self buildProgressBar];
    
    NSLog(@"%@",FILEPATH);
    
    timerUpdate = nil;
    downloadManager = [[VHDownloadManager alloc] initWithDownloadUrl:sDownloadUrl
                                                     andDownloadPath:FILEPATH];
    downloadManager.delegate = self;
    [downloadManager startDownload];
    [self updateInfoUI];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
