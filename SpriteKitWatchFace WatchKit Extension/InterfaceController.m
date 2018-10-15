//
//  InterfaceController.m
//  SpriteKitWatchFace WatchKit Extension
//
//  Created by Steven Troughton-Smith on 09/10/2018.
//  Copyright © 2018 Steven Troughton-Smith. All rights reserved.
//

#import "InterfaceController.h"
#import "FaceScene.h"

@import ObjectiveC.runtime;
@import SpriteKit;

@interface NSObject (fs_override)
+(id)sharedApplication;
-(id)keyWindow;
-(id)rootViewController;
-(NSArray *)viewControllers;
-(id)view;
-(NSArray *)subviews;
-(id)timeLabel;
-(id)layer;
@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"Theme":@(ThemeMarques)}];

	FaceScene *scene = [FaceScene nodeWithFileNamed:@"FaceScene"];
	
	CGSize currentDeviceSize = [WKInterfaceDevice currentDevice].screenBounds.size;
	
	/* Using the 44mm Apple Watch as the base size, scale down to fit */
	scene.camera.xScale = (184.0/currentDeviceSize.width);
	scene.camera.yScale = (184.0/currentDeviceSize.width);
	
	[self.scene presentScene:scene];
}

- (void)didAppear
{
	/* Hack to make the digital time overlay disappear */
	
	NSArray *views = [[[[[[[NSClassFromString(@"UIApplication") sharedApplication] keyWindow] rootViewController] viewControllers] firstObject] view] subviews];
	
	for (NSObject *view in views)
	{
		if ([view isKindOfClass:NSClassFromString(@"SPFullScreenView")])
			[[[view timeLabel] layer] setOpacity:0];
	}
	
	self.crownSequencer.delegate = self;
	[self.crownSequencer focus];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark -

CGFloat totalRotation = 0;

- (void)crownDidRotate:(nullable WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta
{
	int direction = 1;
	totalRotation += fabs(rotationalDelta);
	
	if (rotationalDelta < 0)
		direction = -1;
	
	if (totalRotation > (M_PI_4/2))
	{
		FaceScene *scene = (FaceScene *)self.scene.scene;
		
		if ((scene.theme+direction > 0) && (scene.theme+direction < ThemeMAX))
			scene.theme += direction;
		else
			scene.theme = 0;
		
		[scene refreshTheme];
        
		totalRotation = 0;
	}
}

- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * __nonnull))replyHandler {
    if ([message objectForKey:@"themeChange"]) {
        NSArray *themes = @[@"ThemeHermesPink", @"ThemeHermesOrange", @"ThemeNavy", @"ThemeTidepod", @"ThemeBretonnia", @"ThemeNoir", @"ThemeContrast", @"ThemeVictoire", @"ThemeLiquid", @"ThemeAngler", @"ThemeSculley", @"ThemeKitty", @"ThemeDelay", @"ThemeDiesel", @"ThemeLuxe", @"ThemeSage", @"ThemeBondi", @"ThemeTangerine", @"ThemeStrawberry", @"ThemePawn", @"ThemeRoyal", @"ThemeMarques", @"ThemeVox", @"ThemeSummer", @"ThemeMAX"];
        int key = [themes indexOfObject:[NSString stringWithFormat:@"Theme%@", [message objectForKey:@"themeChange"]]];
        
        FaceScene *scene = (FaceScene *)self.scene.scene;
        
        scene.theme = key;
        
        
        [scene refreshTheme];
    } else if ([message objectForKey:@"faceChange"]) {
        NSArray *faceStyles = @[@"FaceStyleRound", @"FaceStyleRectangular", @"FaceStyleMAX"];
        int key = [faceStyles indexOfObject:[NSString stringWithFormat:@"FaceStyle%@", [[message objectForKey:@"faceChange"] stringByReplacingOccurrencesOfString:@" Face" withString:@""]]];
        FaceScene *scene = (FaceScene *)self.scene.scene;
        
        scene.faceStyle = key;
        
        
        [scene refreshTheme];
    } else {
        
    }
}

@end



