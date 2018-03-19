//
//  RFSimpleAddressBookSortingView.m
//  RFSimpleAddressBookSorting
//
//  Created by Raywf on 2018/3/19.
//  Copyright © 2018年 S.Ray. All rights reserved.
//

#import "RFSimpleAddressBookSortingView.h"

#define RFIndexList_CN @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J", \
                         @"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T", \
                         @"U",@"V",@"W",@"X",@"Y",@"Z", @"#"]

#define RFIndexList_KR @[@"ㄱ", @"ㄲ", @"ㄴ", @"ㄷ", @"ㄸ", @"ㄹ", @"ㅁ", @"ㅂ", @"ㅃ", @"ㅅ", \
                         @"ㅆ", @"ㅇ", @"ㅈ", @"ㅉ", @"ㅊ", @"ㅋ", @"ㅌ", @"ㅍ", @"ㅎ", @"#"]

#define RFRegEx_CN @"[\\u4e00-\\u9fa5]"

#define RFRegEx_KR @"[\\u3130-\\u318f\\uac00-\\ud7a3]"

#define RFTestMetaList @[@"毛泽东", @"邓小平", @"周恩来", @"蒋介石", @"鲁迅", @"林彪", @"张学良", @"林徽因", \
                         @"雷锋", @"张爱玲", @"宋庆龄", @"朱德", @"三毛", @"钱学森", @"老舍", @"彭德怀", \
                         @"Tom", @"Michael", @"Jerry", @"Edward", @"Alice", @"Maddie", @"Cashel", @"Lucifer", \
                         @"Lilly", @"Christina", @"Kristine", @"Hadly", @"Heather", @"Harper", @"Juliet", @"Cécilia", \
                         @"이륙사", @"김유신", @"이규보", @"세종왕", @"김홍도", @"민비", @"신윤복", @"이속곡", \
                         @"이도산", @"이순신", @"황진이", @"신사임당", @"유관순", @"김소월", @"김구"]

@interface RFSimpleAddressBookSortingView () <UITableViewDataSource, UITableViewDelegate>
{
    int _sortType;
    int _fitableType;

    UITableView *_tableView;
    NSMutableDictionary *_showDic;

    NSMutableArray *_indexList;

    UIView *_showIndexView;
    NSMutableArray *_showIndexList;
}
@end

@implementation RFSimpleAddressBookSortingView

- (void)reloadDataViaSwitchType:(int)type {
    if (_tableView) {
        _sortType = type;
        [self processDataCompletion:^{
            [_tableView reloadData];
        }];
    }
}

- (void)reloadDataViaFitableType:(int)type {
    if (_tableView) {
        _fitableType = type;
        [self processDataCompletion:^{
            [_tableView reloadData];
        }];
    }
}

- (void)processDataCompletion:(void (^)(void))compltion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *metaList = RFTestMetaList;
        if (metaList.count==0) {
            return;
        }

        NSArray *keyList = _sortType==0?RFIndexList_CN:RFIndexList_KR;

        NSString *firstLetter;
        NSMutableDictionary *showDic = [NSMutableDictionary dictionary];
        NSMutableArray *showIndexList = [NSMutableArray array];
        NSMutableArray *indexList = [NSMutableArray array];

        [showIndexList addObjectsFromArray:[keyList copy]];
        [indexList addObjectsFromArray:[keyList copy]];
        for (NSInteger i = 0; i < indexList.count; i++) {
            NSMutableArray *cArr = [NSMutableArray array];
            [showDic setObject:cArr forKey:indexList[i]];
        }

        for (NSString *name in metaList) {
            if (name.length > 0) {
                firstLetter = [name substringToIndex:1];    /* 取出字符串中的第一个字符 */

                if ([self rf_IsMatchRegEx:RFRegEx_CN String:firstLetter]) {/* 中文 */
                    firstLetter = [self hanziToPinyin:firstLetter];
                    firstLetter = [[firstLetter substringToIndex:1] uppercaseString];
                } else if ([self rf_IsMatchRegEx:RFRegEx_KR String:firstLetter]) {/* 韩文 */
                    firstLetter = [firstLetter substringToIndex:1];
                    NSInteger unicodeValue = [firstLetter characterAtIndex:0];
                    //NSLog(@"unicodeValue: %ld", (long)unicodeValue);
                    NSInteger index = (unicodeValue-44032)/588;
                    NSArray *krKeyList = RFIndexList_KR;
                    firstLetter = krKeyList[index];
                } else {/* 其它 */
                    firstLetter = [[firstLetter substringToIndex:1] uppercaseString];
                }

                if ([indexList containsObject:firstLetter]) {
                    NSString *key = firstLetter;
                    NSMutableArray *cArr = [showDic objectForKey:key];
                    [cArr addObject:name];
                } else {
                    NSString *key = @"#";
                    NSMutableArray *cArr = [showDic objectForKey:key];
                    [cArr addObject:name];
                }
            } else {
                NSString *key = @"#";
                NSMutableArray *cArr = [showDic objectForKey:key];
                [cArr addObject:name];
            }
        }

        for (NSInteger i = 0; i < showDic.allKeys.count; i++) {
            NSString *key = showDic.allKeys[i];
            NSMutableArray *cArr = [showDic objectForKey:key];
            if (cArr.count==0) {
                [showDic removeObjectForKey:key];
                [showIndexList removeObject:key];
                i--;
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(_indexList) {
                _showDic = showDic;
                _showIndexList = showIndexList;
                _indexList = indexList;
                [_tableView reloadData];
            }
        });
    });
}

