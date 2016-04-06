//
//  ClassifierModel.m
//  AffdexMe
//
//  Created by Boisy Pitre on 3/15/16.
//  Copyright © 2016 tee-boy. All rights reserved.
//

#import "ClassifierModel.h"
#import <Affdex/Affdex.h>
#import "NSImage+Extensions.h"

@implementation ClassifierModel

// Emotions
static ClassifierModel *anger, *contempt, *disgust, *engagement, *fear, *joy, *sadness, *surprise, *valence;

// Expressions
static ClassifierModel *attention, *browRaise, *browFurrow, *eyeClosure, *innerBrowRaise, *frown, *lipPress, *lipPucker, *lipSuck, *mouthOpen, *noseWrinkle, *smile, *smirk, *upperLipRaise;

static ClassifierModel *laughing, *smiley, *relaxed, *wink, *kiss, *tongueWink, *tongueOut, *flushed, *disappointed, *rage, *scream, *emojiSmirk;

static CGFloat emojiFontSize = 80.0;

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    if (self = [super init])
    {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.scoreProperty = [aDecoder decodeObjectForKey:@"scoreProperty"];
        self.image = [aDecoder decodeObjectForKey:@"image"];
        self.emojiCode = [aDecoder decodeObjectForKey:@"emojiCode"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.scoreProperty forKey:@"scoreProperty"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.emojiCode forKey:@"emojiCode"];
}

