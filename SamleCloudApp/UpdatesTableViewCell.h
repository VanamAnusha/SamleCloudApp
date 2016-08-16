//
//  UpdatesTableViewCell.h
//  SamleCloudApp
//
//  Created by Anusha on 8/11/16.
//  Copyright © 2016 Anusha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdatesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@end
