//
//  DPKAsyncWrapper.m
//  AsyncOCExample
//
//  Created by Deepak on 8/27/15.
//  Copyright (c) 2015 deepak. All rights reserved.
//

#import "DPKAsyncWrapper.h"


@interface DPKGCD : NSObject
+ (dispatch_queue_t)mainQueue;
+ (dispatch_queue_t)userInteractiveQueue;
+ (dispatch_queue_t)userInitiatedQueue;
+ (dispatch_queue_t)defaultQueue;
+ (dispatch_queue_t)utilityQueue;
+ (dispatch_queue_t)backgroundQueue;
@end

@interface DPKAsyncWrapper ()
@property (nonatomic, strong) dispatch_group_t dgroup;
@property (nonatomic, assign,getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign) CGFloat afterSecondes;
@end

@interface DPKAsyncChainWrapper : DPKAsyncWrapper
@end

#pragma mark -

@implementation DPKAsyncWrapper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dgroup = dispatch_group_create();
        _cancelled = NO;
        _afterSecondes = 0.0;
    }
    return self;
}

#pragma mark - Public Method

#define GenerateAsyncMethod(name) \
- (DPKAsyncWrapper *(^)(dispatch_block_t block))name \
{ \
    return ^DPKAsyncWrapper* (dispatch_block_t block){ \
        return [self async:block inQueue:[DPKGCD name##Queue] after:self.afterSecondes]; \
    }; \
}
#define GenerateCustomQueueAsyncMethod(name) \
- (DPKAsyncWrapper *(^)(dispatch_queue_t name, dispatch_block_t block))name \
{ \
    return ^DPKAsyncWrapper* (dispatch_queue_t name, dispatch_block_t block) { \
        return [self async:block inQueue:name after:self.afterSecondes]; \
    }; \
}

GenerateAsyncMethod(main)
GenerateAsyncMethod(userInteractive)
GenerateAsyncMethod(userInitiated)
GenerateAsyncMethod(utility)
GenerateAsyncMethod(background)
GenerateCustomQueueAsyncMethod(customQueue)

- (DPKAsyncWrapper * (^)(CGFloat after))after {
    return ^DPKAsyncWrapper* (CGFloat after) {
        self.afterSecondes = after;
        return self;
    };
}

- (void)cancel
{
    self.cancelled = YES;
}
- (void)wait:(CGFloat)seconds
{
    if (seconds != .0f) {
        int64_t nanoSeconds = (int64_t)(seconds * NSEC_PER_SEC);
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds);
        dispatch_group_wait(self.dgroup, time);
    } else {
        dispatch_group_wait(self.dgroup, DISPATCH_TIME_FOREVER);
    }
}

#pragma mark - Private Method

- (dispatch_time_t)timeFromNowAfterSeconds:(CGFloat)seconds {
    int64_t nanoSeceonds = (int64_t)(seconds * NSEC_PER_SEC);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, nanoSeceonds);
    return time;
}

- (DPKAsyncWrapper *)async:(dispatch_block_t) block inQueue:(dispatch_queue_t)queue after:(CGFloat)seconds
{
    DPKAsyncWrapper  *wrapper = [DPKAsyncChainWrapper new];
    dispatch_time_t time = [self timeFromNowAfterSeconds:seconds];
    
    dispatch_group_enter(wrapper.dgroup);
    dispatch_after(time, queue, ^{
        dispatch_block_t bk = [wrapper cancellable:block];
        !bk ?: bk();
        dispatch_group_leave(wrapper.dgroup);
    });
    
    return wrapper;
}

- (dispatch_block_t)cancellable:(dispatch_block_t)blockToWrap
{
    return
    ^{
        if (!self.isCancelled) {
            !blockToWrap ?: blockToWrap();
        }
    };
}


@end


@implementation DPKAsyncChainWrapper

- (DPKAsyncWrapper *)async:(dispatch_block_t) block inQueue:(dispatch_queue_t)queue after:(CGFloat)seconds
{
    DPKAsyncWrapper  *wrapper = [[DPKAsyncChainWrapper alloc] init];
    
    dispatch_group_enter(wrapper.dgroup);
    dispatch_group_notify(self.dgroup, queue, ^{
        
        dispatch_time_t time = [self timeFromNowAfterSeconds:seconds];
        dispatch_after(time, queue, ^{
            dispatch_block_t bk = [wrapper cancellable:block];
            !bk ?: bk();
            dispatch_group_leave(wrapper.dgroup);
        });
    });
    
    return wrapper;
}

@end

@implementation DPKGCD

+ (dispatch_queue_t)mainQueue
{
    return dispatch_get_main_queue();
}

+ (dispatch_queue_t)userInteractiveQueue
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
}

+ (dispatch_queue_t)userInitiatedQueue
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
}

+ (dispatch_queue_t)defaultQueue
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

+ (dispatch_queue_t)utilityQueue
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

+ (dispatch_queue_t)backgroundQueue
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
}

@end
