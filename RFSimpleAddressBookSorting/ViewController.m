//
//  ViewController.m
//  RFSimpleAddressBookSorting
//
//  Created by Raywf on 2018/3/19.
//  Copyright © 2018年 S.Ray. All rights reserved.
//

#import "ViewController.h"
#import "RFSimpleAddressBookSortingView.h"

@interface ViewController ()
{
    RFSimpleAddressBookSortingView *_sortingView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.title = @"AddressBookSorting";
    self.view.backgroundColor = [UIColor lightGrayColor];

    [self customUI];
}

- (void)customUI {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Switch"
                                              style:UIBarButtonItemStyleDone target:self
                                              action:@selector(switchBtnClick:)];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"FullIndex"
                                              style:UIBarButtonItemStyleDone target:self
                                              action:@selector(fullIndexBtnClick:)];

    //CGFloat width = [UIScreen mainScreen].bounds.size.width;
    //CGFloat height = [UIScreen mainScreen].bounds.size.height;

    CGRect frame = self.view.bounds;
    RFSimpleAddressBookSortingView *sortingView = [[RFSimpleAddressBookSortingView alloc]
                                                   initWithFrame:frame];
    [self.view addSubview:sortingView];
    _sortingView = sortingView;
}

- (void)switchBtnClick:(UIButton *)sender {
    UIAlertController *alertCtr = [UIAlertController
                                   alertControllerWithTitle:nil message:nil
                                   preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"CN" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        [_sortingView reloadDataViaSwitchType:0];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"KR" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        [_sortingView reloadDataViaSwitchType:1];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                               handler:nil]];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

- (void)fullIndexBtnClick:(UIButton *)sender {
    UIAlertController *alertCtr = [UIAlertController
                                   alertControllerWithTitle:nil message:nil
                                   preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Fitable" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        [_sortingView reloadDataViaFitableType:0];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Full" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        [_sortingView reloadDataViaFitableType:1];
    }]];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                               handler:nil]];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
