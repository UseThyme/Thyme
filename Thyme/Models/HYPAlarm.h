#import <Foundation/Foundation.h>
#define ALARM_ID_KEY @"HYPAlarmID"
#define ALARM_FIRE_DATE_KEY @"HYPAlarmFireDate"
#define ALARM_FIRE_INTERVAL_KEY @"HYPAlarmFireInterval"

@interface HYPAlarm : NSObject

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *alarmID;
@property (nonatomic, getter = isActive) BOOL active;
@property (nonatomic, getter = isOven) BOOL oven;

+ (NSString *)titleForHomescreen;
+ (NSString *)subtitleForHomescreen;
+ (NSString *)subtitleForHomescreenUsingMinutes:(NSNumber *)minutes;
+ (NSString *)messageForSetAlarm;
+ (NSString *)messageForReleaseToSetAlarm;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *title;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *timerTitle;
+ (NSString *)defaultAlarmID;

@end