//
//  MusicDataHandle.m
//
//
//  Created by biubiu on 15/11/3.
//  Copyright © 2015年 lining. All rights reserved.
//
#import "Headers.h"
#import "MusicDataHandle.h"
#import <AFNetworking/AFNetworking.h>
#import <bluebox/bluebox.h>
#import "SecurityUtil.h"
#import "NSData+Encryption.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <TFHpple/TFHpple.h>
#import "BlueMusicPlayListModel.h"

static MusicDataHandle *musicHandle=nil;

@interface MusicDataHandle()<NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>


@property(nonatomic,copy)NSString *dbPath;//数据库的路径
@property(nonatomic,copy)NSString *filesPath;//存放从数据库获取的文件的文件夹
@property(nonatomic,copy)NSString *projectPath;//沙盒文件夹路径

@property(nonatomic,strong)NSURLRequest *request;
@property(nonatomic,strong)NSURLSession *session;
@property(nonatomic,strong)NSURLSessionDownloadTask *task;

@property(nonatomic,strong)MusicModel *currModel;

@property(assign,nonatomic) BOOL Error;
@property(nonatomic,strong)NSData *data_mp3;

@property(nonatomic,strong)NSData *data_pic;

@property(nonatomic,strong)NSData *data_blurpic;
@property(nonatomic,assign)NSInteger songNum;

@end

@implementation MusicDataHandle

-(NSString*)filesPath
{
    if (_filesPath==nil)
    {
        NSString * cachesPath=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        
        //创建一个新文件夹存放从数据库获得的数据
        NSString *s=[NSString stringWithFormat:@"/%@fileFromNet",[self getNowDate]];
        self.filesPath =[cachesPath stringByAppendingPathComponent:s];
        NSFileManager *m=[NSFileManager defaultManager];//单例
        [m createDirectoryAtPath:self.filesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _filesPath;
    
    
}

-(NSString *)projectPath
{
    if (_projectPath==nil)
    {
        NSString * documents=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        self.projectPath = [documents substringWithRange:NSMakeRange(0, [documents length] - 10)];//    /documents->正好10个字符
    }
    return _projectPath;
}

-(void)getMusicDataFromLC
{
    AVQuery *query = [AVQuery queryWithClassName:@"musicAtLC"];
    query.limit = 220; // 最多返回 800 条结果
    // 按发帖时间升序排列
    [query orderByAscending:@"createdAt"];
    NSArray *arr =  [query findObjects];
    if (arr)
    {
        for (AVObject *dic in arr)
        {
            MusicModel *m = [[MusicModel alloc]init];
            NSDictionary *ddic =[dic objectForKey:@"localData"];
            [m setValuesForKeysWithDictionary:ddic];
            m.objectid = [dic objectForKey:@"objectId"];
            [self.musicArray addObject:m];
        }
    }
}

//从网址下载音乐
+(instancetype)shareMusicDataHandleWithFinishBlock:(finishBlock)finishblock
{
    if (musicHandle==nil)
    {
        musicHandle =[[MusicDataHandle alloc]init];
        musicHandle.musicArray =[NSMutableArray array];
        musicHandle.musicPLArray =[NSMutableArray array];
        //开辟一个子线程
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
          // [musicHandle getNetDataFromWangyi:nil WithFinishBlock:finishblock];
           // finishblock();
           //[musicHandle getNetPlaylistDataFromWangyi:nil WithFinishBlock:finishblock];
            
            [musicHandle getPlayListFromHTMLWithFinishBlock:finishblock];
            //[musicHandle getPlayListFromHTMLByJSWithFinishBlock:finishblock];
        });//开辟一个子线程
    }
    return musicHandle;
}

-(BlueMusicPlayListModel *)musicPlayListWithIndex:(NSInteger)index
{
    return self.musicPLArray[index];
}

-(NSInteger)musicPLDataCount
{
    return self.musicPLArray.count;
}

-(NSInteger)musicDataCount
{
    return self.musicArray.count;
}

-(MusicModel *)musicWithIndex:(NSInteger)index
{
    return self.musicArray[index];
}

//获取当前日期
-(NSString *)getNowDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
 
    return destDateString;
}

