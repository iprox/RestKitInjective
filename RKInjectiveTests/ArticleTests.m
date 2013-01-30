//
//  ArticleTests.m
//  RKInjective
//
//  Created by Taras Kalapun on 1/28/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "ArticleTests.h"
#import "Article.h"

@implementation ArticleTests

+ (void)load {
    NSBundle *testTargetBundle = [NSBundle bundleWithIdentifier:@"com.AppFellas.RKInjectiveTests"];
    [RKTestFixture setFixtureBundle:testTargetBundle];
    
    [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost/"]];
}

- (void)setUp {
    
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown {
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
}

- (void)testModelName {
    expect([Article modelName]).to.equal(@"article");
}

- (void)testModelNamePlural {
    expect([Article modelNamePlural]).to.equal(@"articles");
}

- (void)testObjectMappingDictionary {
    NSDictionary *dict = [Article objectMappingDictionary];
    NSDictionary *dict2 = @{@"id" : @"articleId", @"name" : @"name", @"title" : @"title"};
    expect(dict).to.equal(dict2);
}

- (void)testUniqueIdentifier {
    Article *article = [Article new];
    article.articleId = @"1000";
    expect([article uniqueIdentifier]).to.equal(@"1000");
}

- (void)testMapping {
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"article.json"];
    
    RKMapping *mapping = [Article objectMapping];
    RKMappingTest *test = [RKMappingTest testForMapping:mapping sourceObject:parsedJSON destinationObject:nil];
	[test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"title" destinationKeyPath:@"title"]];
    BOOL evaluated = [test evaluate];
    expect(evaluated).to.equal(YES);
}

#pragma mark - Network tests

- (void)testGetObjects {
    NSString *data = [RKTestFixture stringWithContentsOfFixture:@"articles.json"];
    stubRequest(@"GET", @"http://localhost/articles").andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).withBody(data);
    
    [self runTestWithBlock:^{
        [Article getObjectsOnSuccess:^(NSArray *objects) {
            STAssertNotNil(objects, @"Could not load objects");
            expect(objects).toNot.beNil();
            expect(objects.count).to.equal(3);
            [self blockTestCompleted];
        } failure:^(NSError *error) {
            STAssertNil(error, @"Should be no error on object loading");
            [self blockTestCompleted];
        }];
    }];
}

- (void)testGetObject {
    NSString *data = [RKTestFixture stringWithContentsOfFixture:@"article.json"];
    stubRequest(@"GET", @"http://localhost/articles/10000").andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).withBody(data);
    
    [self runTestWithBlock:^{
        Article *article = [Article new];
        article.articleId = @"10000";
        [article getObjectOnSuccess:^(id object) {
            STAssertNotNil(object, @"Could not load objects");
            expect(object).toNot.beNil();
            [self blockTestCompleted];
        } failure:^(NSError *error) {
            STAssertNil(error, @"Should be no error on object loading");
            [self blockTestCompleted];
        }];
    }];
}

@end
