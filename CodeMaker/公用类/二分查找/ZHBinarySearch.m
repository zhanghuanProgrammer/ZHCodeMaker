#import "ZHBinarySearch.h"

@interface ZHBinarySearch ()
@property (nonatomic,strong)NSMutableArray *dataArr;
@end

@implementation ZHBinarySearch

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr=[NSMutableArray array];
    }
    return _dataArr;
}

- (void)sort{
    [self.dataArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *str1=obj1,*str2=obj2;
        return [str1 compare:str2 options:(NSLiteralSearch)];
    }];
}

- (void)setOriginalData:(NSArray *)data{
    [self.dataArr addObjectsFromArray:data];
    [self sort];
}

/**二分查找(判断是不是白名单)*/
- (BOOL)binarySearch:(NSString *)target{
    NSInteger low=0;
    NSInteger high=self.dataArr.count-1;
    
    while(low<=high){
        
        NSInteger middle=(high+low)/2;
        NSInteger outcome=[target compare:self.dataArr[middle] options:(NSLiteralSearch)];
        if(outcome==0){
            return YES;
        }else if(outcome==-1){
            high=middle-1;
        }else if(outcome==1){
            low=middle+1;
        }
    }
    
    return NO;
}

- (BOOL)binaryInsert:(NSString *)target{
    
    if (self.dataArr.count==0) {
        [self.dataArr addObject:target];
        return YES;
    }
    
    NSInteger low=0;
    
    NSInteger high=self.dataArr.count-1;
    
    NSInteger insertIndex=0;
    NSInteger lastCompare=0;
    
    NSInteger middle=0;
    
    while(low<=high){
        
        middle=(high+low)/2;
        NSInteger outcome=[target compare:self.dataArr[middle] options:(NSLiteralSearch)];
        if(outcome==0){
            return NO;
        }else if(outcome==-1){
            high=middle-1;
            lastCompare=-1;
            insertIndex=high;
        }else{
            low=middle+1;
            insertIndex=low;
            lastCompare=1;
        }
    }
    
    if(lastCompare==-1)insertIndex++;
    [self.dataArr insertObject:target atIndex:insertIndex];
    
    return YES;
}

@end