+ (void)initialize;
{
    if (anger == nil)
    {
        anger = [[ClassifierModel alloc] init];
        anger.name = @"anger";
        anger.title = @"Anger";
        NSString *path = [[NSBundle mainBundle] pathForResource:anger.title ofType:@"jpg" inDirectory:@"media/images"];
        anger.image = [[NSImage alloc] initWithContentsOfFile:path];
        anger.scoreProperty = @"emotions.anger";
    }
    
    if (contempt == nil)
    {
        contempt = [[ClassifierModel alloc] init];
        contempt.name = @"contempt";
        contempt.title = @"Contempt";
        NSString *path = [[NSBundle mainBundle] pathForResource:contempt.title ofType:@"jpg" inDirectory:@"media/images"];
        contempt.image = [[NSImage alloc] initWithContentsOfFile:path];
        contempt.scoreProperty = @"emotions.contempt";
    }
    
    if (disgust == nil)
    {
        disgust = [[ClassifierModel alloc] init];
        disgust.name = @"disgust";
        disgust.title = @"Disgust";
        NSString *path = [[NSBundle mainBundle] pathForResource:disgust.title ofType:@"jpg" inDirectory:@"media/images"];
        disgust.image = [[NSImage alloc] initWithContentsOfFile:path];
        disgust.scoreProperty = @"emotions.disgust";
    }

    if (engagement == nil)
    {
        engagement = [[ClassifierModel alloc] init];
        engagement.name = @"engagement";
        engagement.title = @"Engagement";
        NSString *path = [[NSBundle mainBundle] pathForResource:engagement.title ofType:@"jpg" inDirectory:@"media/images"];
        engagement.image = [[NSImage alloc] initWithContentsOfFile:path];
        engagement.scoreProperty = @"emotions.engagement";
    }
    
    if (fear == nil)
    {
        fear = [[ClassifierModel alloc] init];
        fear.name = @"fear";
        fear.title = @"Fear";
        NSString *path = [[NSBundle mainBundle] pathForResource:fear.title ofType:@"jpg" inDirectory:@"media/images"];
        fear.image = [[NSImage alloc] initWithContentsOfFile:path];
        fear.scoreProperty = @"emotions.fear";
    }
    
    if (joy == nil)
    {
        joy = [[ClassifierModel alloc] init];
        joy.name = @"joy";
        joy.title = @"Joy";
        NSString *path = [[NSBundle mainBundle] pathForResource:joy.title ofType:@"jpg" inDirectory:@"media/images"];
        joy.image = [[NSImage alloc] initWithContentsOfFile:path];
        joy.scoreProperty = @"emotions.joy";
    }
    
    if (sadness == nil)
    {
        sadness = [[ClassifierModel alloc] init];
        sadness.name = @"sadness";
        sadness.title = @"Sadness";
        NSString *path = [[NSBundle mainBundle] pathForResource:sadness.title ofType:@"jpg" inDirectory:@"media/images"];
        sadness.image = [[NSImage alloc] initWithContentsOfFile:path];
        sadness.scoreProperty = @"emotions.sadness";
    }
    
    if (surprise == nil)
    {
        surprise = [[ClassifierModel alloc] init];
        surprise.name = @"surprise";
        surprise.title = @"Surprise";
        NSString *path = [[NSBundle mainBundle] pathForResource:surprise.title ofType:@"jpg" inDirectory:@"media/images"];
        surprise.image = [[NSImage alloc] initWithContentsOfFile:path];
        surprise.scoreProperty = @"emotions.surprise";
    }
    
    if (valence == nil)
    {
        valence = [[ClassifierModel alloc] init];
        valence.name = @"valence";
        valence.title = @"Valence";
        NSString *path = [[NSBundle mainBundle] pathForResource:valence.title ofType:@"jpg" inDirectory:@"media/images"];
        valence.image = [[NSImage alloc] initWithContentsOfFile:path];
        valence.scoreProperty = @"emotions.valence";
    }

    if (attention == nil)
    {
        attention = [[ClassifierModel alloc] init];
        attention.name = @"attention";
        attention.title = @"Attention";
        NSString *path = [[NSBundle mainBundle] pathForResource:attention.title ofType:@"jpg" inDirectory:@"media/images"];
        attention.image = [[NSImage alloc] initWithContentsOfFile:path];
        attention.scoreProperty = @"expressions.attention";
    }

    if (browFurrow == nil)
    {
        browFurrow = [[ClassifierModel alloc] init];
        browFurrow.name = @"browFurrow";
        browFurrow.title = @"Brow Furrow";
        NSString *path = [[NSBundle mainBundle] pathForResource:browFurrow.title ofType:@"jpg" inDirectory:@"media/images"];
        browFurrow.image = [[NSImage alloc] initWithContentsOfFile:path];
        browFurrow.scoreProperty = @"expressions.browFurrow";
    }

    if (browRaise == nil)
    {
        browRaise = [[ClassifierModel alloc] init];
        browRaise.name = @"browRaise";
        browRaise.title = @"Brow Raise";
        NSString *path = [[NSBundle mainBundle] pathForResource:browRaise.title ofType:@"jpg" inDirectory:@"media/images"];
        browRaise.image = [[NSImage alloc] initWithContentsOfFile:path];
        browRaise.scoreProperty = @"expressions.browRaise";
    }

    if (eyeClosure == nil)
    {
        eyeClosure = [[ClassifierModel alloc] init];
        eyeClosure.name = @"eyeClosure";
        eyeClosure.title = @"Eye Closure";
        NSString *path = [[NSBundle mainBundle] pathForResource:eyeClosure.title ofType:@"jpg" inDirectory:@"media/images"];
        eyeClosure.image = [[NSImage alloc] initWithContentsOfFile:path];
        eyeClosure.scoreProperty = @"expressions.eyeClosure";
    }
    
    if (innerBrowRaise == nil)
    {
        innerBrowRaise = [[ClassifierModel alloc] init];
        innerBrowRaise.name = @"innerBrowRaise";
        innerBrowRaise.title = @"Inner Brow Raise";
        NSString *path = [[NSBundle mainBundle] pathForResource:innerBrowRaise.title ofType:@"jpg" inDirectory:@"media/images"];
        innerBrowRaise.image = [[NSImage alloc] initWithContentsOfFile:path];
        innerBrowRaise.scoreProperty = @"expressions.innerBrowRaise";
    }
    
    if (frown == nil)
    {
        frown = [[ClassifierModel alloc] init];
        frown.name = @"lipCornerDepressor";
        frown.title = @"Frown";
        NSString *path = [[NSBundle mainBundle] pathForResource:frown.title ofType:@"jpg" inDirectory:@"media/images"];
        frown.image = [[NSImage alloc] initWithContentsOfFile:path];
        frown.scoreProperty = @"expressions.lipCornerDepressor";
    }
    
    if (lipPress == nil)
    {
        lipPress = [[ClassifierModel alloc] init];
        lipPress.name = @"lipPress";
        lipPress.title = @"Lip Press";
        NSString *path = [[NSBundle mainBundle] pathForResource:lipPress.title ofType:@"jpg" inDirectory:@"media/images"];
        lipPress.image = [[NSImage alloc] initWithContentsOfFile:path];
        lipPress.scoreProperty = @"expressions.lipPress";
    }
    
    if (lipPucker == nil)
    {
        lipPucker = [[ClassifierModel alloc] init];
        lipPucker.name = @"lipPucker";
        lipPucker.title = @"Lip Pucker";
        NSString *path = [[NSBundle mainBundle] pathForResource:lipPucker.title ofType:@"jpg" inDirectory:@"media/images"];
        lipPucker.image = [[NSImage alloc] initWithContentsOfFile:path];
        lipPucker.scoreProperty = @"expressions.lipPucker";
    }
    
    if (lipSuck == nil)
    {
        lipSuck = [[ClassifierModel alloc] init];
        lipSuck.name = @"lipSuck";
        lipSuck.title = @"Lip Suck";
        NSString *path = [[NSBundle mainBundle] pathForResource:lipSuck.title ofType:@"jpg" inDirectory:@"media/images"];
        lipSuck.image = [[NSImage alloc] initWithContentsOfFile:path];
        lipSuck.scoreProperty = @"expressions.lipSuck";
    }
    
    if (mouthOpen == nil)
    {
        mouthOpen = [[ClassifierModel alloc] init];
        mouthOpen.name = @"mouthOpen";
        mouthOpen.title = @"Mouth Open";
        NSString *path = [[NSBundle mainBundle] pathForResource:mouthOpen.title ofType:@"jpg" inDirectory:@"media/images"];
        mouthOpen.image = [[NSImage alloc] initWithContentsOfFile:path];
        mouthOpen.scoreProperty = @"expressions.mouthOpen";
    }
    
    if (noseWrinkle == nil)
    {
        noseWrinkle = [[ClassifierModel alloc] init];
        noseWrinkle.name = @"noseWrinkle";
        noseWrinkle.title = @"Nose Wrinkle";
        NSString *path = [[NSBundle mainBundle] pathForResource:noseWrinkle.title ofType:@"jpg" inDirectory:@"media/images"];
        noseWrinkle.image = [[NSImage alloc] initWithContentsOfFile:path];
        noseWrinkle.scoreProperty = @"expressions.noseWrinkle";
    }
    
    if (smile == nil)
    {
        smile = [[ClassifierModel alloc] init];
        smile.name = @"smile";
        smile.title = @"Smile";
        NSString *path = [[NSBundle mainBundle] pathForResource:smile.title ofType:@"jpg" inDirectory:@"media/images"];
        smile.image = [[NSImage alloc] initWithContentsOfFile:path];
        smile.scoreProperty = @"expressions.smile";
    }
    
    if (smirk == nil)
    {
        smirk = [[ClassifierModel alloc] init];
        smirk.name = @"smirk";
        smirk.title = @"Smirk";
        NSString *path = [[NSBundle mainBundle] pathForResource:smirk.title ofType:@"jpg" inDirectory:@"media/images"];
        smirk.image = [[NSImage alloc] initWithContentsOfFile:path];
        smirk.scoreProperty = @"expressions.smirk";
    }
    
    if (upperLipRaise == nil)
    {
        upperLipRaise = [[ClassifierModel alloc] init];
        upperLipRaise.name = @"upperLipRaise";
        upperLipRaise.title = @"Upper Lip Raise";
        NSString *path = [[NSBundle mainBundle] pathForResource:upperLipRaise.title ofType:@"jpg" inDirectory:@"media/images"];
        upperLipRaise.image = [[NSImage alloc] initWithContentsOfFile:path];
        upperLipRaise.scoreProperty = @"expressions.upperLipRaise";
    }

    if (laughing == nil)
    {   
        laughing = [[ClassifierModel alloc] init];
        laughing.name = @"laughing";
        laughing.title = @"Laughing";
        laughing.image = [NSImage imageFromText:@"😆" size:emojiFontSize];
        laughing.scoreProperty = @"emojis.laughing";
        laughing.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_LAUGHING];
    }
    
    if (smiley == nil)
    {
        smiley = [[ClassifierModel alloc] init];
        smiley.name = @"smiley";
        smiley.title = @"Smiley";
        smiley.image = [NSImage imageFromText:@"😀" size:emojiFontSize];
        smiley.scoreProperty = @"emojis.smiley";
        smiley.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_SMILEY];
    }
    
    if (relaxed == nil)
    {
        relaxed = [[ClassifierModel alloc] init];
        relaxed.name = @"relaxed";
        relaxed.title = @"Relaxed";
        relaxed.image = [NSImage imageFromText:@"☺️" size:emojiFontSize];
        relaxed.scoreProperty = @"emojis.relaxedy";
        relaxed.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_RELAXED];
    }
    
    if (wink == nil)
    {
        wink = [[ClassifierModel alloc] init];
        wink.name = @"wink";
        wink.title = @"Wink";
        wink.image = [NSImage imageFromText:@"😉" size:emojiFontSize];
        wink.scoreProperty = @"emojis.wink";
        wink.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_WINK];
    }
    
    if (kiss == nil)
    {
        kiss = [[ClassifierModel alloc] init];
        kiss.name = @"kiss";
        kiss.title = @"Kiss";
        kiss.image = [NSImage imageFromText:@"😗" size:emojiFontSize];
        kiss.scoreProperty = @"emojis.kiss";
        kiss.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_KISSING];
    }
    
    if (tongueWink == nil)
    {
        tongueWink = [[ClassifierModel alloc] init];
        tongueWink.name = @"tongueWink";
        tongueWink.title = @"Tongue Wink";
        tongueWink.image = [NSImage imageFromText:@"😗" size:emojiFontSize];
        tongueWink.scoreProperty = @"emojis.stuckOutTongueWinkingEye";
        tongueWink.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_STUCK_OUT_TONGUE_WINKING_EYE];
    }
    
    if (tongueOut == nil)
    {
        tongueOut = [[ClassifierModel alloc] init];
        tongueOut.name = @"stuckOutTongue";
        tongueOut.title = @"Tongue Out";
        tongueOut.image = [NSImage imageFromText:@"😛" size:emojiFontSize];
        tongueOut.scoreProperty = @"emojis.stuckOutTongue";
        tongueOut.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_STUCK_OUT_TONGUE];
    }
    
    if (flushed == nil)
    {
        flushed = [[ClassifierModel alloc] init];
        flushed.name = @"flushed";
        flushed.title = @"Flushed";
        flushed.image = [NSImage imageFromText:@"😳" size:emojiFontSize];
        flushed.scoreProperty = @"emojis.flushed";
        flushed.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_FLUSHED];
    }

    if (disappointed == nil)
    {
        disappointed = [[ClassifierModel alloc] init];
        disappointed.name = @"disapointed";
        disappointed.title = @"Disappointed";
        disappointed.image = [NSImage imageFromText:@"😞" size:emojiFontSize];
        disappointed.scoreProperty = @"emojis.disapopinted";
        disappointed.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_DISAPPOINTED];
    }
    
    if (rage == nil)
    {
        rage = [[ClassifierModel alloc] init];
        rage.name = @"rage";
        rage.title = @"Rage";
        rage.image = [NSImage imageFromText:@"😡" size:emojiFontSize];
        rage.scoreProperty = @"rage";
        rage.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_RAGE];
    }
    
    if (scream == nil)
    {
        scream = [[ClassifierModel alloc] init];
        scream.name = @"scream";
        scream.title = @"Scream";
        scream.image = [NSImage imageFromText:@"😱" size:emojiFontSize];
        scream.scoreProperty = @"scream";
        scream.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_SCREAM];
    }
    
    if (emojiSmirk == nil)
    {
        emojiSmirk = [[ClassifierModel alloc] init];
        emojiSmirk.name = @"smirk";
        emojiSmirk.title = @"Smirk";
        emojiSmirk.image = [NSImage imageFromText:@"😏" size:emojiFontSize];
        emojiSmirk.scoreProperty = @"smirk";
        emojiSmirk.emojiCode = [NSNumber numberWithInt:AFDX_EMOJI_SMIRK];
    }
}

