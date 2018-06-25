
#import "MusicModel.h"
#import "Headers.h"
@implementation MusicModel


// 错误处理的方法
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //[super setValue:value forUndefinedKey:key];
    
    
    
    if ([key isEqualToString:@"MP3file"]) {
        
        AVFile *av1 =( AVFile *)value;
        NSDictionary *raw = [av1 valueForKey:@"rawJSONData"];
        self.MP3file_url = [raw valueForKey:@"url"];
        self.playurl_mp3 = [raw valueForKey:@"url"];
        NSLog(@"        self.MP3file_url=%@",self.MP3file_url);
    }
    
    if ([key isEqualToString:@"blurpicfile"]) {
        
        
        AVFile *av2 =( AVFile *)value;
        NSDictionary *raw = [av2 valueForKey:@"rawJSONData"];
        self.picurl_blur = [raw valueForKey:@"url"];
        self.blurpicfile_url =[raw valueForKey:@"url"];
    }
    
    if ([key isEqualToString:@"picfile"]) {
        
        
        
        AVFile *av3 =( AVFile *)value;
        NSDictionary *raw = [av3 valueForKey:@"rawJSONData"];
        self.picfile_url = [raw valueForKey:@"url"];
        self.picurl_normal = [raw valueForKey:@"url"];;
    }
    
    
    
}








@end
