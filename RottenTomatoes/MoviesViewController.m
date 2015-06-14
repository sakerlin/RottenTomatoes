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
#import "AFNetworking.h"
#import "UIAlertView+NSErrorAddition.h"
#import "Reachability.h"
#import "SVProgressHUD.h"

@interface MoviesViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@end

@implementation MoviesViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)handleNotification:(NSNotification *)notif
{
    [SVProgressHUD showWithStatus:@"Loading picker..."];
    NSLog(@"Notification recieved: %@", notif.name);
    NSLog(@"Status user info key: %@", [notif.userInfo objectForKey:SVProgressHUDStatusUserInfoKey]);
    [SVProgressHUD show];
}

- (void)show {
    [SVProgressHUD show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //pull to refersh
   // UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    //[refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    //[self.tableView addSubview:refreshControl];
    // Initialize Refresh Control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];

    
    //network check use Reachability
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //alert use UIAlertView-NSErrorAddition
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey : @"Network Error",
                               NSLocalizedFailureReasonErrorKey : @"Doesn't connect to network",
                               NSLocalizedRecoverySuggestionErrorKey : @"Please check the network.",
                               NSLocalizedRecoveryOptionsErrorKey : @[@"OK"]
                               };
    
    NSError *error = [NSError errorWithDomain:[[NSBundle bundleForClass:[self class]] bundleIdentifier] code:0 userInfo:userInfo];
    UIAlertView *alertView = [[UIAlertView alloc] initWithError:error];
    
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        [alertView show];
    } else {
        [SVProgressHUD showWithStatus:@"Loading movies..." maskType:SVProgressHUDMaskTypeBlack];
        NSLog(@"There IS internet connection");
        [self updateTable];
        [SVProgressHUD dismiss];
    }
    
}
- (void)updateTable{
    //NSString *apiURLString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=92y6xsdanxph55tqaaackxjp";
    NSLog(@"loadMovies");
    NSString *apiURLString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us";
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString: apiURLString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         self.movies = dict[@"movies"];
         [self.tableView reloadData] ;
     }];
}

- (void)refresh:(id)sender  {
    // Do your job, when done:
    NSLog(@"refresh");

    [self updateTable];
    [(UIRefreshControl *)sender endRefreshing];
    //[refreshControl endRefreshing];
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
    [cell.posterView setImageWithURL:[NSURL URLWithString:posterURLString]];
    //NSLog(@"Row %@", posterURLString);
    
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