+ (ClassifierModel *)modelWithName:(NSString *)name;
{
    ClassifierModel *result = nil;
    
    for (ClassifierModel *model in [ClassifierModel emotions])
    {
        if ([name isEqualToString:model.name])
        {
            result = model;
            break;
        }
    }
    
    if (result == nil)
    {
        for (ClassifierModel *model in [ClassifierModel expressions])
        {
            if ([name isEqualToString:model.name])
            {
                result = model;
                break;
            }
        }
    }
    
    return result;
}

+ (NSMutableArray *)emotions;
{
    NSMutableArray *result = [NSMutableArray arrayWithObjects:anger, contempt, disgust, engagement, fear, joy, sadness, surprise, valence, nil];

    return result;
}

+ (NSMutableArray *)expressions;
{
    NSMutableArray *result = [NSMutableArray arrayWithObjects:attention, browFurrow, browRaise, eyeClosure, innerBrowRaise, frown, lipPress, lipPucker, lipSuck, mouthOpen, noseWrinkle, smile, smirk, upperLipRaise, nil];
    
    return result;
}

+ (NSMutableArray *)emojis;
{
    NSMutableArray *result = [NSMutableArray arrayWithObjects:laughing, smiley, relaxed, wink, kiss, tongueWink, tongueOut, flushed, disappointed, rage, scream, emojiSmirk, nil];
    
    return result;
}

@end
