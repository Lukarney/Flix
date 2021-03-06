//
//  MoviesViewController.m
//  Flix
//
//  Created by Luke Arney on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"
#import "Reachability.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
//automatically create getter and setter getMovies and setMovies
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //loading
    // Start the activity indicator
    [self.activityIndicator startAnimating];
    
    [self setReachabilityNotif];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Do any additional setup after loading the view.
    [self fetchMovies];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    

    
    
}

- (void)fetchMovies {
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSLog(@"%@", dataDictionary);
               
               self.movies = dataDictionary[@"results"];
               for (NSDictionary *movie in self.movies){
                   NSLog(@"%@", movie[@"title"]);
               }
               // call data source methods again because it may have changed
               [self.tableView reloadData];
               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
           }
        [self.refreshControl endRefreshing];
        // Stop the activity indicator
        // Hides automatically if "Hides When Stopped" is enabled
        [self.activityIndicator stopAnimating];
        
       }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
//configures rows
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie [@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    
    //    cell.textLabel.text = movie[@"title"];
    
    return cell;
}

- (void)showAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Bad Connection"
        message:@"Cannot get movies. The internet connections is offline"
        preferredStyle:(UIAlertControllerStyleAlert)];
    
    // create a cancel action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                style:UIAlertActionStyleCancel
            handler:^(UIAlertAction * _Nonnull action) {
    // handle cancel response here. Doing nothing will dismiss the view.
                                                      }];
    // add the cancel action to the alertController
    [alert addAction:cancelAction];

    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                // handle response here.
                                                     }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}

- (void) setReachabilityNotif{
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];

    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:

        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
        });
    };

    reach.unreachableBlock = ^(Reachability*reach)
    {
        
        NSLog(@"UNREACHABLE!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert];

        });
    };

    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
    }


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
    NSLog(@"Tapping on a movie!");
}


@end
