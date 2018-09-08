//
//  MusicNetWorkCenter.m
//  blueMusic
//
//  Created by lining on 2018/7/5.
//  Copyright © 2018年 biubiublue. All rights reserved.
// #1

#import "MusicNetWorkCenter.h"
#import <AFNetworking/AFNetworking.h>
#import <TFHpple/TFHpple.h>
#import "BlueMusicPlayListModel.h"
#import "MusicDataCenter.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "MusicModel.h"
#import <bluebox/bluebox.h>

#define kNetease_playlist  @"http://music.163.com/discover/playlist/"

#define kMozilla_userAgent  @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36"

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

- (void)netease_RequestMusicDataWithParameters:(NSDictionary*)parameters andFinishBlock:(finishBlock)finishblock
{
    
        //typeof(self) weakSelf = self;
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
        NSString *plid = [parameters objectForKey:@"plid"];
        NSDictionary *params = [self getMusicModelWithPLid:plid?:@""];
    
        NSString *url = @"http://music.163.com/weapi/v3/playlist/detail";
    
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
        
        [manager POST:url
           parameters:params
             progress:^(NSProgress * _Nonnull uploadProgress) {
                 
             } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     
                 NSMutableArray *musicsArray = [NSMutableArray array];
                 NSDictionary *playlist = [responseObject objectForKey:@"playlist"];
                 NSArray *tracks = [playlist objectForKey:@"tracks"];
                 if (tracks.count>0)
                 {
                     
                     for (NSDictionary *ddd in tracks)
                     {
                         MusicModel *m = [[MusicModel alloc]init];
                         m.songname = [ddd objectForKey:@"name"];
                         NSNumber *num = [ddd objectForKey:@"dt"];
                         m.duration = num.stringValue;
                         m.songid = [ddd objectForKey:@"id"];
                         
                         NSArray *ar_arr = [ddd objectForKey:@"ar"];
                         NSDictionary *ar_dic = ar_arr.firstObject;
                         if ([ar_dic objectForKey:@"name"])
                         {
                             m.singer = [ar_dic objectForKey:@"name"];
                         }
                         
                          NSDictionary *al_dic = [ddd objectForKey:@"al"];
                         if ([al_dic objectForKey:@"picUrl"])
                         {
                             m.coverurl = [al_dic objectForKey:@"picUrl"];
                         }
                         
                         [musicsArray addObject:m];
                     }
                     if (musicsArray.count>0)
                     {
                         [[MusicDataCenter shareInstance] updateMusicdata:musicsArray];
                     }
                 }
                 
                 finishblock();
               
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               finishblock();
             }];
   
}

