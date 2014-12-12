#import <Cocoa/Cocoa.h>
@interface AOMatrix : NSObject 

- (id)initWithRows:(NSUInteger)rowCount Columns:(NSUInteger)columnCount;

- (NSUInteger)rowCount;
- (NSUInteger)columnCount;

- (NSInteger)valueAtRow:(NSUInteger)rowIndex Column:(NSUInteger)columnIndex;
- (void)setValue:(NSInteger)value atRow:(NSUInteger)rowIndex Column:(NSUInteger)columnIndex;

@end
