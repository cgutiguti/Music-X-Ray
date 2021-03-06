//
//  AffinitiesViewController.h
//  Bounce
//
//  Created by Carmen Gutierrez on 7/23/20.
//  Copyright © 2020 Carmen Gutierrez. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AffinitiesViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *tracksData;
@property (nonatomic, strong) NSMutableArray<NSString *> *genresData;
@property (nonatomic, strong) NSMutableArray<NSString *> *artistsData;
@property (nonatomic, strong) NSString *accessToken;
@end

NS_ASSUME_NONNULL_END