#pragma mark --下载
-(void)downloadmp3:(NSString *)url
{
     NSURL *uurl = [NSURL URLWithString:url];
    
    //创建请求对象  默认是get请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:uurl];
    //创建响应对象
    NSURLResponse * response=nil;
    //错误
    NSError *error=nil;
    //建立连接，传输数据
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //打印响应
    //NSLog(@"response=%@",response);
    
    //解析时候，data为空，就会崩溃
    if (data!=nil)
    {
        self.data_mp3=data;
    }
    else
    {
        NSLog(@"获取MP3数据失败。");
        self.Error=YES;
    }

}

-(void)downloadpic:(NSString *)url
{
    NSURL *uurl = [NSURL URLWithString:url];
    //创建请求对象  默认是get请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:uurl];
    //创建响应对象
    NSURLResponse * response=nil;
    //错误
    NSError *error=nil;
    //建立连接，传输数据
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //打印响应
    NSLog(@"response=%@",response);
    
    //解析时候，data为空，就会崩溃
    if (data!=nil)
    {
        self.data_pic=data;
    }
    else
    {
        NSLog(@"获取pic数据失败。");
        
        self.Error=YES;
    }
}

-(void)downloadblurpic:(NSString *)url{
    
    NSURL *uurl = [NSURL URLWithString:url];
    
    
    //创建请求对象  默认是get请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:uurl];
    //创建响应对象
    NSURLResponse * response=nil;
    //错误
    NSError *error=nil;
    //建立连接，传输数据
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //打印响应
    NSLog(@"response=%@",response);
    
    //解析时候，data为空，就会崩溃
    if (data!=nil)
    {
        self.data_blurpic = data;
    }
    else
    {
        NSLog(@"获取blurpic数据失败。");
        
        self.Error=YES;
    }
    
}



-(void)startDownload:(NSString*)url
{
    NSURL *uurl = [NSURL URLWithString:url];
    
    /*
    self.request=[NSURLRequest requestWithURL:uurl];
    NSURLSessionConfiguration *conf =[NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
    
    
    self.task = [self.session downloadTaskWithRequest:self.request];
    
    [self.task resume];
    
    */
    
}
//下载完成
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    
    NSLog(@"下载完成");
    NSLog(@"location=%@",location);
    NSData *data =[NSData dataWithContentsOfURL:location];
   
    
    NSString  *filemp3=  [self.filesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@平凡之路-片段.mp3",[self getNowDate]]];
    [data writeToFile:filemp3 atomically:YES];
    
}

//下载多少
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
    
    
}

//下载进度下载总量---进度--文件大小
//BytesWritten--当前写入文件的大小
//totalBytesWritten--已经写入文件的大小
//totalBytesExpectedToWrite--文件总大小
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
  //  NSLog(@"正在下载。");
   // NSLog(@"bytesWritten=%lld",bytesWritten/1024);
  //  NSLog(@"totalBytesExpectedToWrite=%lld",totalBytesExpectedToWrite/1024);
    
    //self.myPro.progress = bytesWritten/totalBytesExpectedToWrite ;
    
    //[self.myPro setProgress:bytesWritten/totalBytesExpectedToWrite animated:YES];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.myPro.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
//        
//    });
    
}


#pragma mark --Leancloud操作
-(BOOL)haveThisMp3:(MusicModel*)m
{
    AVQuery *query = [AVQuery queryWithClassName:@"musicAtLC"];
    [query whereKey:@"name" equalTo:m.name];
    NSArray *postArray = [query findObjects];
    if (postArray.count>0)
    {
       return YES;
    }
   else return NO;
}

-(void)updatetoLC:(MusicModel*)m
{
    // 第一个参数是 className，第二个参数是 objectId
    AVObject *todo =[AVObject objectWithClassName:@"musicAtLC" objectId:m.objectid];
    // 修改属性
    [todo setObject:m.playurl_mp3 forKey:@"mp3Url"];
    [todo setObject:m.picurl_normal forKey:@"picUrl"];
    [todo setObject:m.picurl_normal forKey:@"picfile_url"];
    [todo setObject:m.picurl_blur forKey:@"blurPicUrl"];
    [todo setObject:m.picurl_blur forKey:@"blurpicfile_url"];
    
    // 保存到云端
    [todo saveInBackground];
}

