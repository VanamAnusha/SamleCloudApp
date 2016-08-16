//
//  ImageViewController.mß
//  SamleCloudApp
//
//  Created by Anusha on 6/3/16.
//  Copyright © 2016 Anusha. All rights reserved.
//

#import "ImageViewController.h"
#import <CloudKit/CloudKit.h>

@interface ImageViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>
{
    UIActivityIndicatorView *activityView;
}
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end

@implementation ImageViewController

#pragma mark - View life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setCenter:self.view.center];
    [self.view addSubview:activityView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button action methods

- (IBAction)tapOnImage:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
        [actionSheet dismissViewControllerAnimated:YES completion:nil];

    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Upload Photo" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self uploadPhoto];
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}


#pragma mark - Cloud kit Saving method

/*!
 * @abstract saving user entered details into cloud kit containers
 * @param nil
 * @return nil
 */

- (IBAction)saveDetails:(id)sender
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
    NSData *imageData = UIImageJPEGRepresentation(self.image.image, 0.8);
    NSString *imagePath = [path stringByAppendingPathComponent:@"TempImage.png"];
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
    [imageData writeToURL:imageURL atomically:YES];
    
    NSString *timeStampString = [NSString stringWithFormat:@"%f",[NSDate timeIntervalSinceReferenceDate]];
    CKRecordID *recordId = [[CKRecordID alloc] initWithRecordName:[timeStampString componentsSeparatedByString:@"."][0]];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Notes" recordID:recordId];
    [record setObject:self.nameTextfield.text forKey:@"name"];
    [record setObject:self.descriptionTextView.text forKey:@"description"];
    CKAsset *asset = [[CKAsset alloc] initWithFileURL:imageURL];
    [record setObject:asset forKey:@"image"];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CourseDataModel" ofType:@"plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString *storePlistPath = [path stringByAppendingPathComponent:@"CourseDataModel.Plist"];
    [data writeToFile:storePlistPath atomically:YES];
    NSURL *plistUrl = [NSURL fileURLWithPath:storePlistPath];
    CKAsset *plistAsset = [[CKAsset alloc] initWithFileURL:plistUrl];
    [record setObject:plistAsset forKey:@"plist"];
    
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = container.privateCloudDatabase;
    [activityView startAnimating];
    [database saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        [activityView stopAnimating];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                NSLog(@"error:%@",(error));
                [self showAlertControllerWithText:error.description];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
    }];
}


#pragma mark - UIImagePickerController methods

-(void)takePhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

-(void)uploadPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.image.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


#pragma mark - UITextField Delegate Method

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

@end
