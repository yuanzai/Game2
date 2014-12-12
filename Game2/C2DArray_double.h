#import <Foundation/Foundation.h>
@interface C2DArray_double : NSObject 

- (id)initWithRows:(NSUInteger)rowCount Columns:(NSUInteger)columnCount;

- (NSUInteger)rowCount;
- (NSUInteger)columnCount;

- (double)valueAtRow:(NSUInteger)rowIndex Column:(NSUInteger)columnIndex;
- (void)setValue:(double)value atRow:(NSUInteger)rowIndex Column:(NSUInteger)columnIndex;

@end