-(BOOL)savetoLC:(MusicModel*)m
{
    /*
    AVObject *post = [AVObject objectWithClassName:@"musicAtLC"];
    //歌曲名字
    post[@"name"] =m.name;
    //album名字
    post[@"album"] = m.album;
    //演唱者
    post[@"singer"] = m.singer;//
    
    
    //原唱
    post[@"artists_name"] = m.artists_name;
    //lyric歌词
    post[@"lyric"] = m.lyric;
    
    //duration 长度 多少毫秒
    post[@"duration"] = m.duration;
    
    //mp3Url
    
    post[@"mp3Url"] = m.mp3Url;
    //picUrl
    
    post[@"picUrl"] = m.picUrl;
    //blurPicUrl
    
    post[@"blurPicUrl"] = m.blurPicUrl;
    //id
    
    post[@"mId"] = m.mId;
    
    NSString *mp3name =[NSString stringWithFormat:@"%@.mp3",m.name];
    AVFile *MP3file = [AVFile fileWithName:mp3name data:self.data_mp3];
    
    
    [MP3file save];
    
    [post setObject:MP3file  forKey:@"MP3file"];
    
  
    NSString *picname =[NSString stringWithFormat:@"%@.jpg",m.name];
    AVFile *picfile = [AVFile fileWithName:picname data:self.data_pic];
    
    
    [picfile save];
    
    [post setObject:picfile  forKey:@"picfile"];
    
  
    NSString *blurpicname =[NSString stringWithFormat:@"blur-%@.jpg",m.name];
    AVFile *blurpicfile = [AVFile fileWithName:blurpicname data:self.data_blurpic];
    
    
    [blurpicfile save];
    
    [post setObject:blurpicfile  forKey:@"blurpicfile"];
    
    
    
    if ([post save]) {
        NSLog(@"%@保存成功",m.name);
        return YES;
    } else
    {
        
        
        NSLog(@"%@保存失败",m.name);
        
        return NO;
    
    }
    
    */
    return NO;
     
}

- (void)getNetDataFromWangyi:(NSString *)type WithFinishBlock:(finishBlock)finishblock;
{
   // [self testjs];
//    NSString *originalString = @"加密这个字符串";
//    NSString * secretStr = @"秘钥是这个";
//    //CBC加密字符串
//    NSString * encryptCBC = [SecurityUtil  encryptAESData: originalString Withkey:@"uuid" ivkey: secretStr];
//    //CBC解密字符串
//    NSString * decryptCBC = [SecurityUtil  decryptAESData: encryptCBC Withkey:@"uuid" ivkey: secretStr];
//    
//  
      typeof(self) weakSelf = self;
    
    // 请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *dd = @{@"ids":@[@"502218792"],@"br":@320000,@"csrf_token":@""};
    NSString *orr = [self convertToJsonData:dd];//[NSJSONSerialization dataWithJSONObject:dd options:NSJSONWritingPrettyPrinted error:nil];
   // NSString *orr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *nonce = @"0CoJUm6Qyw8W8jud";
    
    NSString *sec_orr = [SecurityUtil encryptAESData:orr Withkey:nonce ivkey:@"0102030405060708"];//[orr blueaes256_encrypt:nonce];
    NSString *s16Key = [self createSecretKeyWithLength:16];
    NSString *finalstr = [SecurityUtil encryptAESData:sec_orr Withkey:s16Key ivkey:@"0102030405060708"];//[sec_orr blueaes256_encrypt:s16Key];
    
    // 拼接请求参数
    NSMutableDictionary *params = [self testjs];
    NSString *encSecKey =  @"92f9a89487c36866e985ec347a0456a81ac0a14263309ac601735517d16375201eb14e43160e35416316ba3713d47f12644fde31f85134e7625abcbed24193f07b4620d57b99e131dab8b5661ca18304e2187a44478b84e8c8e77b8a0639a8061ca510d5fa2f8d0ceb38c092ae5a5b49989f17556cef59a828f8b4c264c1e0e1";
    
   // [params setObject:[self dsl_encodeUrl:encSecKey] forKey:@"encSecKey"];
    NSString *pa = @"wr2aYQTi6pVLvBEMJTBZm1KcKHRJHeE89FzRXeJn6hI4jV+jkEntyHy0WFGjlgiYUv17yZ3gSn6TJfzDnFuOy1Ry42n6UcYlj+vERqovKaZDFhwKGwUx25/JGTu0C4g/";
    //[params setObject:[self dsl_encodeUrl:finalstr] forKey:@"params"];
    
    NSString *url = @"http://music.163.com/weapi/song/enhance/player/url?csrf_token=";
    [manager.requestSerializer
     setValue:@"application/x-www-form-urlencoded"
     forHTTPHeaderField:@"Content-Type"];
   
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
   
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:url
       parameters:params
         progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@",responseObject);
        NSArray *arr = [responseObject objectForKey:@"data"];
        NSDictionary *data = arr.firstObject;
        if (data)
        {
            NSString *url = [data objectForKey:@"url"];
            NSNumber *title = [data objectForKey:@"id"];
            MusicModel *m = [[MusicModel alloc]init];
            m.name = title.stringValue;
            m.mp3Url = url;
            m.playurl_mp3 = url;
            m.MP3file_url = url;
            m.duration =@303000;
              [weakSelf.musicArray addObject:m];
        }
        
        finishblock();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
        finishblock();
    }];
    
}
-(NSString* )dsl_encodeUrl:(NSString*)sss{
    if (![sss isKindOfClass:[NSString class]]||sss.length == 0)
    {
        return nil;
    }
    
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                    (CFStringRef)sss,
                                                                                                    (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                                                                    NULL,
                                                                                                    kCFStringEncodingUTF8));
    return encodedString;
}

