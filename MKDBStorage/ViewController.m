//
//  ViewController.m
//  MKDBStorage
//
//  Created by zhengmiaokai on 2021/4/20.
//

#import "ViewController.h"
#import "MKKVStorage.h"
#import "MKTestDBStorage.h"
#import "MKArchivesDoubleModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* kv储存 */
    for (int i=0; i<500; i++) {
        [[MKKVStorage sharedInstance] saveDataWithValue:@"233333" forKey:[NSString stringWithFormat:@"%dsfsdfsdf", i]];
    }
    
    [[MKKVStorage sharedInstance] getValueForKey:[NSString stringWithFormat:@"%dsfsdfsdf", 0] completion:^(id  _Nonnull response) {
        
    }];
    
    /* MKTestDBModel 继承于 MKDBModel；MKTestDBStorage 继承于 MKDBStorage */
    MKTestDBStorage* testDB = [[MKTestDBStorage alloc] initWithDbName:@"test.db" gcdQueue:nil];
    [testDB saveData:^(BOOL success) {
        
    }];
    [testDB selectData:^(NSArray *datas) {
        
    }];
    
    /* 基类实现了 NSCoding/NSCoping 协议 */
    MKArchivesDoubleModel * archivesData = [[MKArchivesDoubleModel alloc] init];
    archivesData.nihao = @"sdf";
    archivesData.dajiahao = @"sdfsdf";
    archivesData.nihaoA = @"sdf";
    archivesData.dajiahaoA = @"sdfsdf";
    archivesData.wohao = @"sdf";
    archivesData.tahao = @"sdfsdf";
    archivesData.intNumber = 1;
    archivesData.floatNumber = 1.1;
    
    MKPropertyA* propertyA = [MKPropertyA new];
    propertyA.a = @"s";
    propertyA.b = @"d";
    archivesData.propertyA = propertyA;
    
    [archivesData saveData];
    [archivesData selectData];
    
    MKArchivesDoubleModel * dataCopy = [archivesData copy];
    NSLog(@"data-copy: %@", dataCopy);
}

@end
