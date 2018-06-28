//
//  BlueMusicModel.h
//  blueMusic
//
//  Created by lining on 2018/6/27.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "JSONModel.h"

@interface BlueMusicModel : JSONModel

@property (strong, nonatomic) NSString<Optional>* objectid;

@property (nonatomic, copy) NSString *playurl_mp3;
@property (nonatomic, copy) NSString *picurl_blur;
@property (nonatomic, copy) NSString *picurl_normal;

@property (nonatomic, copy) NSString *album;

@property (nonatomic, copy) NSString *artists_name;

@property (nonatomic, copy) NSString *blurPicUrl;



@property (nonatomic, copy) NSString *blurpicfile_url;


@property (nonatomic, copy) NSString *duration;

@property (nonatomic, copy) NSString *lyric;

@property (nonatomic, copy) NSString *mp3Url;

@property (nonatomic, copy) NSString *MP3file_url;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *picUrl;


@property (nonatomic, copy) NSString *picfile_url;




@property (nonatomic, copy) NSString *singer;

@property (nonatomic, copy) NSString *mId;

@property(nonatomic,strong)UIImage *image;
@end
