//
//  ViewController.m
//  projectsCommands
//
//  Created by roryhuang-MC1 on 17/4/19.
//  Copyright © 2017年 roryhuang. All rights reserved.
//

#import "ViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>
@implementation ViewController{
  
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  self.seletedID = [[defaults objectForKey:@"seletedID"] integerValue];
  self.projects = @[@"QQLBroadcast",@"QQLVideos",@"QQLSocial",@"QQLiveBroadcast"];
  for (NSString *project in self.projects) {
    [self.comboBox addItemWithObjectValue:(project)];
  }
  [self.comboBox selectItemAtIndex:self.seletedID];
  [self refreshUI];
  [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}


-(void)timerFired{
  if ([self.notifyBox state] == NSOnState) {
    NSString *ssidcmd = @"/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}'";
    NSString *ssid = [self unixSinglePathCommandWithReturn:ssidcmd];
    bool proxy = false;
    if ([ssid containsString:@"OfficeWiFi"]) {
      proxy = true;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ip = [defaults objectForKey:@"savedip"]?:@"10.14.36.100";

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 4;
    config.connectionProxyDictionary = @{       @"HTTPEnable"  : @(proxy),
                                                (NSString *)kCFStreamPropertyHTTPProxyHost  : ip,
                                                (NSString *)kCFStreamPropertyHTTPProxyPort  : @(8080),
                                                };;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    session.configuration.HTTPAdditionalHeaders = @{@"User-Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36"};
    NSURL *url = [NSURL URLWithString:@"http://cloud.chinajnc.cn/index.php/Change/checkProfit_app"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (!error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *s = [[NSString alloc] initWithData:data encoding:enc];
        if ([dict[@"info"] integerValue] == 0) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [NSApp dockTile].badgeLabel = [NSString stringWithFormat:@"%@",dict[@"data"][@"profit"]];
          });

        }

      }
    }];
    [task resume];
  } else {
    [NSApp dockTile].badgeLabel = @"";
  }

}

-(void)refreshUI{
  [self.projectNameLabel setStringValue:[NSString stringWithFormat:@"当前项目是:%@",self.projectName]];
}

-(NSString*)projectName{
  return self.projects[self.seletedID];
}
- (IBAction)OnComboboxChanged:(id)sender
{
  self.seletedID = [self.comboBox indexOfSelectedItem];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[NSString stringWithFormat:@"%ld",self.seletedID] forKey:@"seletedID"];
  [defaults synchronize];
  [self refreshUI];
}


- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];

  // Update the view, if already loaded.
}
- (NSString *)unixSinglePathCommandWithReturn:(NSString *)command
{
  NSPipe *newPipe = [NSPipe pipe];
  NSFileHandle *readHandle = [newPipe fileHandleForReading];

  NSTask *unixTask = [[NSTask alloc] init];
  [unixTask setStandardOutput:newPipe];
  [unixTask setLaunchPath:@"/bin/sh"];
  [unixTask setArguments:[NSArray arrayWithObjects:@"-c", command , nil]];
  [unixTask launch];
  [unixTask waitUntilExit];

  NSString *output = [[NSString alloc] initWithData:[readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];

  return output;
}
-(NSString*)exampleName{
  if (self.seletedID < [self.projects count]-1) {
    return @"/Example";
  }
  return @"";
}
-(IBAction)updateSelf:(id)sender{
  NSString *script = [NSString stringWithFormat:@"cd /Users/rory/%@%@;git st;pod update %@ --no-repo-update;git st;",self.projectName,self.exampleName,self.projectName];
  [self openTerminal:script];
}
-(IBAction)updateQQLGeneratedCode:(id)sender{
  NSString *script = [NSString stringWithFormat:@"cd /Users/rory/%@%@;git st;pod update QQLGeneratedCode --no-repo-update;git st;",self.projectName,self.exampleName];
  [self openTerminal:script];
}

-(IBAction)commit:(id)sender{
  NSString *content = [_commitText stringValue];
  if ([content hasPrefix:@"savedip:"]) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[content stringByReplacingOccurrencesOfString:@"savedip:" withString:@""] forKey:@"seletedID"];
    [defaults synchronize];
    return;
  }





  NSString *script = [NSString stringWithFormat:@"cd /Users/rory/%@;git st;git add .;git ci -m %@ ;git push;git st;",self.projectName,content];
  [self openTerminal:script];
}

