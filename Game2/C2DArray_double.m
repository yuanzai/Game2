#import "C2DArray_double.h"

@implementation C2DArray_double{
    NSInteger* matrix_;
    NSUInteger columnCount_;
    NSUInteger rowCount_;
}

- (id)initWithRows:(NSUInteger)initRowCount Columns:(NSUInteger)initColumnCount {
    self = [super init];
    if(self) {
        rowCount_ = initRowCount;
        columnCount_ = initColumnCount;
        matrix_ = malloc(sizeof(int)*rowCount_*columnCount_);

        uint i;
        for(i = 0; i < rowCount_*columnCount_; ++i) {
            matrix_[i] = 0;
        }
    }
    return self;
}

- (void)dealloc {
    free(matrix_);
    [super dealloc];
}

- (NSUInteger)rowCount {
    return rowCount_;
}

- (NSUInteger)columnCount {
    return columnCount_;
}

- (double)valueAtRow:(NSUInteger)rowIndex Column:(NSUInteger)columnIndex 
{
    return matrix_[rowIndex*columnCount_+columnIndex];
}
- (void)setValue:(double)value atRow:(NSUInteger)rowIndex Column:(NSUInteger)columnIndex 
{
    matrix_[rowIndex*columnCount_+columnIndex] = value;
}

@end
