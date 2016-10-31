//
//  VHRequestRange.m
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/10/30.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import "VHRequestRange.h"

@implementation VHRequestRange


- (id)initWithLocation:(unsigned long long)location andLength:(unsigned long long)length {
    
    self = [super init];
    if (self) {
        self.length = length;
        self.location = location;
    }
    
    return self;
    
}

@end