-(IBAction)status:(id)sender{
  NSString *script = [NSString stringWithFormat:@"cd /Users/rory/%@;git st;",self.projectName];
  [self openTerminal:script];
}


-(IBAction)updateSubProject:(id)sender{
  NSString *generate=@"",*videos=@"",*social=@"",*broadcast=@"";
  if ([self.generatedCode state] == NSOnState) {
    generate = [NSString stringWithFormat:@"cd /Users/rory/QQLiveBroadcast/lib/QQLGeneratedCode;git st;git pull origin master;"];
  }
  if ([self.broadCast state] == NSOnState) {
    videos = [NSString stringWithFormat:@"cd /Users/rory/QQLiveBroadcast/lib/QQLBroadcast;git st;git pull origin master;"];
  }
  if ([self.social state] == NSOnState) {
    social = [NSString stringWithFormat:@"cd /Users/rory/QQLiveBroadcast/lib/QQLSocial;git st;git pull origin master;"];
  }
  if ([self.videos state] == NSOnState) {
    broadcast = [NSString stringWithFormat:@"cd /Users/rory/QQLiveBroadcast/lib/QQLVideos;git st;git pull origin master;"];
  }
  NSString *script = [NSString stringWithFormat:@"git st;%@%@%@%@",generate,videos,social,broadcast];
  [self openTerminal:script];
}

-(IBAction)finderopenDir:(id)sender{
  NSString *script = [NSString stringWithFormat:@"cd /Users/rory/%@;open .;",self.projectName];
  [self unixSinglePathCommandWithReturn:script];
}
-(IBAction)submoduleUpdate:(id)sender{
  NSString *script = [NSString stringWithFormat:@"cd /Users/rory/%@;git st;git submodule update --init;echo 'submodule already update';git st;",self.projectName];
  [self openTerminal:script];
}
-(IBAction)xcodeopen:(id)sender{
  NSString *script = [NSString stringWithFormat:@"cd /Users/rory/%@%@;git st;open -a Xcode %@.xcworkspace;",self.projectName,self.exampleName,self.projectName];
  [self unixSinglePathCommandWithReturn:script];
}
-(IBAction)amend:(id)sender{
  NSString *script = [NSString stringWithFormat:@"cd /Users/rory/%@;git st;git add .;git ci --amend --no-edit ;git push;git st;",self.projectName];
  [self openTerminal:script];
}





//采用Sheet的方式展示
-(IBAction)reset:(id)sender{

  NSAlert *alert = [NSAlert new] ;
  [alert addButtonWithTitle:@"确定"];
  [alert addButtonWithTitle:@"点错了..."];
  [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
    if(returnCode == NSAlertFirstButtonReturn )
    {
      NSString *script = [NSString stringWithFormat:@"cd /Users/rory/%@;git st;git checkout master;git reset --hard origin/master;git pull;git st;",self.projectName];
      [self openTerminal:script];
    }
  }];


}

-(void)openTerminal:(NSString*)script{

//  NSString *scriptbefore = @"SERVICE='Terminal';if ps ax | grep -v grep | grep $SERVICE > /dev/null ;then echo \"$SERVICE service running, everything is fine\" ;else echo \"$SERVICE is not running\"; echo \"$SERVICE is not running!\" | mail -s \"$SERVICE down\" root ;fi;";
//  NSString * outs = [self unixSinglePathCommandWithReturn:scriptbefore];

  NSString *s = [NSString stringWithFormat:@"tell application \"Terminal\" to do script \"%@\" in front window", script];
  NSAppleScript *as = [[NSAppleScript alloc] initWithSource: s];
  [as executeAndReturnError:nil];
  //NSDictionary *r = [NSDictionary new];;
  //[[[NSAppleScript alloc] initWithSource: @"tell application \"Terminal\" to activate"] executeAndReturnError:&r];
  [[[NSAppleScript alloc] initWithSource: @"tell application \"System Events\" to set visible of process \"Terminal\" to false"] executeAndReturnError:nil];
  [[[NSAppleScript alloc] initWithSource: @"tell application \"System Events\" to set frontmost of process \"Terminal\" to true"] executeAndReturnError:nil];



}
@end