/*
 function createSecretKey($length=16){
 $str='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
 $r='';
 for($i=0;$i<$length;$i++){
 $r.=$str[rand(0,strlen($str)-1)];
 }
 return $r;
 }
 
 
 */

-(NSString*)createSecretKeyWithLength:(NSInteger)len
{
    NSString *str = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSString *result = nil;
    
    for (int i=0; i<len; i++)
    {
        NSInteger randomIndex  = arc4random() % str.length;
        
        NSRange    rangeOne = NSMakeRange(randomIndex, 1);
        
        if (!result)
        {
            result = [str substringWithRange:rangeOne];
        }
        else
        {
            result = [NSString stringWithFormat:@"%@%@",result,[str substringWithRange:rangeOne]];
        }
    }
    
    return result;
}

-(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    
    NSString *ff = [self removeSpecilaStr:mutStr];
    
    return ff;
    
}

- (NSString *)removeSpecilaStr:(NSString*)sss
{
    NSMutableString *responseString = [NSMutableString stringWithString:sss];
    NSString *character = nil;
    for (int i = 0; i < responseString.length; i ++) {
        character = [responseString substringWithRange:NSMakeRange(i, 1)];
        if ([character isEqualToString:@"\\"])
            [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
    }
    return responseString;
}

-(NSDictionary*)testjs
{
    NSString *aespath = [[NSBundle mainBundle] pathForResource:@"aes" ofType:@"js"];
    NSString *aespathstr= [NSString stringWithContentsOfFile:aespath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *bigint = [[NSBundle mainBundle] pathForResource:@"bigint" ofType:@"js"];
    NSString *bigintstr = [NSString stringWithContentsOfFile:bigint encoding:NSUTF8StringEncoding error:nil];
    
    NSString *jshi = [[NSBundle mainBundle] pathForResource:@"jshi" ofType:@"js"];
    NSString *jshiStr = [NSString stringWithContentsOfFile:jshi encoding:NSUTF8StringEncoding error:nil];
    
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript:aespathstr];
    [context evaluateScript:bigintstr];
    [context evaluateScript:jshiStr];
    
    JSValue *function =context[@"go_request"];
    
    NSString *s1 = @"sU49pNzNAZvdv6u9TMxxeFLOb18XniYbISCVtw2qk1oEUaZWQt7Rf/X2Bj/ihKjbYu5lf3vqswAyvNOgpie8iQ==";
    NSString* s2 = @"a4ad299e9eab0563";
    
    JSValue *s = [function callWithArguments:@[@"26352841"]];//@"34144485"
    NSLog(@"s=%@",[s toDictionary]);
    
    return [s toDictionary];
}

- (void)getNetPlaylistDataFromWangyi:(NSString *)type WithFinishBlock:(finishBlock)finishblock
{
    typeof(self) weakSelf = self;
    
    // 请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = @"http://music.163.com/discover/playlist/?order=hot&limit=35&offset=70";
       NSString * userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36";
    [manager.requestSerializer setValue:@"text/html;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"UserAgent"];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager GET:url
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@",responseObject);
        NSArray *arr = [responseObject objectForKey:@"data"];
        NSDictionary *data = arr.firstObject;
        if (data)
        {
        }
        
        finishblock();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
        finishblock();
    }];
   
}

