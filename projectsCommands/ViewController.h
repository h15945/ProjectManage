//
//  ViewController.h
//  projectsCommands
//
//  Created by roryhuang-MC1 on 17/4/19.
//  Copyright © 2017年 roryhuang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property(nonatomic,weak)IBOutlet NSTextField *commitText;
@property(nonatomic,weak)IBOutlet NSComboBox *comboBox;
@property(nonatomic,strong) NSArray *projects;
@property(nonatomic,assign) NSInteger seletedID;
@property(nonatomic,weak  )IBOutlet  NSTextField*projectNameLabel;
@property(nonatomic,strong) NSString*projectName;
@property(nonatomic,strong) NSString*exampleName;


@property(nonatomic,weak)IBOutlet NSButton*generatedCode;
@property(nonatomic,weak)IBOutlet NSButton*broadCast;
@property(nonatomic,weak)IBOutlet NSButton*videos;
@property(nonatomic,weak)IBOutlet NSButton*social;



@end

