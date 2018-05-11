//
//  CollectionView.m
//  MBProgressHUD
//
//  Created by Trung Pham on 5/11/18.
//

#import "CollectionView.h"
#import "ViewLib.h"
#import "QUIBuilder.h"

@implementation CollectionView

-(instancetype)init{
    self = [super init];
    return self;
}

-(void)initUI
{
    //collectionview
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setScrollDirection: self.isScrollDirectionHorizontal ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical];
    [flow setItemSize: self.itemSize];
    [flow setMinimumInteritemSpacing: self.itemSpacing];
    [flow setMinimumLineSpacing: self.lineSpacing];
    [flow setSectionInset: self.sectionInset];
    
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:flow];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.allowsMultipleSelection = NO;
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    
    [self addSubview: _collectionView];
    
    [ViewLib updateLayoutForView:_collectionView superEdge:@"L0R0T0B0" otherEdge:nil];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemData.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    NSString* item = [self.itemData objectAtIndex:indexPath.row];
    
    for (UIView* view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if ([FileLib checkPathExisted:item]) {
        [QUIBuilder rebuildUIWithFile:item containerView:cell.contentView errorBlock:^(NSString *msg, NSException *exception) {
            NSLog(@"%@ %@", msg, exception);
        }];
    }else{
        [QUIBuilder rebuildUIWithContent:item containerView:cell.contentView errorBlock:^(NSString *msg, NSException *exception) {
            NSLog(@"%@ %@", msg, exception);
        }];
    }
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.itemSelectedBlock) return;
    self.itemSelectedBlock(indexPath.row);
}



@end
