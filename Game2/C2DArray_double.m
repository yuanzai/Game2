

#import "C2DArray_double.h"

@implementation C2DArray_double
- (id)initWithRows:(NSUInteger)initRowCount Columns:(NSUInteger)initColumnCount {
    self = [super init];
    if(self) {
        rowCount_ = initRowCount;
        columnCount_ = initColumnCount;
        matrix = malloc(sizeof(double)*rowCount_*columnCount_);

        /*uint i;
        for(i = 0; i < rowCount_*columnCount_; ++i) {
            matrix[i] = 0;
        }*/
    }
    return self;
}


- (void)dealloc {
    free(matrix);
}


- (NSUInteger)rowCount {
    return rowCount_;
}

- (NSUInteger)columnCount {
    return columnCount_;
}

- (double)valueAtRow:(NSUInteger)rowIndex Column:(NSUInteger)columnIndex 
{
    return matrix[rowIndex*columnCount_+columnIndex];
}
- (void)setValue:(double)value atRow:(NSUInteger)rowIndex Column:(NSUInteger)columnIndex 
{
    matrix[rowIndex*columnCount_+columnIndex] = value;
}

@end
