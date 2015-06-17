//
//  tabBarController.m
//  RottenTomatoes
//
//  Created by Saker Lin on 2015/6/17.
//  Copyright (c) 2015年 Saker Lin. All rights reserved.
//

#import "tabBarController.h"

@interface tabBarController () <UITabBarControllerDelegate>

@end

@implementation tabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
    self.title = @"Movies";
      
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 1) {
        self.title = @"DVDs";
    } else {
        self.title = @"Movies";
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
