//
//  CatalogCollectionViewController.m
//  E-book
//
//  Created by 小王 on 2017/4/5.
//  Copyright © 2017年 小王. All rights reserved.
//

#import "CatalogCollectionViewController.h"
#import "BookViewCell.h"
#import "BookNamesTableViewController.h"

@interface CatalogCollectionViewController ()

@end

@implementation CatalogCollectionViewController

static NSString *const reuseIdentifier = @"Cell";
static CGFloat   const leading         = 0.f;
static NSInteger const sectionNum      = 3;

- (instancetype)init
{
    //创建一个 layout 布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake((ScreenWidth - leading*(sectionNum+1))/sectionNum, 120);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //两个cell之间的间距（同一行的cell的间距）
    layout.minimumInteritemSpacing = 0;
    //两行cell之间的间距（上下行cell的间距）
    layout.minimumLineSpacing = 0;
    //头部大小
    layout.headerReferenceSize = CGSizeMake(ScreenWidth, 0);
    
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shelf_row"]];
    // Register cell classes
    UINib *cellNib = [UINib nibWithNibName:bookCellID bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:bookCellID];
    
    [self setNaviItem];
}

-(void)setNaviItem
{
    self.navigationItem.title = @"书架";
    
    UIImage* image = [UIImage imageNamed:@"button.png"];
    CGRect frame = CGRectMake(0, 0, 75, 25);
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:frame];
    [leftButton setBackgroundImage:image forState:UIControlStateNormal];
    [leftButton setTitle:@"推荐" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [leftButton addTarget:self action:@selector(doComment:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:frame];
    [rightButton setBackgroundImage:image forState:UIControlStateNormal];
    [rightButton setTitle:@"列表" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightButton addTarget:self action:@selector(doComment:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)doComment:(UIButton *)button
{
    BookNamesTableViewController *BookNamesVC = [[BookNamesTableViewController alloc] init];
    [self.navigationController pushViewController:BookNamesVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 30;
}

- (BookViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BookViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:bookCellID forIndexPath:indexPath];
    
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSString *seleStr = [NSString stringWithFormat:@"点击了：第 %d 行-第 %d 个",(int)(indexPath.row)/3+1,(int)(indexPath.row)%3+1];
    
    [DKProgressHUD showStatus:seleStr toView:self.view];
}


/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
