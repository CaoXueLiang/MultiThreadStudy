//
//  ViewController.m
//  MultiThreadStudy
//
//  Created by bjovov on 2017/12/5.
//  Copyright © 2017年 caoxueliang.cn. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //[self example5];
    //[self example6];
    //[self example7];
    //[self example8];
    //[self example10];
    //[self example11];
    [self example12];
}

- (void)example1{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        /*耗时操作在这处理
         例如：数据库访问，图片下载*/
        
        dispatch_async(dispatch_get_main_queue(), ^{
           /*在主线程中，更新UI
            UI只能在主线程中更新，其他线程不能更新UI*/
        });
    });
}

- (void)example2{
    
    ///1. 通过GCD的API生成 Dispatch Queue
    /**
     创建 dispatch_queue
     第一个参数: 线程名称，推荐使用应用程序ID这种逆序全程域名,也可以设置为`NULL`
     第二个参数: `SerialDispatchQueue`时设置为`DISPATCH_QUEUE_SERIAL` or `NULL`
                `ConcurrentDispatchQueue`时设置为`DISPATCH_QUEUE_CONCURRENT`
     */
    dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create("caoxueliang.MultiThreadStudy.mySerialDispatchQueue", NULL);
    dispatch_queue_t myConcurrentDispatchQueue = dispatch_queue_create("caoxueliang.MultiThreadStudy.myConcurrentDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
    
    //在Concurrent Dispatch Queue中执行指定的Block
    dispatch_async(myConcurrentDispatchQueue, ^{
        NSLog(@"block on myConcurrentDispatchQueue");
    });
    
    
    ///2. 获取系统标准提供的 Dispatch Queue
    dispatch_queue_t mainDispatchQueue = dispatch_get_main_queue();
    
    dispatch_queue_t globalDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}


- (void)example3{
   dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create("caoxueliang.MultiThreadStudy.mySerialDispatchQueue", NULL);
    dispatch_queue_t globalDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    /*
     变更生成的Dispatch Queue 的执行优先级
     第一个参数: 要变更执行优先级的Dispatch Queue
     第二个参数: 指定与要使用的执行优先级相同优先级的`globalDispatchQueue`
     */
    dispatch_set_target_queue(mySerialDispatchQueue, globalDispatchQueue);
}

- (void)example4{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"waited at least three seconds");
    });
}


- (void)example5{
    /*
     在追加到 Dispatch Queue 中的多个处理全部结束后，执行结束处理
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        NSLog(@"block0");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"block1");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"block2");
    });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"执行完毕");
    });
}

- (void)example6{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        NSLog(@"block0");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"block1");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"block2");
    });
    
    /*仅等待全部处理执行结束*/
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

- (void)example7{
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.ForBarrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{NSLog(@"block0_for_reading");});
    dispatch_async(queue, ^{NSLog(@"block1_for_reading");});
    dispatch_async(queue, ^{NSLog(@"block2_for_reading");});
    dispatch_async(queue, ^{NSLog(@"block3_for_reading");});
    
    /*
     写入处理
     将写入的内容读取之后的处理中
     */
    dispatch_barrier_async(queue, ^{
        NSLog(@"block_for_waiting");
    });
    
    dispatch_async(queue, ^{NSLog(@"block4_for_reading");});
    dispatch_async(queue, ^{NSLog(@"block5_for_reading");});
    dispatch_async(queue, ^{NSLog(@"block6_for_reading");});
    dispatch_async(queue, ^{NSLog(@"block7_for_reading");});
}

- (void)example8{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        NSLog(@"hello");
    });
}

- (void)example9{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        dispatch_sync(queue, ^{
             NSLog(@"hello");
        });
    });
}

- (void)example10{
    /*dispatch_queue_t queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"%zu",index);
        if (index == 3) {
            sleep(2);
        }
    });
    NSLog(@"执行完成");*/
    
    
    //推荐在`dispatch_async`函数中非同步的执行`dispatch_apply`函数
    NSArray *tmpArray = [NSArray arrayWithObjects:@1,@2,@3,@4, nil];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        /*
         *Global Dispatch Queue
         *等待`dispatch_apply`函数中全部处理执行结束
         */
        dispatch_apply([tmpArray count], queue, ^(size_t index) {
            
            //并列处理包含在`Nsarray`中的全部对象
            NSLog(@"%@",[tmpArray objectAtIndex:index]);
        });
        
        //`dispatch_apply`函数中处理全部执行结束
         
        
        //在`main dispatch queue`中非同步执行
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //更新用户界面
            NSLog(@"done");
        });
    });
}

- (void)example11{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    /*
     * 生成 Dispatch Semaphone
     * Dispatch Semaphone 的计数初始值设置为1
     *
     * 保证可访问 NSMutableArray 类对象的线程
     * 同时只能有一个
     */
    dispatch_semaphore_t semaphone = dispatch_semaphore_create(1);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 10000; i++) {
        dispatch_async(queue, ^{
            
            /*
             * 等待Dispatch Semaphone
             * 一直等待，直到Dispatch Semaphone 的计数值达到大于等于1
             */
            dispatch_semaphore_wait(semaphone, DISPATCH_TIME_FOREVER);
            
            /*
             * 由于 Dispatch Semaphone 的计数值达到大于等于1
             * 所以将 Dispatch Semaphone 的计数值减去1
             * dispatch_semaphore_wait 函数执行返回
             *
             * 即执行到此时的 Dispatch Semaphone 的计数恒为0
             *
             * 由于可访问NSMutableArray类对象的线程，只有一个
             * 因此可安全的进行更新
             */
            [array addObject:[NSNumber numberWithInt:i]];
            
            /*
             * 排他控制处理结束
             * 所以通过 dispatch_semaphore_signal 函数
             * 将 Dispatch Semaphone 的计数值加1
             *
             * 如果有通过 dispatch_semaphore_wait 函数
             * 等待Dispatch Semaphone的计数值增加的线程
             * 就由最先等待的线程执行
             */
            dispatch_semaphore_signal(semaphone);
        });
    }
}

+ (NSBundle *)bundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ResourceWeibo" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle;
}

/*dispatch实现定时器*/
- (void)example12{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //每秒执行
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);

    //指定定时器指定时间内执行的处理
    dispatch_source_set_event_handler(_timer, ^{
        NSLog(@"text");
        if(time <= 0){
            //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{

            });
        }else{
            
        }
    });
    
    //启动 Dispatch Source
    dispatch_resume(_timer);
}

@end

