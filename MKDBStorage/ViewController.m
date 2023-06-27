//
//  ViewController.m
//  MKDBStorage
//
//  Created by mikazheng on 2021/4/20.
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
    
    /* 储存 */
    for (int i=0; i<500; i++) {
        [[MKKVStorage sharedInstance] saveDataWithValue:@"233333" forKey:[NSString stringWithFormat:@"%dsfsdfsdf", i]];
    }
    
    [[MKKVStorage sharedInstance] getValueForKey:[NSString stringWithFormat:@"%dsfsdfsdf", 0] completion:^(id  _Nonnull response) {
        
    }];
    
    /*工具 + model
     MKTestDBModel 继承于 MKDBModel
     MKTestDBStorage 继承于 MKDBStorage
     */
    MKTestDBStorage* otherDataBase = [[MKTestDBStorage alloc] initWithDbName:@"test.db" gcdQueue:nil];
    [otherDataBase saveData];
    [otherDataBase selectData];
    
    /* 基类实现了 NSCoding/NSCoping 协议 */
    MKArchivesDoubleModel * data = [MKArchivesDoubleModel new];
    data.nihao = @"sdf";
    data.dajiahao = @"sdfsdf";
    data.nihaoA = @"sdf";
    data.dajiahaoA = @"sdfsdf";
    data.wohao = @"sdf";
    data.tahao = @"sdfsdf";
    data.intNumber = 1;
    data.floatNumber = 1.1;
    
    MKPropertyA* propertyA = [MKPropertyA new];
    propertyA.a = @"s";
    propertyA.b = @"d";
    data.propertyA = propertyA;
    
    [data save_and_find];
    
    MKArchivesDoubleModel * dataCopy = [data copy];
    NSLog(@"data-copy: %@", dataCopy);
}


@end
