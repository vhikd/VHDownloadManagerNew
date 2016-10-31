//
//  VHRequestRange.h
//  VHDownloadManager
//
//  Created by 刁志远 on 2016/10/30.
//  Copyright © 2016年 刁志远. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VHRequestRange : NSObject

@property (nonatomic) unsigned long long location;
@property (nonatomic) unsigned long long length;
//@property (nonatomic) unsigned long long location;

- (id)initWithLocation:(unsigned long long)location andLength:(unsigned long long)length;

@end
