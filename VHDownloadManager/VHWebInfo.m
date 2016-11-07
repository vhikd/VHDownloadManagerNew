//
//  VHWebInfo.m
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/11/6.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import "VHWebInfo.h"

#import "ViewController.h"

@interface VHWebInfo () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actView;
@end

@implementation VHWebInfo


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.absoluteString rangeOfString:@"d.pcs.baidu.com"].location != NSNotFound ||
        [request.URL.absoluteString rangeOfString:@"pcs/file"].location != NSNotFound) {
        
        
        ViewController *ctrl = [[ViewController alloc] initWithDownloadURL:request.URL.absoluteString];
        [self.navigationController pushViewController:ctrl animated:YES];
        return NO;
    }
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [self.actView startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.actView stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.actView stopAnimating];
    [self.webView performSelector:@selector(reload)
                       withObject:nil
                       afterDelay:1.5f];
}

#pragma mark - SYS

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //http://pan.baidu.com/s/1hr5yv3I
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:
                               [NSURL URLWithString:@"http://pan.baidu.com/s/1hr5yv3I"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