-(void)setua
{
    //https://blog.csdn.net/chenyufeng1991/article/details/47425799
    NSString *url = @"http://music.163.com/discover/playlist/?order=hot&limit=35&offset=0";
    NSURL *rr = [NSURL URLWithString:url];
    //NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *ss = [NSString stringWithContentsOfURL:rr encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"ss= %@",ss);
}

-(void)getPlayListFromHTMLWithFinishBlock:(finishBlock)finishblock
{
    //NSString *titlesArr = [NSMutableArray array];
    
    NSURL *url = [NSURL URLWithString:@"http://music.163.com/discover/playlist/?order=hot&limit=35&offset=0"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    TFHpple *xpthParser = [[TFHpple alloc]initWithHTMLData:data];
    NSArray *dataArr = [xpthParser searchWithXPathQuery:@"//ul"];
    NSMutableArray *dataArrNew = [NSMutableArray array];
    for (TFHppleElement *hppleElement in dataArr)
    {
        NSString *clssss = hppleElement.attributes[@"class"];
        if ([clssss containsString:@"m-cvrlst"] ) //@"m-cvrlst"
        {
            [dataArrNew addObject:hppleElement];
          
        }
    }
    
    NSMutableArray *plArr = [NSMutableArray array];
    
    if (dataArrNew.count>0)
    {
        for (TFHppleElement *hppleElement in dataArrNew)
        {
            NSArray *dataArray = [hppleElement searchWithXPathQuery:@"//li"];
            for (TFHppleElement *HppleElement in dataArray)
            {
                //NSLog(@"%@",HppleElement.raw);
                //NSLog(@"%@",HppleElement.text);
                
                BlueMusicPlayListModel *plModel = [[BlueMusicPlayListModel alloc]init];
                
                NSArray *tArray = [HppleElement searchWithXPathQuery:@"//div//a"];
                TFHppleElement *pp = tArray.firstObject;
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
                NSArray *imgArray = [HppleElement searchWithXPathQuery:@"//div//img"];
                TFHppleElement *imgtt = imgArray.firstObject;
                NSString *img = imgtt.attributes[@"src"];
                
                plModel.cover_img_url = img;
                
                [plArr addObject:plModel];
            }
        }
       
    }
    
    if (plArr.count>0)
    {
        NSLog(@"plArr = %@",plArr);
        [musicHandle.musicPLArray addObjectsFromArray:plArr];
    }
    
    if (finishblock)
    {
        finishblock();
    }
}

-(void)getPlayListFromHTMLByJSWithFinishBlock:(finishBlock)finishblock
{
    NSString *aespath = [[NSBundle mainBundle] pathForResource:@"angular.min" ofType:@"js"];
    NSString *aespathstr= [NSString stringWithContentsOfFile:aespath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *bigint = [[NSBundle mainBundle] pathForResource:@"bigint" ofType:@"js"];
    NSString *bigintstr = [NSString stringWithContentsOfFile:bigint encoding:NSUTF8StringEncoding error:nil];
    
    NSString *jshi = [[NSBundle mainBundle] pathForResource:@"jshi" ofType:@"js"];
    NSString *jshiStr = [NSString stringWithContentsOfFile:jshi encoding:NSUTF8StringEncoding error:nil];
    
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript:aespathstr];
    [context evaluateScript:bigintstr];
    [context evaluateScript:jshiStr];
    
    JSValue *function =context[@"go_show_playlist"];
    
    NSString *s1 = @"hot";
    NSString* s2 = @"35";
    
    JSValue *s = [function callWithArguments:@[s1,s2]];
    NSLog(@"s=%@",[s toDictionary]);
}
@end
