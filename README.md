# E-book
好用的电子书阅读
==
效果图：
-- 
![image](https://github.com/jun-hui/SmoothSwitchNavigationBar/blob/master/%E6%95%88%E6%9E%9C%E5%9B%BE.gif)

使用方法：
--
1.无需多余代码

2.只需将 SmoothSwitchNavigationBar/SmoothSwitchNavigationBar/SmoothSwitchNavigationBar 文件夹导入到工程

3.在 viewWillAppear 里设置上颜色和透明度即可：

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    
    self.navBarBgAlpha = @"1.0";
    
}
