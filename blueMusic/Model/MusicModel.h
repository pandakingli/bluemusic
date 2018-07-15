

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MusicModel : NSObject

@property (nonatomic, copy) NSString *objectid;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *songid;
@property (nonatomic, copy) NSString *songname;
@property (nonatomic, copy) NSString *playurl;
@property (nonatomic, copy) NSString *coverurl;
@property (nonatomic, copy) NSString *singer;
@property (nonatomic, copy) NSString *lyric;

@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *durationstring;

@property (nonatomic, copy) NSString *localpath;
@end
