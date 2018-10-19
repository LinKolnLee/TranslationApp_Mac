//
//  AppDelegate.m
//  BeautyTran
//
//  Created by llk on 2018/6/21.
//  Copyright © 2018年 Beauty. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking.h>
@interface AppDelegate ()<NSTableViewDelegate,NSTableViewDataSource>
{
    NSString * _selectType;
    NSMutableArray * _words;
}
@property (weak) IBOutlet NSButton *tranButton;
@property (weak) IBOutlet NSImageView *resultImageView;
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *contentTextField;
@property (weak) IBOutlet NSTextField *resultTextfield;
- (IBAction)selectLag:(NSPopUpButton *)sender;
@property (weak) IBOutlet NSTableView *MyTableview;
@property(nonatomic,strong)NSString * content;
- (IBAction)hortButtonClick:(NSButton *)sender;
@property (weak) IBOutlet NSButton *hortButton;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor whiteColor]];
    _words = [[NSMutableArray alloc] init];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"HistoryWord" ofType:@"plist"];
    //@"/Users/llk/Desktop/BeautyTran/BeautyTran/HistoryWord.plist";
    _words = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    [self.MyTableview setDelegate:self];
    [self.MyTableview setDataSource:self];
    //[self.contentTextField setBordered:YES];
    NSCell * cell = [self.resultTextfield cell];
    cell.usesSingleLineMode = NO;
    cell.wraps = YES;
    cell.lineBreakMode = NSLineBreakByWordWrapping;
    //设置label内容可以被选中
    cell.selectable = YES;
    [self.tranButton setKeyEquivalent:@"\r"];
//    [self.contentTextField setBordered:YES];
//    self.contentTextField.layer.borderColor = [[NSColor colorWithRed:138/255 green:208/255 blue:247/255 alpha:1] CGColor];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag{
    if (!flag){
        //主窗口显示
        [NSApp activateIgnoringOtherApps:NO];
        [self.window makeKeyAndOrderFront:self];
    }
    return YES;
} 
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)teansButtonClick:(NSButton *)sender {
    NSLog(@"haha");
    if (self.contentTextField.stringValue.length > 0) {
        if (!_selectType) {
            _selectType = @"EN2ZH_CN";
        }
        NSString *content = self.contentTextField.stringValue;
        /** 翻译规则 */
        content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"." withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"。" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"?" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"？" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@";" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"；" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"、" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"!" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"！" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"_" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"—" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"-" withString:@","];
        content = [content stringByReplacingOccurrencesOfString:@"+" withString:@","];
        self.content = content;
        
        /** Post网络请求 */
        NSDictionary *params = @{@"i":content,@"doctype":@"json",@"type":_selectType};
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer  = [AFHTTPRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        //http://dict.youdao.com/dictvoice?audio=good&type=2
        [manager POST:@"http://fanyi.youdao.com/translate" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSArray *array = [[NSArray alloc]initWithArray:responseObject[@"translateResult"]];
            self.resultTextfield.stringValue = [[array firstObject] firstObject][@"tgt"];
            NSString * filePath = [[NSBundle mainBundle] pathForResource:@"HistoryWord" ofType:@"plist"];
            NSMutableDictionary *newsDict = [NSMutableDictionary dictionary];
            
            //赋值
            [newsDict setObject:self.contentTextField.stringValue forKey:@"query"];
            [newsDict setObject:self.resultTextfield.stringValue forKey:@"result"];
            [self->_words addObject:newsDict];
            [self->_words writeToFile:filePath atomically:YES];
            [self.MyTableview reloadData];
            
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            self.resultTextfield.stringValue = [NSString stringWithFormat:@"%ld -> %@",error.code,error.localizedDescription];
        }];
    }
}

- (IBAction)selectLag:(NSPopUpButton *)sender {
    _selectType = @[@"EN2ZH_CN",@"ZH_CN2EN",
                    @"ZH_CN2JA",@"JA2ZH_CN"
                    ][sender.indexOfSelectedItem];
    if (sender.indexOfSelectedItem >1) {
        self.hortButton.enabled = NO;
    }else{
        self.hortButton.enabled = YES;
    }
}
// 这个方法返回列表的行数 : 类似于iOS中的numberOfRowsInSection:
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _words.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    // 1.创建可重用的cell:
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    NSArray* reversedArray = [[_words reverseObjectEnumerator] allObjects];
    // 2. 根据重用标识，设置cell 数据
    if( [tableColumn.identifier isEqualToString:@"MainTableViewCell"] ){
        NSString * text = [NSString stringWithFormat:@"%@:%@",reversedArray[row][@"query"],reversedArray[row][@"result"]];
        cellView.textField.stringValue = text;
        return cellView;
    }
    return cellView;
    
}
- (IBAction)hortButtonClick:(NSButton *)sender {
    NSSpeechSynthesizer *synth= [[NSSpeechSynthesizer alloc] init];
    synth.rate = 1;
    if ([_selectType isEqualToString:@"ZH_CN2EN"]){
        [synth startSpeakingString: self.resultTextfield.stringValue];
    }else{
        [synth startSpeakingString: self.content];

    }
}
@end
