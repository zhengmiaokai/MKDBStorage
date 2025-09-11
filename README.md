# MKDBStorage 

基于FMDB的数据库组件封装，通过传入DBModel与对应的tableName，实现数据表的创建，到增删改查等数据表的操作。

使用说明：具体实现参考demo中的ViewController

```objective-c
/* kv储存 */
for (int i=0; i<500; i++) {
    [[MKKVStorage sharedInstance] saveDataWithValue:@"2333" forKey:[NSString stringWithFormat:@"key_%d", i]];
}
    
[[MKKVStorage sharedInstance] getValueForKey:@"key_1" completion:^(NSString *value) {
    NSLog(@"key-value: %@", value);
}];
```

```objective-c
/* MKTestDBModel 继承于 MKDBModel；MKTestDBStorage 继承于 MKDBStorage */
MKTestDBStorage* testStorage = [[MKTestDBStorage alloc] init];
[testStorage insertDatas:^(BOOL success) { }];
[testStorage selectDatas:^(NSArray *datas) { }];
[testStorage deleteDatas:^(BOOL success) { }];
```
```objective-c
/* 基类实现了 NSCoding/NSCoping 协议 */
MKArchivesDoubleModel * archivesData = [[MKArchivesDoubleModel alloc] init];
archivesData.title = @"title";
archivesData.detail = @"detail";
archivesData.intValue = 27;
archivesData.floatValue = 1.01;
    
MKPropertyModel* property = [[MKPropertyModel alloc] init];
property.content = @"content";
archivesData.property = property;
    
[archivesData saveData];
[archivesData selectData];
    
MKArchivesDoubleModel * dataCopy = [archivesData copy];
NSLog(@"data-copy: %@", dataCopy);
```
