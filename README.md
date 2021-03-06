# Async.legacy.OC
Rewrite [Async.legacy](https://github.com/josephlord/Async.legacy) by Objective-C (iOS7+ and OS X 10.9+ compatible)

**Async** sugar looks like this:
```obj-c
Async.background(^{
    NSLog(@"A: This is run on the background");
}).main(^{
    NSLog(@"B: This is run on the , after the previous block");
});
```

Instead of the familiar syntax for GCD:
```obj-c
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSLog(@"A: This is run on the background");

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"B: This is run on the , after the previous block");
    });
});
```

## Things you can do

Supports the modern queue classes:
```obj-c
Async.main (^{})
Async.userInteractive (^{})
Async.userInitiated (^{})
Async.utility (^{})
Async.background (^{})
```

Chain as many blocks as you want:
```obj-c
Async.userInitiated (^{
    // 1
}).main (^{
    // 2
}).background (^{
    // 3
}).main (^{
    // 4
})
```

Instend of `dispatch_after
```obj-c
// After
CGFloat seconds = .5;
NSLog(@"---------------");
Async.after(seconds).main(^{
    NSLog(@"Is called after 0.5 seconds");
}).after(.4).background(^{
    NSLog(@"At least 0.4 seconds after previous block, and 0.5 after Async code is called");
});
```
Cancel blocks
```obj-c
// Cancel blocks not yet dispatched
AsyncBlock block1 = Async.background(^{
    // Heavy work
    for (NSUInteger i=0; i < 1000; i++) {
        NSLog(@"A %zd",i);
    }
});
AsyncBlock block2 = block1.background(^{
    NSLog(@"B - shouldn't be reached, since cancelled");
});
Async.main(^{
    [block1 cancel];
    [block2 cancel];
});
```
