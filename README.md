# RAC
[博客地址](http://shuaiwang007.github.io/2016/04/21/RAC-MVVM在实际项目中的用法/)

### RAC+MVVM在实际项目中用法
#### RAC在iOS的实际开发中确实是一件有力的武器，此文将从以下几方面讲解
>
* RACSignal
* RACSubject
* RACSequence
* RACMulticastConnection
* RACCommand
* RAC常用宏
* RAC-bind
* RAC-过滤
* RAC-映射
* RAC-组合
* RAC+MVVM-网络请求


#### RACSignal
``` objc
// 1.创建信号
RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
// 3.发送信号
[subscriber sendNext:@"ws"];
// 4.取消信号，如果信号想要被取消，就必须返回一个RACDisposable
// 信号什么时候被取消：1.自动取消，当一个信号的订阅者被销毁的时候机会自动取消订阅，2.手动取消，
//block什么时候调用：一旦一个信号被取消订阅就会调用
//block作用：当信号被取消时用于清空一些资源
return [RACDisposable disposableWithBlock:^{
NSLog(@"取消订阅");
}];
}];
// 2. 订阅信号
//subscribeNext
// 把nextBlock保存到订阅者里面
// 只要订阅信号就会返回一个取消订阅信号的类
RACDisposable *disposable = [signal subscribeNext:^(id x) {
// block的调用时刻：只要信号内部发出数据就会调用这个block
NSLog(@"======%@", x);
}];
// 取消订阅
[disposable dispose];

```

**总结**


* .核心：
* .核心：信号类
* .信号类的作用：只要有数据改变就会把数据包装成信号传递出去
* .只要有数据改变就会有信号发出
* .数据发出，并不是信号类发出，信号类不能发送数据
* .使用方法：
* .创建信号
* .订阅信号
* .实现思路：
* .当一个信号被订阅，创建订阅者，并把nextBlock保存到订阅者里面。
* .创建的时候会返回 [RACDynamicSignal createSignal:didSubscribe];
* .调用RACDynamicSignal的didSubscribe
* .发送信号[subscriber sendNext:value];
* .拿到订阅者的nextBlock调用
*/

#### RACSubject

RACSubject 在使用中我们可以完全代替代理，代码简介方法。具体代码请看demo中的RACSubject。

**总结**

我们完全可以用RACSubject代替代理/通知，确实方便许多
这里我们点击TwoViewController的pop的时候 将字符串"ws"传给了ViewController的button的title。

步骤：

* 1.创建信号
```objc
RACSubject *subject = [RACSubject subject];
```
* 2.订阅信号
```objc
[subject subscribeNext:^(id x) {
// block:当有数据发出的时候就会调用
// block:处理数据
NSLog(@"%@",x);
}];
```
* 3.发送信号
```objc
[subject sendNext:value];
``` 
* 注意
RACSubject和RACReplaySubject的区别
RACSubject必须要先订阅信号之后才能发送信号， 而RACReplaySubject可以先发送信号后订阅.
RACSubject 代码中体现为：先走TwoViewController的sendNext，后走ViewController的subscribeNext订阅
RACReplaySubject 代码中体现为：先走ViewController的subscribeNext订阅，后走TwoViewController的sendNext
可按实际情况各取所需。


#### RACSequence

使用场景---： 可以快速高效的遍历数组和字典。

```objc
NSString *path = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
NSArray *dictArr = [NSArray arrayWithContentsOfFile:path];
[dictArr.rac_sequence.signal subscribeNext:^(id x) {
NSLog(@"%@", x);
} error:^(NSError *error) {
NSLog(@"===error===");
} completed:^{
NSLog(@"ok---完毕");
}];

也可以使用宏

NSDictionary *dict = @{@"key":@1, @"key2":@2};
[dict.rac_sequence.signal subscribeNext:^(id x) {
NSLog(@"%@", x);
NSString *key = x[0];
NSString *value = x[1];
// RACTupleUnpack宏：专门用来解析元组
// RACTupleUnpack 等会右边：需要解析的元组 宏的参数，填解析的什么样数据
// 元组里面有几个值，宏的参数就必须填几个
RACTupleUnpack(NSString *key, NSString *value) = x;
NSLog(@"%@ %@", key, value);
} error:^(NSError *error) {
NSLog(@"===error");
} completed:^{
NSLog(@"-----ok---完毕");
}];

```
#### RACMulticastConnection

当有多个订阅者，但是我们只想发送一个信号的时候怎么办？这时我们就可以用RACMulticastConnection，来实现。代码示例如下

```objc
// 普通写法, 这样的缺点是：没订阅一次信号就得重新创建并发送请求，这样很不友好
RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
// didSubscribeblock中的代码都统称为副作用。
// 发送请求---比如afn
NSLog(@"发送请求啦");
// 发送信号
[subscriber sendNext:@"ws"];
return nil;
}];
[signal subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
[signal subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
[signal subscribeNext:^(id x) {
NSLog(@"%@", x);
}];

```


```objc
// 比较好的做法。 使用RACMulticastConnection，无论有多少个订阅者，无论订阅多少次，我只发送一个。
// 1.发送请求，用一个信号内包装，不管有多少个订阅者，只想发一次请求
RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
// 发送请求
NSLog(@"发送请求啦");
// 发送信号
[subscriber sendNext:@"ws"];
return nil;
}];
//2. 创建连接类
RACMulticastConnection *connection = [signal publish];
[connection.signal subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
[connection.signal subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
[connection.signal subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
//3. 连接。只有连接了才会把信号源变为热信号
[connection connect];
```


#### RACCommand
* RACCommand:RAC中用于处理事件的类，可以把事件如何处理，事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程，比如看事件有没有执行完毕
* 使用场景：监听按钮点击，网络请求

```objc
// 普通做法
// RACCommand: 处理事件
// 不能返回空的信号
// 1.创建命令
RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//block调用，执行命令的时候就会调用
NSLog(@"%@",input); // input 为执行命令传进来的参数
// 这里的返回值不允许为nil
return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
[subscriber sendNext:@"执行命令产生的数据"];
return nil;
}];
}];

// 如何拿到执行命令中产生的数据呢？
// 订阅命令内部的信号
// ** 方式一：直接订阅执行命令返回的信号

// 2.执行命令
RACSignal *signal =[command execute:@2]; // 这里其实用到的是replaySubject 可以先发送命令再订阅
// 在这里就可以订阅信号了
[signal subscribeNext:^(id x) {
NSLog(@"%@",x);
}];

```
```objc
// 一般做法
// 1.创建命令
RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//block调用，执行命令的时候就会调用
NSLog(@"%@",input); // input 为执行命令传进来的参数
// 这里的返回值不允许为nil
return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
[subscriber sendNext:@"执行命令产生的数据"];
return nil;
}];
}];

// 方式二：
// 订阅信号
// 注意：这里必须是先订阅才能发送命令
// executionSignals：信号源，信号中信号，signalofsignals:信号，发送数据就是信号
[command.executionSignals subscribeNext:^(RACSignal *x) {
[x subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
//        NSLog(@"%@", x);
}];

// 2.执行命令
[command execute:@2];

```
```objc
// 高级做法
// 1.创建命令
RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
// block调用：执行命令的时候就会调用
NSLog(@"%@", input);
// 这里的返回值不允许为nil
return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
[subscriber sendNext:@"发送信号"];
return nil;
}];
}];

// 方式三
// switchToLatest获取最新发送的信号，只能用于信号中信号。
[command.executionSignals.switchToLatest subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
// 2.执行命令
[command execute:@3];
```
```objc
// switchToLatest--用于信号中信号
// 创建信号中信号
RACSubject *signalofsignals = [RACSubject subject];
RACSubject *signalA = [RACSubject subject];
// 订阅信号
//    [signalofsignals subscribeNext:^(RACSignal *x) {
//        [x subscribeNext:^(id x) {
//            NSLog(@"%@", x);
//        }];
//    }];
// switchToLatest: 获取信号中信号发送的最新信号
[signalofsignals.switchToLatest subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
// 发送信号
[signalofsignals sendNext:signalA];
[signalA sendNext:@4];

```
```objc
// 监听事件有没有完成
//注意：当前命令内部发送数据完成，一定要主动发送完成
// 1.创建命令
RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
// block调用：执行命令的时候就会调用
NSLog(@"%@", input);
// 这里的返回值不允许为nil
return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
// 发送数据
[subscriber sendNext:@"执行命令产生的数据"];

// *** 发送完成 **
[subscriber sendCompleted];
return nil;
}];
}];
// 监听事件有没有完成
[command.executing subscribeNext:^(id x) {
if ([x boolValue] == YES) { // 正在执行
NSLog(@"当前正在执行%@", x);
}else {
// 执行完成/没有执行
NSLog(@"执行完成/没有执行");
}
}];

// 2.执行命令
[command execute:@1];

```
#### RAC常用宏
RAC有许多强大而方便的宏。如下

```objc
// RAC:把一个对象的某个属性绑定一个信号,只要发出信号,就会把信号的内容给对象的属性赋值
// 给label的text属性绑定了文本框改变的信号
RAC(self.label, text) = self.textField.rac_textSignal;
//    [self.textField.rac_textSignal subscribeNext:^(id x) {
//        self.label.text = x;
//    }];

```
```objc
/**
*  KVO
*  RACObserveL:快速的监听某个对象的某个属性改变
*  返回的是一个信号,对象的某个属性改变的信号
*/
[RACObserve(self.view, center) subscribeNext:^(id x) {
NSLog(@"%@", x);
}];

```
```objc 
//例 textField输入的值赋值给label，监听label文字改变,
RAC(self.label, text) = self.textField.rac_textSignal;
[RACObserve(self.label, text) subscribeNext:^(id x) {
NSLog(@"====label的文字变了");
}];

```
```objc
/**
*  循环引用问题
*/
@weakify(self)
RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
@strongify(self)
NSLog(@"%@",self.view);
return nil;
}];
_signal = signal;
使用 @weakify(self)和@strongify(self)来避免循环引用

```
```objc
/**
* 元祖
* 快速包装一个元组
* 把包装的类型放在宏的参数里面,就会自动包装
*/
RACTuple *tuple = RACTuplePack(@1,@2,@4);
// 宏的参数类型要和元祖中元素类型一致， 右边为要解析的元祖。
RACTupleUnpack_(NSNumber *num1, NSNumber *num2, NSNumber * num3) = tuple;// 4.元祖
// 快速包装一个元组
// 把包装的类型放在宏的参数里面,就会自动包装
NSLog(@"%@ %@ %@", num1, num2, num3);

```
#### RAC-bind
```objc
// 1.创建信号
RACSubject *subject = [RACSubject subject];
// 2.绑定信号
RACSignal *bindSignal = [subject bind:^RACStreamBindBlock{
// block调用时刻：只要绑定信号订阅就会调用。不做什么事情，
return ^RACSignal *(id value, BOOL *stop){
// 一般在这个block中做事 ，发数据的时候会来到这个block。
// 只要源信号（subject）发送数据，就会调用block
// block作用：处理源信号内容
// value:源信号发送的内容，
value = @3; // 如果在这里把value的值改了，那么订阅绑定信号的值即44行的x就变了
NSLog(@"接受到源信号的内容：%@", value);
//返回信号，不能为nil,如果非要返回空---则empty或 alloc init。
return [RACReturnSignal return:value]; // 把返回的值包装成信号
};
}];

// 3.订阅绑定信号
[bindSignal subscribeNext:^(id x) {

NSLog(@"接收到绑定信号处理完的信号:%@", x);
}];
// 4.发送信号
[subject sendNext:@"123"];

```
* 总结
* bind（绑定）的使用思想和Hook的一样---> 都是拦截API从而可以对数据进行操作，，而影响返回数据。
* 发送信号的时候会来到30行的block。在这个block里我们可以对数据进行一些操作，那么35行打印的value和订阅绑定信号后的value就会变了。变成什么样随你喜欢喽。

#### RAC-过滤
* 有时候我们想要过滤一些信号，这时候我们便可以用RAC的过滤方法。过滤方法有好多种，如下代码，从不同情况下进行了分析。

```objc
// 跳跃 ： 如下，skip传入2 跳过前面两个值
// 实际用处： 在实际开发中比如 后台返回的数据前面几个没用，我们想跳跃过去，便可以用skip
RACSubject *subject = [RACSubject subject];
[[subject skip:2] subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
[subject sendNext:@1];
[subject sendNext:@2];
[subject sendNext:@3];

```
```objc
//distinctUntilChanged:-- 如果当前的值跟上一次的值一样，就不会被订阅到
RACSubject *subject = [RACSubject subject];
[[subject distinctUntilChanged] subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
// 发送信号
[subject sendNext:@1];
[subject sendNext:@2];
[subject sendNext:@2]; // 不会被订阅

```
```objc
// take:可以屏蔽一些值,去掉前面几个值---这里take为2 则只拿到前两个值
RACSubject *subject = [RACSubject subject];
[[subject take:2] subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
// 发送信号
[subject sendNext:@1];
[subject sendNext:@2];
[subject sendNext:@3];

```
```objc
//takeLast:和take的用法一样，不过他取的是最后的几个值，如下，则取的是最后两个值
//注意点:takeLast 一定要调用sendCompleted，告诉他发送完成了，这样才能取到最后的几个值
RACSubject *subject = [RACSubject subject];
[[subject takeLast:2] subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
// 发送信号
[subject sendNext:@1];
[subject sendNext:@2];
[subject sendNext:@3];
[subject sendCompleted];

```
```objc
// takeUntil:---给takeUntil传的是哪个信号，那么当这个信号发送信号或sendCompleted，就不能再接受源信号的内容了。
RACSubject *subject = [RACSubject subject];
RACSubject *subject2 = [RACSubject subject];
[[subject takeUntil:subject2] subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
// 发送信号
[subject sendNext:@1];
[subject sendNext:@2];
[subject2 sendNext:@3];  // 1
//    [subject2 sendCompleted]; // 或2
[subject sendNext:@4];

```
```objc 
// ignore: 忽略掉一些值
//ignore:忽略一些值
//ignoreValues:表示忽略所有的值
// 1.创建信号
RACSubject *subject = [RACSubject subject];
// 2.忽略一些值
RACSignal *ignoreSignal = [subject ignore:@2]; // ignoreValues:表示忽略所有的值
// 3.订阅信号
[ignoreSignal subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
// 4.发送数据
[subject sendNext:@2];

```
```objc
// 一般和文本框一起用，添加过滤条件
// 只有当文本框的内容长度大于5，才获取文本框里的内容
[[self.textField.rac_textSignal filter:^BOOL(id value) {
// value 源信号的内容
return [value length] > 5;
// 返回值 就是过滤条件。只有满足这个条件才能获取到内容
}] subscribeNext:^(id x) {
NSLog(@"%@", x);
}];

```

#### RAC-映射
* RAC的映射在实际开发中有什么用呢？比如我们想要拦截服务器返回的数据，给数据拼接特定的东西或想对数据进行操作从而更改返回值，类似于这样的情况下，我们便可以考虑用RAC的映射，实例代码如下

```objc
- (void)map {
// 创建信号
RACSubject *subject = [RACSubject subject];
// 绑定信号
RACSignal *bindSignal = [subject map:^id(id value) {

// 返回的类型就是你需要映射的值
return [NSString stringWithFormat:@"ws:%@", value]; //这里将源信号发送的“123” 前面拼接了ws：
}];
// 订阅绑定信号
[bindSignal subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
// 发送信号
[subject sendNext:@"123"];

```
```objc
- (void)flatMap {
// 创建信号
RACSubject *subject = [RACSubject subject];
// 绑定信号
RACSignal *bindSignal = [subject flattenMap:^RACStream *(id value) {
// block：只要源信号发送内容就会调用
// value: 就是源信号发送的内容
// 返回信号用来包装成修改内容的值
return [RACReturnSignal return:value];

}];

// flattenMap中返回的是什么信号，订阅的就是什么信号(那么，x的值等于value的值，如果我们操纵value的值那么x也会随之而变)
// 订阅信号
[bindSignal subscribeNext:^(id x) {
NSLog(@"%@", x);
}];

// 发送数据
[subject sendNext:@"123"];

}

```
```objc
- (void)flattenMap2 {
// flattenMap 主要用于信号中的信号
// 创建信号
RACSubject *signalofSignals = [RACSubject subject];
RACSubject *signal = [RACSubject subject];

// 订阅信号
//方式1
//    [signalofSignals subscribeNext:^(id x) {
//
//        [x subscribeNext:^(id x) {
//            NSLog(@"%@", x);
//        }];
//    }];
// 方式2
//    [signalofSignals.switchToLatest  ];
// 方式3
//   RACSignal *bignSignal = [signalofSignals flattenMap:^RACStream *(id value) {
//
//        //value:就是源信号发送内容
//        return value;
//    }];
//    [bignSignal subscribeNext:^(id x) {
//        NSLog(@"%@", x);
//    }];
// 方式4--------也是开发中常用的
[[signalofSignals flattenMap:^RACStream *(id value) {
return value;
}] subscribeNext:^(id x) {
NSLog(@"%@", x);
}];

// 发送信号
[signalofSignals sendNext:signal];
[signal sendNext:@"123"];
}

```
#### RAC-组合
* 把多个信号聚合成你想要的信号,使用场景----：比如-当多个输入框都有值的时候按钮才可点击。

```objc
// 思路--- 就是把输入框输入值的信号都聚合成按钮是否能点击的信号。
- (void)combineLatest {

RACSignal *combinSignal = [RACSignal combineLatest:@[self.accountField.rac_textSignal, self.pwdField.rac_textSignal] reduce:^id(NSString *account, NSString *pwd){ //reduce里的参数一定要和combineLatest数组里的一一对应。
// block: 只要源信号发送内容，就会调用，组合成一个新值。
NSLog(@"%@ %@", account, pwd);
return @(account.length && pwd.length);
}];

//    // 订阅信号
//    [combinSignal subscribeNext:^(id x) {
//        self.loginBtn.enabled = [x boolValue];
//    }];    // ----这样写有些麻烦，可以直接用RAC宏
RAC(self.loginBtn, enabled) = combinSignal;
}

```
```objc
- (void)zipWith {
//zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元祖，才会触发压缩流的next事件。
// 创建信号A
RACSubject *signalA = [RACSubject subject];
// 创建信号B
RACSubject *signalB = [RACSubject subject];
// 压缩成一个信号
// **-zipWith-**: 当一个界面多个请求的时候，要等所有请求完成才更新UI
// 等所有信号都发送内容的时候才会调用
RACSignal *zipSignal = [signalA zipWith:signalB];
[zipSignal subscribeNext:^(id x) {
NSLog(@"%@", x); //所有的值都被包装成了元组
}];

// 发送信号 交互顺序，元组内元素的顺序不会变，跟发送的顺序无关，而是跟压缩的顺序有关[signalA zipWith:signalB]---先是A后是B
[signalA sendNext:@1];
[signalB sendNext:@2];

}

```
```objc
// 任何一个信号请求完成都会被订阅到
// merge:多个信号合并成一个信号，任何一个信号有新值就会调用
- (void)merge {
// 创建信号A
RACSubject *signalA = [RACSubject subject];
// 创建信号B
RACSubject *signalB = [RACSubject subject];
//组合信号
RACSignal *mergeSignal = [signalA merge:signalB];
// 订阅信号
[mergeSignal subscribeNext:^(id x) {
NSLog(@"%@", x);
}];
// 发送信号---交换位置则数据结果顺序也会交换
[signalB sendNext:@"下部分"];
[signalA sendNext:@"上部分"];
}

```
```objc
// then --- 使用需求：有两部分数据：想让上部分先进行网络请求但是过滤掉数据，然后进行下部分的，拿到下部分数据
- (void)then {
// 创建信号A
RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
// 发送请求
NSLog(@"----发送上部分请求---afn");

[subscriber sendNext:@"上部分数据"];
[subscriber sendCompleted]; // 必须要调用sendCompleted方法！
return nil;
}];

// 创建信号B，
RACSignal *signalsB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
// 发送请求
NSLog(@"--发送下部分请求--afn");
[subscriber sendNext:@"下部分数据"];
return nil;
}];
// 创建组合信号
// then;忽略掉第一个信号的所有值
RACSignal *thenSignal = [signalA then:^RACSignal *{
// 返回的信号就是要组合的信号
return signalsB;
}];

// 订阅信号
[thenSignal subscribeNext:^(id x) {
NSLog(@"%@", x);
}];

}

```
```objc
// concat----- 使用需求：有两部分数据：想让上部分先执行，完了之后再让下部分执行（都可获取值）
- (void)concat {
// 组合

// 创建信号A
RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
// 发送请求
//        NSLog(@"----发送上部分请求---afn");

[subscriber sendNext:@"上部分数据"];
[subscriber sendCompleted]; // 必须要调用sendCompleted方法！
return nil;
}];

// 创建信号B，
RACSignal *signalsB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
// 发送请求
//        NSLog(@"--发送下部分请求--afn");
[subscriber sendNext:@"下部分数据"];
return nil;
}];


// concat:按顺序去链接
//**-注意-**：concat，第一个信号必须要调用sendCompleted
// 创建组合信号
RACSignal *concatSignal = [signalA concat:signalsB];
// 订阅组合信号
[concatSignal subscribeNext:^(id x) {
NSLog(@"%@",x);
}];

}

```
#### RAC+MVVM-网络请求
**请看demo**