- (BOOL)rf_IsMatchRegEx:(NSString *)regEx String:(NSString *)string {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

#pragma mark - 中文排序处理
- (NSString *)hanziToPinyin:(NSString *)hanzi {
    NSString *pinyin = [self transformMandarinToLatin:hanzi];
    if (pinyin.length > 0) {
        return pinyin;
    }

    NSMutableString *ms = [[NSMutableString alloc] initWithString:hanzi];
    if (CFStringTransform((__bridge CFMutableStringRef)ms, 0,
                          kCFStringTransformMandarinLatin, NO)) {
        //PLog(@"Pingying: %@", ms); // wǒ shì zhōng guó rén
    }
    if (CFStringTransform((__bridge CFMutableStringRef)ms, 0,
                          kCFStringTransformStripDiacritics, NO)) {
        //PLog(@"Pingying: %@", ms); // wo3 shi4 zhong1 guo2 ren2
    }

    return ms;
}

- (NSString *)transformMandarinToLatin:(NSString *)hanzi {  /* 部分多音字处理 */
    NSString *pinyin = @"";
    if ([hanzi compare:@"长"] == NSOrderedSame) {
        pinyin = @"chang";
    } else if ([hanzi compare:@"沈"] == NSOrderedSame) {
        pinyin = @"shen";
    } else if ([hanzi compare:@"厦"] == NSOrderedSame) {
        pinyin = @"xia";
    } else if ([hanzi compare:@"地"] == NSOrderedSame) {
        pinyin = @"di";
    } else if ([hanzi compare:@"重"] == NSOrderedSame) {
        pinyin = @"chong";
    } else if ([hanzi compare:@"行"] == NSOrderedSame) {
        pinyin = @"xing";
    }
    return pinyin;
}

#pragma mark - 韩文排序处理

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self customUI];

        _sortType = 0;
        _fitableType = 0;
        [self processDataCompletion:^{
            [_tableView reloadData];
        }];
    }
    return self;
}

- (void)customUI {
    /* tableView */
    CGRect frame = self.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    //修改索引颜色
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];//修改右边索引的背景色
    tableView.sectionIndexColor = [UIColor orangeColor];//修改右边索引字体的颜色
    tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];//修改右边索引点击时候的背景色
    [self addSubview:tableView];
    _tableView = tableView;

    /* showIndexView */
    frame = CGRectMake((int)((CGRectGetWidth(self.frame)-78)/2),
                       (int)((CGRectGetHeight(self.frame)-78)/2), 78, 78);
    UIView *showIndexView = [[UIView alloc] initWithFrame:frame];
    {
        frame = showIndexView.bounds;
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor orangeColor];
        label.font = [UIFont systemFontOfSize:44];
        label.textColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = CGRectGetHeight(label.frame)/2;
        label.clipsToBounds = YES;
        [showIndexView addSubview:label];
    }
    showIndexView.alpha = 0.0f;
    showIndexView.hidden = YES;
    [self addSubview:showIndexView];
    _showIndexView = showIndexView;
}

#pragma mark - tableView dataSource & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _showIndexList.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 25.0f);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor lightGrayColor];
    {
        NSString *key = _showIndexList[section];
        CGRect frame = CGRectMake(15, 0, CGRectGetWidth(self.frame)-15*2, 25);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blueColor];
        label.text = key;
        [view addSubview:label];
    }
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = _showIndexList[section];
    NSArray *rows = [_showDic objectForKey:key];
    return rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellId];
    }

    NSString *key = _showIndexList[indexPath.section];
    NSMutableArray *rows = [_showDic objectForKey:key];
    NSString *name = rows[indexPath.row];
    cell.textLabel.text = name;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//索引的设置
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!_fitableType) {
        return _showIndexList;
    } else {
        return _indexList;
    }
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    NSString* key = (!_fitableType)?[_showIndexList objectAtIndex:index]:[_indexList objectAtIndex:index];

    //if (key == UITableViewIndexSearch) {
    //    [tableView setContentOffset:CGPointZero animated:YES];
    //    return NSNotFound;
    //}

    UILabel *showLab = _showIndexView.subviews.firstObject;
    showLab.text = key;
    if (_showIndexView.alpha < 1.0f) {
        _showIndexView.hidden = NO;
        [UIView animateWithDuration:0.3f animations:^{
            _showIndexView.alpha = 1.0f;
        } completion:nil];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideShowIndexView) object:nil];
    [self performSelector:@selector(hideShowIndexView) withObject:nil afterDelay:2.0f];

    if (![_showIndexList containsObject:key]) {
        return NSNotFound;
    }
    return [_showIndexList indexOfObject:key];
}

#pragma mark - animation for showIndexView
- (void)hideShowIndexView {
    [UIView animateWithDuration:0.3f animations:^{
        _showIndexView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            _showIndexView.hidden = YES;
        }
    }];
}

@end
