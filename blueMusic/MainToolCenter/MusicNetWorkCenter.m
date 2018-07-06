//
//  MusicNetWorkCenter.m
//  blueMusic
//
//  Created by lining on 2018/7/5.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "MusicNetWorkCenter.h"
#import <AFNetworking/AFNetworking.h>
#import <TFHpple/TFHpple.h>
#import "BlueMusicPlayListModel.h"
#import "MusicDataCenter.h"

#define kNetease_playlist  @"http://music.163.com/discover/playlist/"

#define kMozilla_userAgent  @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36"

static MusicNetWorkCenter *musicNWCenter=nil;

@interface MusicNetWorkCenter()


@end

@implementation MusicNetWorkCenter
+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (musicNWCenter == nil) {
            musicNWCenter = [[MusicNetWorkCenter alloc]init];
        }
    });
    
    return musicNWCenter;
}

- (void)netease_RequestPlayListDataWithParameters:(NSDictionary*)parameters andFinishBlock:(finishBlock)finishblock
{
   // typeof(self) weakSelf = self;
    
    // 请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
     NSMutableString *urlstring = [NSMutableString stringWithString:kNetease_playlist];
    NSString *paramstr = [self keyValueStringWithDict:parameters];
    if (paramstr)
    {
        [urlstring appendString:paramstr];
    }
    
    [manager.requestSerializer setValue:@"text/html;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:kMozilla_userAgent forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:kMozilla_userAgent forHTTPHeaderField:@"UserAgent"];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    
    [manager GET:urlstring
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
            if (responseObject&&[responseObject isKindOfClass:[NSData class]])
            {
                NSArray *array = [self doPlaylistdata:responseObject];
                [[MusicDataCenter shareInstance] updatepldata:array];
            }
            finishblock();
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           finishblock();
        }];
    
}

-(NSArray*)doPlaylistdata:(NSData*)data
{
    TFHpple *xpthParser = [[TFHpple alloc]initWithHTMLData:data];
    
    NSArray *array_ul = [xpthParser searchWithXPathQuery:@"//ul"];
    
    NSMutableArray *array_cvrlst = [NSMutableArray array];
    
    for (TFHppleElement *hppleElement in array_ul)
    {
        NSString *clssss = hppleElement.attributes[@"class"];
        
        if ([clssss containsString:@"m-cvrlst"] )
        {
            [array_cvrlst addObject:hppleElement];
        }
    }
    
    NSMutableArray *array_pl = [NSMutableArray array];
    
    if (array_cvrlst.count>0)
    {
        for (TFHppleElement *hppleElement in array_cvrlst)
        {
            NSArray *array_li = [hppleElement searchWithXPathQuery:@"//li"];
            
            for (TFHppleElement *HppleElement in array_li)
            {
                BlueMusicPlayListModel *plModel = [[BlueMusicPlayListModel alloc]init];
                
                NSArray *array_diva = [HppleElement searchWithXPathQuery:@"//div//a"];
                TFHppleElement *pp = array_diva.firstObject;
                NSString *title = pp.attributes[@"title"];
                NSString *href = pp.attributes[@"href"];
                
                if (href)
                {
                    NSArray *arr = [href componentsSeparatedByString:@"="];
                    href = arr.lastObject;
                }
                
                plModel.title = title;
                plModel.pl_id = href;
                plModel.source_url = [NSString stringWithFormat:@"http://music.163.com/#/playlist?id=%@",plModel.pl_id];
                
                NSArray *array_divimg = [HppleElement searchWithXPathQuery:@"//div//img"];
                TFHppleElement *imgsrc = array_divimg.firstObject;
                NSString *img = imgsrc.attributes[@"src"];
                 plModel.cover_img_url = img;
                
                
                NSArray *array_person = [HppleElement searchWithXPathQuery:@"//p//a"];
                if (array_person.count>1)
                {
                    TFHppleElement *person = [array_person objectAtIndex:1];
                    NSString *personname = person.attributes[@"title"];
                     plModel.personname = personname;
                }
                
                NSArray *array_nb = [HppleElement searchWithXPathQuery:@"//div//div//span"];
                if (array_nb.count>1)
                {
                    TFHppleElement *e_nb = [array_nb objectAtIndex:1];
                    NSString *num = e_nb.content;
                    plModel.playnum = num;
                }
               
                
                [array_pl addObject:plModel];
            }
        }
        
    }
    
    if (array_pl.count>0)
    {
        return array_pl;
    }
    
    return nil;
}

//将{@"type":@"hot",@"uid":@"abc"} ->  ?type=hot&uid=abc的形式
- (NSString *)keyValueStringWithDict:(NSDictionary *)dict
{
    if (dict == nil)
    {
        return nil;
    }
    
    NSMutableString *string = [NSMutableString stringWithString:@"?"];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [string appendFormat:@"%@=%@&",key,obj];
    }];
    
    if ([string rangeOfString:@"&"].length)
    {
        [string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
    }
    
    return string;
}

-(NSDictionary *)dictionaryWithUrlString:(NSString *)urlStr
{
    NSMutableDictionary *paramsDict = nil;
    
    if (urlStr && urlStr.length && [urlStr rangeOfString:@"?"].length == 1)
    {
        NSArray *array = [urlStr componentsSeparatedByString:@"?"];
        
        if (array && array.count == 2)
        {
            NSString *paramsStr = array[1];
            
            if (paramsStr.length)
            {
                paramsDict = [NSMutableDictionary dictionary];
                NSArray *paramArray = [paramsStr componentsSeparatedByString:@"&"];
                for (NSString *param in paramArray)
                {
                    if (param && param.length)
                    {
                        NSArray *parArr = [param componentsSeparatedByString:@"="];
                        if (parArr.count == 2)
                        {
                            [paramsDict setObject:parArr[1] forKey:parArr[0]];
                        }
                    }
                }
                
                return paramsDict;
                
            }
           
            
            
        }
        
        
        
    }
   
    return paramsDict;
}
@end
