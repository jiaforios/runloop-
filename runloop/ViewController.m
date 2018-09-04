//
//  ViewController.m
//  runloop
//
//  Created by admin on 2018/8/31.
//  Copyright © 2018年 com. All rights reserved.
//

#import "ViewController.h"

//https://blog.csdn.net/jeffasd/article/details/52023182  参考学习链接


@interface ViewController ()
{
    NSThread *thread;
    NSPort *port;
    NSRunLoop *runloop;
    CFRunLoopRef runloop2;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    port = [NSPort new];
//    CFRunLoopRef,
//    CFRunLoopMode
//    CFRunLoopSourceRef
//    CFRunLoopTimerRef
//    CFRunLoopObserverRef
 
    
    [self makeAthread];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"时间到 停止runloop");
        CFRunLoopStop(runloop2);
    });
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self performSelector:@selector(nameAction) onThread:thread withObject:nil waitUntilDone:NO];

//    CFRunLoopStop(runloop.getCFRunLoop);
    

}


- (void)nameAction{
    
    NSLog(@"执行位置 thread = %@",thread.name);
//    [self registerSource];

}

- (void)makeAthread{
    
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadAction) object:nil];
    thread.name = @"testtHREAD";
    [thread start];
    
}


- (void)threadAction{
    NSLog(@"thread action 1");
//    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
//    [runloop addPort:[NSPort new] forMode:NSDefaultRunLoopMode]; // 如果一个 runloop 没有任何port timer 会立即退出
//    [runloop run];

//    runloop = [NSRunLoop currentRunLoop];
//    [runloop addPort:port forMode:NSDefaultRunLoopMode];
    // 该启动方式 会因为performSelector 而结束runloop
//    [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//
    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    runloop2 = CFRunLoopGetCurrent();
    
    CFRunLoopAddSource(runloop2, source, kCFRunLoopDefaultMode);

    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 2000, NO); // 第三个参数，能够控制是否在处理事件后让Run Loop退出返回
//    CFRunLoopRun(); 这个he nsrunloop 不同，可以通过CFRunLoopStop 停止
    
    
    NSLog(@"thread action 2");
    

  
}

// 注册；source0 事件，runloop 如果活着就执行，反之需要唤醒执行
// source0 只是简单的注册了事件，不能主动触发事件，source1 能够唤醒runloop
- (void)registerSource{
    
    CFRunLoopSourceContext context = {0, (__bridge void *)self, NULL, NULL, NULL, NULL, NULL, NULL, NULL, perform};
    

    CFRunLoopSourceRef source0 = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
// 标记source0 唤醒后执行
    CFRunLoopSourceSignal(source0);
    CFRunLoopAddSource(runloop2, source0, kCFRunLoopDefaultMode);
//    CFRunLoopWakeUp(runloop2);
}

void perform(void *info){
    
    NSLog(@"触发了事件");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
