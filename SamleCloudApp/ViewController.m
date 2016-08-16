//
//  ViewController.m
//  SamleCloudApp
//
//  Created by Anusha on 6/3/16.
//  Copyright © 2016 Anusha. All rights reserved.
//

#import "ViewController.h"
#import "ImageViewController.h"
#import "UpdatesTableViewCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *recordsArray;
    UIActivityIndicatorView *activityView;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

#pragma mark - View life cycle methods

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    recordsArray = [NSMutableArray array];
    [self.navigationController setNavigationBarHidden:YES];
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setCenter:self.view.center];
    [self.view addSubview:activityView];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (IBAction)pushToAddScreen:(id)sender {
    ImageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Cloud data fetching method
/*!
 * @abstract fetching records data from cloud kit container
 * @param nil
 * @return nil
 */

-(void)fetchData
{
    [recordsArray removeAllObjects];
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = container.privateCloudDatabase;
    NSPredicate *predicate = [NSPredicate predicateWithValue:true];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Notes" predicate:predicate];
    [activityView startAnimating];
    [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        [activityView stopAnimating];
        if (error != nil) {
            NSLog(@"error:%@",(error));
            [self showAlertControllerWithText:error.description];
        }
        else {
            NSLog(@"results:%@",results);
            for (CKRecord *record in results) {
                [recordsArray addObject:record];
            }
            [self.tableView reloadData];
        }
    }];
    
}

#pragma mark - UIAlertController method
/*!
 * @abstract show alert with given text as message
 * @param text message of alert
 * @return nil
 */

-(void)showAlertControllerWithText:(NSString *)text
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:text preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableView delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return recordsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"cellIdentifier";
    UpdatesTableViewCell *cell = (UpdatesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor clearColor]];
    CKRecord *record = recordsArray[indexPath.row];
    [cell.linkLabel setText:[record valueForKey:@"name"]];
    [cell.descriptionLabel setText:[record valueForKey:@"description"]];
    CKAsset *asset = [record valueForKey:@"image"];
    [cell.icon setImage:[UIImage imageWithContentsOfFile:asset.fileURL.path]];
    return cell;
}

@end