//根据播单id获取参数
-(NSDictionary*)getMusicModelWithPLid:(NSString*)plid
{
    NSString *aespath = [[NSBundle mainBundle] pathForResource:@"aes" ofType:@"js"];
    NSString *aespathstr= [NSString stringWithContentsOfFile:aespath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *bigint = [[NSBundle mainBundle] pathForResource:@"bigint" ofType:@"js"];
    NSString *bigintstr = [NSString stringWithContentsOfFile:bigint encoding:NSUTF8StringEncoding error:nil];
    
    NSString *request_netease = [[NSBundle mainBundle] pathForResource:@"request_netease" ofType:@"js"];
    NSString *request_neteaseStr = [NSString stringWithContentsOfFile:request_netease encoding:NSUTF8StringEncoding error:nil];
    
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript:aespathstr];
    [context evaluateScript:bigintstr];
    [context evaluateScript:request_neteaseStr];
    
    JSValue *function =context[@"go_requestpldetail"];
    
    if (!plid)
    {
        plid=@"123";
    }
    JSValue *s = [function callWithArguments:@[plid]];
 
    return [s toDictionary];
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

- (void)netease_RequestMusicSongurlDataWithParameters:(NSDictionary*)parameters andFinishBlock:(finishURLBlock)finishblock
{
   
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *songid = [parameters objectForKey:@"songid"];
    NSDictionary *params = [self getSongdicWithsongid:songid?:@""];
    
    
    NSString *url = @"http://music.163.com/weapi/song/enhance/player/url?csrf_token=";
   [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
   // [manager.requestSerializer setValue:@"text/html;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:kMozilla_userAgent forHTTPHeaderField:@"User-Agent"];
    
    [manager.requestSerializer setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"zh-CN,zh;q=0.9,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
    [manager.requestSerializer setValue:@"http://music.163.com/" forHTTPHeaderField:@"Referer"];
     [manager.requestSerializer setValue:@"http://music.163.com/" forHTTPHeaderField:@"Origin"];
    manager.requestSerializer.HTTPShouldHandleCookies = YES;
     manager.responseSerializer = [AFJSONResponseSerializer serializer];
     manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    
    NSString *cook = @"vjuids=2a4d1e32d.15cde8ec889.0.f6d8a99ae0ac1; _ntes_nuid=5369e89fab2ece7dbd6b79d8e2d550c8; __gads=ID=714397f16df879aa:T=1500911001:S=ALNI_MaU1oFWxPK2IdfuFpxqY11ZuySaFA; mail_psc_fingerprint=2f785c8d2a095c24d756807d1b2207ab; __utma=187553192.1257968989.1500911362.1500911362.1500911362.1; usertrack=c+xxCloCbmxqP6+QAyC6Ag==; _ga=GA1.2.1257968989.1500911362; P_INFO=lvguang2017@126.com|1500911361|2|mail126|00&99|null&null&null#jis&320400#10#0#0|&0||lvguang2017@126.com; _iuqxldmzr_=32; _ntes_nnid=5369e89fab2ece7dbd6b79d8e2d550c8,1530419088176; WM_TID=8InlDBo86N3VCZYFN%2FRF9bpJAT9H7usX; __utmz=94650624.1532622156.3.3.utmcsr=baidu|utmccn=(organic)|utmcmd=organic|utmctr=%E7%BD%91%E6%98%93%E4%BA%91%E9%9F%B3%E4%B9%90; UM_distinctid=164d76634ff74b-0e4c42fc9d872a-16386952-fa000-164d7663500369; JSESSIONID-WYYY=8IF0H5Dw0maPJs5Sl9IyVO8zCM%2B%2FBPHms9%2BWh0fURJrK3%5CCQgk%2FeUXQbXqHkidJV4XcKJxSwGMB1dbFG6CFGpVIXWgjOB5id3Re4%5COSwleME%2By7rK3e3c2obyZbw6oZ2ajWeprtCDwRzACzj4EEtMagA4b8FKrZBZJPH90kTvRjrg1X6%3A1532959000123; __utma=94650624.1257968989.1500911362.1532622156.1532957200.4; CNZZDATA1272960468=230797546-1529207902-%7C1532956326; WM_NI=mKwIFkBWWvsLs%2B7pjSQ1KvdKzL5V2%2FqSagQD8E7khcfOSTrcActEhSwN37NltCP5mhsqnYlmeAGkBH1Hov7QEd0Cv0F7YGr%2F1e2D8zptgNB6QXrGoSHrs%2Bjosm84AfB8ZUI%3D; WM_NIKE=9ca17ae2e6ffcda170e2e6ee94e15db0f598b7ca72939b8eafcf70bb8782a7cc3989b6a4aef83ca88a8f88c12af0fea7c3b92aaf95b9aac56182899997f248b1f5f991e95993ef8597e741ba94fbb7b125b38daf88d450fc9bf98ceb69a6919db5f16983bdbca6eb59b592fdd8cd68b89da0d6f064b1afa2baef67a79f898cc144f398a197b65b87bc00a4f53c86e997a8f125f3bbfea5bb72b4aca9afc13e9388bea8ee598caebdcce965b1b3f8d5c46e82e896b6cc37e2a3; vjlast=1498382518.1536253739.21; ne_analysis_trace_id=1536253739504; s_n_f_l_n3=a8b50a368f7dbf571536253739510; _antanalysis_s_id=1536253739645; NNSSPID=c2406ba83fdc4057b9df93472b64cef3; vinfo_n_f_l_n3=a8b50a368f7dbf57.1.4.1498382518526.1516541041868.1536325943148";
    [manager.requestSerializer setValue:cook forHTTPHeaderField:@"Cookie"];
    [manager POST:url
       parameters:params
         progress:^(NSProgress * _Nonnull uploadProgress) {
             
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSArray *arr = [responseObject objectForKey:@"data"];
             NSDictionary *data = arr.firstObject;
             if (data)
             {
                 NSString *url = [data objectForKey:@"url"];
                 
                 finishblock(url);
             }
             else
             {
                  finishblock(nil);
             }
             
             
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
             finishblock(nil);
         }];
}

//根据歌曲id获取参数
-(NSDictionary*)getSongdicWithsongid:(NSString*)songid
{
    NSString *aespath = [[NSBundle mainBundle] pathForResource:@"aes" ofType:@"js"];
    NSString *aespathstr= [NSString stringWithContentsOfFile:aespath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *bigint = [[NSBundle mainBundle] pathForResource:@"bigint" ofType:@"js"];
    NSString *bigintstr = [NSString stringWithContentsOfFile:bigint encoding:NSUTF8StringEncoding error:nil];
    
    NSString *request_netease = [[NSBundle mainBundle] pathForResource:@"request_netease" ofType:@"js"];
    NSString *request_neteaseStr = [NSString stringWithContentsOfFile:request_netease encoding:NSUTF8StringEncoding error:nil];
    
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript:aespathstr];
    [context evaluateScript:bigintstr];
    [context evaluateScript:request_neteaseStr];
    
    JSValue *function =context[@"go_request"];
    
    if (!songid)
    {
        songid=@"123";
    }
    JSValue *s = [function callWithArguments:@[songid]];
    
    return [s toDictionary];
}

- (void)netease_RequestMusicLyricDataWithParameters:(NSDictionary*)parameters andFinishBlock:(finishURLBlock)finishblock
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *songid = [parameters objectForKey:@"songid"];
    NSDictionary *params = [self getSongLyricdicWithsongid:songid?:@""];
    
    NSString *url = @"http://music.163.com/weapi/song/lyric?csrf_token=";
    [manager.requestSerializer
     setValue:@"application/x-www-form-urlencoded"
     forHTTPHeaderField:@"Content-Type"];
    
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:url
       parameters:params
         progress:^(NSProgress * _Nonnull uploadProgress) {
             
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSDictionary *dic = [responseObject objectForKey:@"lrc"];
             NSString *lyric = [dic objectForKey:@"lyric"];
             if (bbx_StringValid(lyric))
             {
                 finishblock(lyric);
             }
             else
             {
                 finishblock(nil);
             }
             
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
             finishblock(nil);
         }];
}

//根据歌曲id获取参数-获取歌词
-(NSDictionary*)getSongLyricdicWithsongid:(NSString*)songid
{
    NSString *aespath = [[NSBundle mainBundle] pathForResource:@"aes" ofType:@"js"];
    NSString *aespathstr= [NSString stringWithContentsOfFile:aespath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *bigint = [[NSBundle mainBundle] pathForResource:@"bigint" ofType:@"js"];
    NSString *bigintstr = [NSString stringWithContentsOfFile:bigint encoding:NSUTF8StringEncoding error:nil];
    
    NSString *request_netease = [[NSBundle mainBundle] pathForResource:@"request_netease" ofType:@"js"];
    NSString *request_neteaseStr = [NSString stringWithContentsOfFile:request_netease encoding:NSUTF8StringEncoding error:nil];
    
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript:aespathstr];
    [context evaluateScript:bigintstr];
    [context evaluateScript:request_neteaseStr];
    
    JSValue *function =context[@"go_requestsonglyric"];
    
    if (!songid)
    {
        songid=@"123";
    }
    JSValue *s = [function callWithArguments:@[songid]];
    
    return [s toDictionary];
}
@end
