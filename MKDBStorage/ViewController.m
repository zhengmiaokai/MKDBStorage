//
//  ViewController.m
//  MKDBStorage
//
//  Created by mikazheng on 2021/4/20.
//

#import "ViewController.h"
#import "MKKVOStorage.h"
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
        [[MKKVOStorage sharedInstance] saveDataWithValue:@"233333" forKey:[NSString stringWithFormat:@"%dsfsdfsdf", i]];
    }
    
    [[MKKVOStorage sharedInstance] getValueForKey:[NSString stringWithFormat:@"%dsfsdfsdf", 0] completion:^(id  _Nonnull response) {
        
    }];
    
    /*工具 + model
     MKTestDBModel 继承于 MKDBModel
     MKTestDBStorage 继承于 MKDBStorage
     */
    MKTestDBStorage* otherDataBase = [[MKTestDBStorage alloc] initWithDbName:@"dataBase" gcdQueue:nil];
    [otherDataBase saveData];
    [otherDataBase selectData];
    
    MKArchivesDoubleModel * data = [MKArchivesDoubleModel new];
    data.nihao = @"sdf";
    data.dajiahao = @"sdfsdf";
    data.nihaoA = @"sdf";
    data.dajiahaoA = @"sdfsdf";
    data.wohao = @"sdf";
    data.tahao = @"sdfsdf";
    [data save_and_find];
}


@end
