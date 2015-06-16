//
//  ViewController.m
//  RottenTomatoes
//
//  Created by Saker Lin on 2015/6/13.
//  Copyright (c) 2015年 Saker Lin. All rights reserved.
//

#import "ViewController.h"
#import <UIImageView+AFNetworking.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text =  self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"synopsis"];
    NSString *lowResImg = [self.movie valueForKeyPath:@"posters.original"];
    NSString *hightResImg = [self convertPosterUrlStringToHighRes:lowResImg];
    
    UIImage *placeHolderImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: lowResImg]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: hightResImg]];
    [self.posterView setImageWithURLRequest:request
                           placeholderImage:placeHolderImage
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        if (request) {
                                            //Fade animation
                                            [UIView transitionWithView:self.posterView
                                                              duration:2.0f
                                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                                            animations:^{[self.posterView setImage:image];}
                                                            completion:NULL];
                                        }
                                        
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        NSLog(@"fail");
                                    }
     
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//helper to workaround rotten tomatoes giving low res images.
- (NSString *)convertPosterUrlStringToHighRes:(NSString *)urlString {
    NSRange range = [urlString rangeOfString:@".*cloudfront.net/" options:NSRegularExpressionSearch];
    NSString *returnValue = urlString;
    if (range.length > 0) {
        returnValue = [urlString stringByReplacingCharactersInRange:range withString: @"https://content6.flixster.com/"];
    }
    return returnValue;
}
@end
