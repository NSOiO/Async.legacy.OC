//
//  DPKAsyncWrapper.h
//  AsyncOCExample
//
//  Created by Deepak on 8/27/15.
//  Copyright (c) 2015 deepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>


#ifndef Async
#define Async ([[DPKAsyncWrapper alloc] init])
#endif

#ifndef AsyncBlock
#define AsyncBlock DPKAsyncWrapper*
#endif


@interface DPKAsyncWrapper : NSObject

- (DPKAsyncWrapper *(^)(dispatch_block_t block))main;
- (DPKAsyncWrapper *(^)(dispatch_block_t block))userInteractive;
- (DPKAsyncWrapper *(^)(dispatch_block_t block))userInitiated;
- (DPKAsyncWrapper *(^)(dispatch_block_t block))utility;
- (DPKAsyncWrapper *(^)(dispatch_block_t block))background;
- (DPKAsyncWrapper *(^)(dispatch_queue_t customQueue, dispatch_block_t block))customQueue;

- (DPKAsyncWrapper *(^)(CGFloat after))after;

- (void)cancel;
- (void)wait:(CGFloat)seconds;

@end

