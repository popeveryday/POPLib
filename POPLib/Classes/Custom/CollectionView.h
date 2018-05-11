//
//  CollectionView.h
//  MBProgressHUD
//
//  Created by Trung Pham on 5/11/18.
//

#import <UIKit/UIKit.h>

@interface CollectionView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
//item is qui content or patch to qui file
@property (nonatomic) NSArray* itemData;
@property (nonatomic) UICollectionView* collectionView;

@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat itemSpacing;
@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) UIEdgeInsets sectionInset;
@property (nonatomic) BOOL isScrollDirectionHorizontal;

@property (nonatomic) void (^itemSelectedBlock)(NSInteger index);

-(void) initUI;


@end
