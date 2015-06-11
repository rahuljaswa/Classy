//
//  RJGalleryViewController.h
//  FitnessClasses
//
//  Created by Rahul Jaswa on 5/6/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RJGalleryCell;

@interface RJGalleryViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) BOOL spaced;
@property (nonatomic, assign) CGFloat itemsPerRow;

- (void)configureCell:(RJGalleryCell *)galleryCell indexPath:(NSIndexPath *)indexPath;

- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection;

@end
