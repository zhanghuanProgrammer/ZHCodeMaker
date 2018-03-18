#import <XCTest/XCTest.h>

@interface CodeMakerUITests : XCTestCase

@end

@implementation CodeMakerUITests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    [[[XCUIApplication alloc] init] launch];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
}

@end
