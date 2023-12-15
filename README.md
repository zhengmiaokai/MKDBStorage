# MKDBStorage 

基于FMDB的数据库组件封装，通过传入DBModel与对应的tableName，实现数据表的创建，到增删改查等数据表的操作。

使用说明：具体实现参考demo中的ViewController

```objective-c
/* kv储存 */
for (int i=0; i<500; i++) {
    [[MKKVStorage sharedInstance] saveDataWithValue:@"233333" forKey:[NSString stringWithFormat:@"%dsfsdfsdf", i]];
}
    
[[MKKVStorage sharedInstance] getValueForKey:[NSString stringWithFormat:@"%dsfsdfsdf", 0] completion:^(id  _Nonnull response) {
    
}];
```

```objective-c
/* MKTestDBModel 继承于 MKDBModel；MKTestDBStorage 继承于 MKDBStorage */
MKTestDBStorage* testDB = [[MKTestDBStorage alloc] initWithDbName:@"test.db" gcdQueue:nil];
[testDB saveData:^(BOOL success) {
        
}];
[testDB selectData:^(NSArray *datas) {
        
}];
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
