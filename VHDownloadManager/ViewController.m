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
    
    NSString *surl = @"https://1geauomtsgyzdncb3fa4unmmrgrzgramjct4zya5uf3ts65e.ourdvsss.com/d1.baidupcs.com/file/de9b33627c658ecefba0e74b89bfc656?bkt=p2-qd-838&xcode=d5121bb2afc482995993a3c0da21a0fead66b1a0853929c5a7103330c9091c9b&fid=1280098185-250528-207155959871156&time=1477903458&sign=FDTAXGERLBH-DCb740ccc5511e5e8fedcff06b081203-WKnW%2F7tqcRFUTWwGeALMfi9v7BY%3D&to=sf&fm=Qin,B,T,bs&sta_dx=34620451&sta_cs=8601&sta_ft=ape&sta_ct=7&sta_mt=7&fm2=Qingdao,B,T,bs&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=1400de9b33627c658ecefba0e74b89bfc656ba900ca9000002104423&sl=77594702&expires=8h&rt=sh&r=416205936&mlogid=7066793823260874647&vuk=606923620&vbdid=800758283&fin=%E5%91%A8%E6%9D%B0%E4%BC%A6%20-%20%E6%88%91%E4%B8%8D%E9%85%8D.ape&fn=%E5%91%A8%E6%9D%B0%E4%BC%A6%20-%20%E6%88%91%E4%B8%8D%E9%85%8D.ape&slt=pm&uta=0&rtype=1&iv=0&isw=0&dp-logid=7066793823260874647&dp-callid=0.1.1&hps=1&csl=127&csign=l8EIrgzcNYJcR06i81AfOfvkgQs%3D&wshc_tag=0&wsts_tag=58170463&wsid_tag=dfff23d4&wsiphost=ipdbm";
    
    VHDownloadManager *man = [[VHDownloadManager alloc] initWithDownloadUrl:surl andDownloadPath:FILEPATH];
    man.delegate = self;
    [man startDownload];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
