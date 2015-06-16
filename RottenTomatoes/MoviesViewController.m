//
//  MoviesViewController.m
//  RottenTomatoes
//
//  Created by Saker Lin on 2015/6/13.
//  Copyright (c) 2015年 Saker Lin. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "ViewController.h"
#import <UIImageView+AFNetworking.h>
#import "SVProgressHUD.h"

@interface MoviesViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@end

@implementation MoviesViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)showNetworkError{
    UIView *netWorkErrorview = [[UIView alloc]
                    initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 25)];
    netWorkErrorview.backgroundColor = [UIColor colorWithRed:0.5 green:0.6 blue:0.9 alpha:0.5];
    UILabel *label = [[UILabel alloc]
                           initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 25)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"⚠️ Network error";
    label.textColor = [UIColor redColor];
    [netWorkErrorview addSubview:label];
    self.tableView.tableHeaderView = netWorkErrorview;
}
- (void)hideNetworkError{
    self.tableView.tableHeaderView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //pull to refersh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self updateTable];
}
- (void)updateTable{
    
    [SVProgressHUD showWithStatus:@"Loading movies..." maskType:SVProgressHUDMaskTypeBlack];
    //NSString *apiURLString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=92y6xsdanxph55tqaaackxjp";
    NSString *apiURLString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=40&country=us";
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString: apiURLString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError == nil) {
             NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             self.movies = dict[@"movies"];
             [self.tableView reloadData] ;
             [self hideNetworkError];
         } else {
             [self showNetworkError];
         }
         [SVProgressHUD dismiss];
     }];
}

- (void)refresh:(id)sender  {
    NSLog(@"refresh");
    [self updateTable];
    [(UIRefreshControl *)sender endRefreshing];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
};
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.movies.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyMovieCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"synopsis"];
    NSString *posterURLString = [movie valueForKeyPath:@"posters.thumbnail"];
    //[cell.posterView setImageWithURL:[NSURL URLWithString:posterURLString]];
    //NSLog(@"Row %@", posterURLString);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: posterURLString]];
    [cell.posterView setImageWithURLRequest:request
                           placeholderImage:nil
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            //Fade animation
                                            [UIView transitionWithView:cell.posterView
                                                              duration:1.0f
                                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                                            animations:^{[cell.posterView setImage:image];}
                                                            completion:NULL];
                                        
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        NSLog(@"fail");
                                    }
     ];

    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // Do any additional setup after loading the view, typically from a nib.
   }


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MovieCell *cell = sender;
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    NSDictionary *movie = self.movies[indexpath.row];
    ViewController *destinationVC = segue.destinationViewController;
    destinationVC.movie = movie;
}


@end
