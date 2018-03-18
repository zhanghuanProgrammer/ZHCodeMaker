#import <Foundation/Foundation.h>

@interface NSObject (ZH)

#pragma mark - Swap method (Swizzling)
/**交换类的实例方法*/
+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;
/**交换类的类方法*/
+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;

/**打印类名*/
+ (NSString *)className;

/**打印类名*/
- (NSString *)className;

/**深度复制自身(原理是通过归档自己,所以前提是需要遵循NSCoding协议)*/
- (id)deepCopy;

/**添加关联对象(strong类型的)*/
- (void)setAssociateValue:(id)value withKey:(void *)key;

/**添加关联对象(weak类型的)*/
- (void)setAssociateWeakValue:(id)value withKey:(void *)key;

/**移除关联对象*/
- (void)removeAssociatedValues;

/**获取关联对象*/
- (id)getAssociatedValueForKey:(void *)key;

/**延迟delay时间间隔执行自身的Selector:sel函数*/
- (void)performSelector:(SEL)sel afterDelay:(NSTimeInterval)delay;

/**在主线程执行自己的某个函数,可以传很多参数*/
- (id)performSelectorWithArgs:(SEL)sel, ...;

/**在后台线程执行自己的某个函数,可以传很多参数*/
- (void)performSelectorWithArgsInBackground:(SEL)sel, ...;

/**在主线程延迟 delay 执行自己的某个函数,可以传很多参数*/
- (void)performSelectorWithArgs:(SEL)sel afterDelay:(NSTimeInterval)delay, ...;

@end
