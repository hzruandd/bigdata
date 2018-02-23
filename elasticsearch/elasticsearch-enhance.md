分布式搜索elasticsearch高级配置之（二）------线程池设置

一个Elasticsearch节点会有多个线程池，但重要的是下面四个：
索引（index）：主要是索引数据和删除数据操作（默认是cached类型）
搜索（search）：主要是获取，统计和搜索操作（默认是cached类型）
批量操作（bulk）：主要是对索引的批量操作（默认是cached类型）
更新（refresh）：主要是更新操作（默认是cached类型）

可以通过给设置一个参数来改变线程池的类型（type），例如，把索引的线程池改成blocking类型：

threadpool: 
    index: 
        type: blocking 
        min: 1
        size: 30
        wait_time: 30s
下面是三种可以设置的线程池的类型
cache
cache线程池是一个无限大小的线程池，如果有很请求的话都会创建很多线程，下面是个例子

threadpool: 
    index: 
        type: cached
fixed
fixed线程池保持固定个数的线程来处理请求队列。
size参数设置线程的个数，默认设置是cpu核心数的5倍
queue_size可以控制待处理请求队列的大小。默认是设置为-1，意味着无限制。当一个请求到来但队列满了的时候，reject_policy参数可以控制它的行为。默认是abort，会使那个请求失败。设置成caller会使该请求在io线程中执行。

threadpool: 
    index: 
        type: fixed 
        size: 30
        queue: 1000
        reject_policy: caller
blocking
blocking线程池允许设置一个最小值（min，默认为1）和线程池大小（size，默认为cpu核心数的5倍）。它也有一个等待队列，队列的大小（queue_size
）默认是1000，当这队列满了的时候。它会根据定好的等待时间（wait_time，默认是60秒）来调用io线程，如果没有执行就会报错。

threadpool: 
    index: 
        type: blocking 
        min: 1
        size: 30
        wait_time: 30s

