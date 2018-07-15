
#import "MusicModel.h"
#import "Headers.h"
@implementation MusicModel

-(NSString*)durationstring
{
    if (self.duration)
    {
        float duu = self.duration.floatValue;
        NSString *ss = [NSString stringWithFormat:@"%.1fs",duu/1000.0f];
        return ss;
    }
    return @"0.0";
}

@end
