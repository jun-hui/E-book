//
//  BookNamesTableViewController.m
//  E-book
//
//  Created by 小王 on 2017/4/5.
//  Copyright © 2017年 小王. All rights reserved.
//

#import "BookNamesTableViewController.h"
#import "ReadBookViewController.h"

@interface BookNamesTableViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation BookNamesTableViewController


-(void)viewWillAppear:(BOOL)animated
{
    self.tableView.delegate = self;
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.tableView.delegate = nil;
    [super viewDidDisappear:animated];
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"盗墓笔记.txt";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        [self loadBookNames];
    }
    return _dataArray;
}

-(void)loadBookNames
{
    NSString *baseSavePath = [[NSBundle mainBundle] bundlePath]; // 要列出来的目录
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *myDirectoryEnumerator = [fileManager enumeratorAtPath:baseSavePath];  //baseSavePath 为文件夹的路径
    
    _dataArray = [NSMutableArray arrayWithCapacity:0];//用来存目录名字的数组
    NSString *file;
    
    while((file = [myDirectoryEnumerator nextObject]))     //遍历当前目录
      {
        
        if([[file pathExtension] isEqualToString:@"txt"])  //取得后缀名为.xml的文件名
          {
            
            [_dataArray addObject:file];//文件名存到数组
          }
      }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ReadBookViewController *readVC = [[ReadBookViewController alloc] init];
    readVC.bookName = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:readVC animated:YES];
}




@end
