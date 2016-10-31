//
//  ViewController.m
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/10/30.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import "ViewController.h"

#import "VHDownloadManager.h"

@interface ViewController () <VHDownloadManagerDelegate>

@end

@implementation ViewController


#pragma mark - VHDownloadManagerDelegate

- (void)didStartDownloadWithFileName:(NSString *)file_name andTotalSize:(unsigned long long)size {
    NSLog(@"%@ --  %lld",file_name,size);
}

- (void)didLoadData:(unsigned long long)size andProgress:(double)progress {
    
    NSLog(@"%lld --- %.2f",size,progress);
    
}
- (void)didFinishLoadInDirectory:(NSString *)path {
    
    NSLog(@"path - %@",path);
    
}

#pragma mark - SYS

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *surl = @"https://1ge3dymt1gy3nhp3zfa5u1mmrgrzgramjct4zya5uf3ts65e.ourdvsss.com/d1.baidupcs.com/file/e2c387de9ea821190bcdb880e7a4fa55?bkt=p2-qd-221&xcode=fa05f214f562129dbcb949c47e0970977c0a43926c4121c8ded0b7c77404c736&fid=3796632986-250528-758906592723881&time=1477900359&sign=FDTAXGERLBH-DCb740ccc5511e5e8fedcff06b081203-YIEIbyliNVwupAWhgWX%2FrtEBZ4M%3D&to=sf&fm=Nin,B,T,bs&sta_dx=34037949&sta_cs=21992&sta_ft=ape&sta_ct=7&sta_mt=7&fm2=Ningbo,B,T,bs&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=1400e2c387de9ea821190bcdb880e7a4fa55c987ec240000020760bd&sl=74055758&expires=8h&rt=sh&r=672165973&mlogid=7065962012141198059&vuk=606923620&vbdid=800758283&fin=%E5%91%A8%E6%9D%B0%E4%BC%A6-%E4%B8%9C%E9%A3%8E%E7%A0%B4.ape&fn=%E5%91%A8%E6%9D%B0%E4%BC%A6-%E4%B8%9C%E9%A3%8E%E7%A0%B4.ape&slt=pm&uta=0&rtype=1&iv=0&isw=0&dp-logid=7065962012141198059&dp-callid=0.1.1&hps=1&csl=181&csign=IlOfPFCiSoOV91zCyZi3fjnqRDQ%3D&wshc_tag=0&wsts_tag=5816f848&wsid_tag=dfff23d4&wsiphost=ipdbm";
    
    VHDownloadManager *man = [[VHDownloadManager alloc] initWithDownloadUrl:surl];
    man.delegate = self;
    [man startDownload];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
