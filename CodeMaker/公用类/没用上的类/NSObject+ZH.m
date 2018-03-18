#import "NSObject+ZH.h"
#import <objc/runtime.h>

@implementation NSObject (ZH)

/**交换类的类方法*/
+ (BOOL)swizzleClassMethod:(SEL)originalSel with:(SEL)newSel {
    Class class = object_getClass(self);
    Method originalMethod = class_getInstanceMethod(class, originalSel);
    Method newMethod = class_getInstanceMethod(class, newSel);
    if (!originalMethod || !newMethod) return NO;
    method_exchangeImplementations(originalMethod, newMethod);
    return YES;
}

/**交换类的实例方法*/
+ (BOOL)swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel {
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    class_addMethod(self,
                    originalSel,
                    class_getMethodImplementation(self, originalSel),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(self,
                    newSel,
                    class_getMethodImplementation(self, newSel),
                    method_getTypeEncoding(newMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
                                   class_getInstanceMethod(self, newSel));
    return YES;
}

/**打印类名*/
+ (NSString *)className {
    return NSStringFromClass(self);
}

/**打印类名*/
- (NSString *)className {
    return [NSString stringWithUTF8String:class_getName([self class])];
}

/**深度复制自身(原理是通过归档自己,所以前提是需要遵循NSCoding协议)*/
- (id)deepCopy {
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return obj;
}

/**添加关联对象(strong类型的)*/
- (void)setAssociateValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**添加关联对象(weak类型的)*/
- (void)setAssociateWeakValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

/**移除关联对象*/
- (void)removeAssociatedValues {
    objc_removeAssociatedObjects(self);
}

/**获取关联对象*/
- (id)getAssociatedValueForKey:(void *)key {
    return objc_getAssociatedObject(self, key);
}

/**延迟delay时间间隔执行自身的Selector:sel函数*/
- (void)performSelector:(SEL)sel afterDelay:(NSTimeInterval)delay {
    [self performSelector:sel withObject:nil afterDelay:delay];
}

//其实这段宏定义和下面这段代码是一样的效果
/**
 //拿到函数签名,里面存放着函数参数个数和参数类型
 NSMethodSignature * sig = [self methodSignatureForSelector:sel];
 if (!sig) { [self doesNotRecognizeSelector:sel]; return; }
 //拿到函数调用,可为其动态添加实参
 NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
 if (!inv) { [self doesNotRecognizeSelector:sel]; return; }
 [inv setTarget:self];
 [inv setSelector:sel];
 
 //拿到实参
 va_list args;
 va_start(args, sel);
 [NSObject setInv:inv withSig:sig andArgs:args];
 va_end(args);
 */
#define INIT_INV(_last_arg_, _return_) \
NSMethodSignature * sig = [self methodSignatureForSelector:sel]; \
if (!sig) { [self doesNotRecognizeSelector:sel]; return _return_; } \
NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig]; \
if (!inv) { [self doesNotRecognizeSelector:sel]; return _return_; } \
[inv setTarget:self]; \
[inv setSelector:sel]; \
va_list args; \
va_start(args, _last_arg_); \
[NSObject setInv:inv withSig:sig andArgs:args]; \
va_end(args);

/**在主线程执行自己的某个函数,可以传很多参数*/
- (id)performSelectorWithArgs:(SEL)sel, ...{
    INIT_INV(sel, nil);
    [inv retainArguments];//把所有参数临时retain一遍
    //(invoke)调用
    [inv performSelector:@selector(invoke) withObject:nil];
    //根据拿到的函数签名,再根据函数签名获得真正的函数实现地址,然后再将其执行完后的返回结果给提取出来
    return [NSObject getReturnFromInv:inv withSig:sig];
}

/**在后台线程执行自己的某个函数,可以传很多参数*/
- (void)performSelectorWithArgsInBackground:(SEL)sel, ...{
    
    //拿到函数签名,里面存放着函数参数个数和参数类型
    NSMethodSignature * sig = [self methodSignatureForSelector:sel];
    if (!sig) { [self doesNotRecognizeSelector:sel]; return; }
    //拿到函数调用,可为其动态添加实参
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    if (!inv) { [self doesNotRecognizeSelector:sel]; return; }
    [inv setTarget:self];
    [inv setSelector:sel];
    
    //拿到实参
    va_list args;
    va_start(args, sel);
    [NSObject setInv:inv withSig:sig andArgs:args];
    va_end(args);
    
    [inv retainArguments];//把所有参数临时retain一遍
    //(invoke)调用
    [inv performSelectorInBackground:@selector(invoke) withObject:nil];
    
    //其实整体下来是这样的,就是先拿到函数签名,根据函数签名获得真正的函数实现地址,然后动态的为其传参数,最后调用即可
}

/**在主线程延迟 delay 执行自己的某个函数,可以传很多参数*/
- (void)performSelectorWithArgs:(SEL)sel afterDelay:(NSTimeInterval)delay, ...{
    INIT_INV(delay, );
    [inv retainArguments];
    [inv performSelector:@selector(invoke) withObject:nil afterDelay:delay];
}

/**在主线程执行自己的某个函数,可以传很多参数,如果wait为YES,那么相当于要执行完这个sel后再执行后面的代码,反之,需要等到调用这句代码的代码块里面全部执行完,在执行sel*/
- (id)performSelectorWithArgsOnMainThread:(SEL)sel waitUntilDone:(BOOL)wait, ...{
    INIT_INV(wait, nil);
    if (!wait) [inv retainArguments];
    [inv performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:wait];
    return wait ? [NSObject getReturnFromInv:inv withSig:sig] : nil;
}

/**在目标线程(Thread)执行自己的某个函数,可以传很多参数,如果wait为YES,那么相当于要执行完这个sel后再执行后面的代码,反之,需要等到调用这句代码的代码块里面全部执行完,在执行sel*/
- (id)performSelectorWithArgs:(SEL)sel onThread:(NSThread *)thr waitUntilDone:(BOOL)wait, ...{
    INIT_INV(wait, nil);
    if (!wait) [inv retainArguments];
    [inv performSelector:@selector(invoke) onThread:thr withObject:nil waitUntilDone:wait];
    return wait ? [NSObject getReturnFromInv:inv withSig:sig] : nil;
}

/**根据拿到的函数签名,再根据函数签名获得真正的函数实现地址,然后动态的为其传参数*/
+ (void)setInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig andArgs:(va_list)args {
    NSUInteger count = [sig numberOfArguments];
    for (int index = 2; index < count; index++) {
        char *type = (char *)[sig getArgumentTypeAtIndex:index];
        while (*type == 'r' ||
               *type == 'n' ||
               *type == 'N' ||
               *type == 'o' ||
               *type == 'O' ||
               *type == 'R' ||
               *type == 'V') {
            type++;
        }
        BOOL unsupportedType = NO;
        switch (*type) {
            case 'v'://void
            case 'B'://整型
            case 'c'://字符
            case 'C'://字符
            case 's'://字符串
            case 'S'://字符串
            case 'i'://整型
            case 'I'://整型
            case 'l'://整型
            case 'L'://整型
            {
                int arg = va_arg(args, int);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'q'://长整型
            case 'Q'://长整型
            {
                long long arg = va_arg(args, long long);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'f'://浮点
            {
                double arg = va_arg(args, double);
                float argf = arg;
                [inv setArgument:&argf atIndex:index];
            } break;
                
            case 'd'://浮点
            {
                double arg = va_arg(args, double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'D'://长浮点
            {
                long double arg = va_arg(args, long double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '*':
            case '^'://空指针
            {
                void *arg = va_arg(args, void *);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case ':'://SEL
            {
                SEL arg = va_arg(args, SEL);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '#'://Class
            {
                Class arg = va_arg(args, Class);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '@'://对象
            {
                id arg = va_arg(args, id);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '{'://结构体类型
            {
                if (strcmp(type, @encode(CGPoint)) == 0) {
                    CGPoint arg = va_arg(args, CGPoint);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGSize)) == 0) {
                    CGSize arg = va_arg(args, CGSize);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGRect)) == 0) {
                    CGRect arg = va_arg(args, CGRect);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGVector)) == 0) {
                    CGVector arg = va_arg(args, CGVector);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                    CGAffineTransform arg = va_arg(args, CGAffineTransform);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                    CATransform3D arg = va_arg(args, CATransform3D);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(NSRange)) == 0) {
                    NSRange arg = va_arg(args, NSRange);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIOffset)) == 0) {
                    UIOffset arg = va_arg(args, UIOffset);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                    UIEdgeInsets arg = va_arg(args, UIEdgeInsets);
                    [inv setArgument:&arg atIndex:index];
                } else {//自定义的结构体
                    unsupportedType = YES;
                }
            } break;
                
            case '('://不支持
            {
                unsupportedType = YES;
            } break;
                
            case '['://不支持
            {
                unsupportedType = YES;
            } break;
                
            default://不支持
            {
                unsupportedType = YES;
            } break;
        }
        
        //如果不支持,那么可能是自定义结构体
        if (unsupportedType) {
            
            NSUInteger size = 0;
            NSGetSizeAndAlignment(type, &size, NULL);
            
//            分配空间
            
#define case_size(_size_) \
else if (size <= 4 * _size_ ) { \
struct dummy { char tmp[4 * _size_]; }; \
struct dummy arg = va_arg(args, struct dummy); \
[inv setArgument:&arg atIndex:index]; \
}
            if (size == 0) { }
            case_size( 1) case_size( 2) case_size( 3) case_size( 4)
            case_size( 5) case_size( 6) case_size( 7) case_size( 8)
            case_size( 9) case_size(10) case_size(11) case_size(12)
            case_size(13) case_size(14) case_size(15) case_size(16)
            case_size(17) case_size(18) case_size(19) case_size(20)
            case_size(21) case_size(22) case_size(23) case_size(24)
            case_size(25) case_size(26) case_size(27) case_size(28)
            case_size(29) case_size(30) case_size(31) case_size(32)
            case_size(33) case_size(34) case_size(35) case_size(36)
            case_size(37) case_size(38) case_size(39) case_size(40)
            case_size(41) case_size(42) case_size(43) case_size(44)
            case_size(45) case_size(46) case_size(47) case_size(48)
            case_size(49) case_size(50) case_size(51) case_size(52)
            case_size(53) case_size(54) case_size(55) case_size(56)
            case_size(57) case_size(58) case_size(59) case_size(60)
            case_size(61) case_size(62) case_size(63) case_size(64)
            else {
                
                struct dummy {char tmp;};
                for (int i = 0; i < size; i++) va_arg(args, struct dummy);
                NSLog(@"YYKit performSelectorWithArgs unsupported type:%s (%lu bytes)",
                      [sig getArgumentTypeAtIndex:index],(unsigned long)size);
            }
#undef case_size
        }
    }
}

/**根据拿到的函数签名,再根据函数签名获得真正的函数实现地址,然后再将其执行完后的返回结果给提取出来*/
+ (id)getReturnFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig {
    NSUInteger length = [sig methodReturnLength];
    if (length == 0) return nil;//不为0,说明有返回参数
    
    char *type = (char *)[sig methodReturnType];
    while (*type == 'r' ||
           *type == 'n' ||
           *type == 'N' ||
           *type == 'o' ||
           *type == 'O' ||
           *type == 'R' ||
           *type == 'V') {
        type++;
    }
    
    //将基本数据类型包装成对象
#define return_with_number(_type_) \
do { \
_type_ ret; \
[inv getReturnValue:&ret]; \
return @(ret); \
} while (0)
    
    switch (*type) {
        case 'v': return nil;
        case 'B': return_with_number(bool);
        case 'c': return_with_number(char);
        case 'C': return_with_number(unsigned char);
        case 's': return_with_number(short);
        case 'S': return_with_number(unsigned short);
        case 'i': return_with_number(int);
        case 'I': return_with_number(unsigned int);
        case 'l': return_with_number(int);
        case 'L': return_with_number(unsigned int);
        case 'q': return_with_number(long long);
        case 'Q': return_with_number(unsigned long long);
        case 'f': return_with_number(float);
        case 'd': return_with_number(double);
        case 'D': {
            long double ret;
            [inv getReturnValue:&ret];
            return [NSNumber numberWithDouble:ret];
        };
            
        case '@': {
            id ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
            
        case '#': {
            Class ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
            
            //结构体
        default: {
            const char *objCType = [sig methodReturnType];
            char *buf = calloc(1, length);
            if (!buf) return nil;
            [inv getReturnValue:buf];
            NSValue *value = [NSValue valueWithBytes:buf objCType:objCType];
            free(buf);
            return value;
        };
    }
#undef return_with_number
}

@end
