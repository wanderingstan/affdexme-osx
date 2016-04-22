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
static ClassifierModel *attention, *browRaise, *browFurrow, *chinRaise, *eyeClosure, *innerBrowRaise, *frown, *lipPress, *lipPucker, *lipSuck, *mouthOpen, *noseWrinkle, *smile, *smirk, *upperLipRaise;

static ClassifierModel *laughing, *smiley, *relaxed, *wink, *kiss, *tongueWink, *tongueOut, *flushed, *disappointed, *rage, *scream, *emojiSmirk;

static CGFloat emojiFontSize = 80.0;

#define INIT_MODEL(modelProperty, modelName, modelTitle) \
    if (modelName == nil) { \
        modelName = [[ClassifierModel alloc] init]; \
        modelName.name = @""#modelName""; \
        modelName.title = @""#modelTitle""; \
        NSString *path = [[NSBundle mainBundle] pathForResource:modelName.title ofType:@"jpg" inDirectory:@"media/images"]; \
        modelName.image = [[NSImage alloc] initWithContentsOfFile:path]; \
        path = [[NSBundle mainBundle] pathForResource:modelName.title ofType:@"mp4" inDirectory:@"media/movies"]; \
        if (nil != path) { \
            modelName.movieURL = [NSURL fileURLWithPath:path]; \
        } \
        modelName.scoreProperty = @""#modelProperty"."#modelName""; \
    }

#define INIT_EMOJI_MODEL(modelName, modelTitle, emojiString, emojiEnumeration) \
    if (modelName == nil) { \
        modelName = [[ClassifierModel alloc] init]; \
        modelName.name = @""#modelName""; \
        modelName.title = @""#modelTitle""; \
        modelName.image = [NSImage imageFromText:emojiString size:emojiFontSize]; \
        modelName.scoreProperty = @"emojis.kiss"; \
        modelName.emojiCode = [NSNumber numberWithInt:emojiEnumeration]; \
    }

+ (void)initialize;
{
    INIT_MODEL(emotions, anger, Anger)
    INIT_MODEL(emotions, contempt, Contempt)
    INIT_MODEL(emotions, disgust, Disgust)
    INIT_MODEL(emotions, engagement, Engagement)
    INIT_MODEL(emotions, fear, Fear)
    INIT_MODEL(emotions, joy, Joy)
    INIT_MODEL(emotions, sadness, Sadness)
    INIT_MODEL(emotions, surprise, Surprise)
    INIT_MODEL(emotions, valence, Valence)

    INIT_MODEL(expressions, attention, Attention)
    INIT_MODEL(expressions, browFurrow, Brow Furrow)
    INIT_MODEL(expressions, browRaise, Brow Raise)
    INIT_MODEL(expressions, chinRaise, Chin Raise)
    INIT_MODEL(expressions, eyeClosure, Eye Closure)
    INIT_MODEL(expressions, innerBrowRaise, Inner Brow Raise)
    INIT_MODEL(expressions, frown, Frown)
    frown.scoreProperty = @"expressions.lipCornerDepressor";
    INIT_MODEL(expressions, lipPress, Lip Press)
    INIT_MODEL(expressions, lipPucker, Lip Pucker)
    INIT_MODEL(expressions, lipSuck, Lip Suck)
    INIT_MODEL(expressions, mouthOpen, Mouth Open)
    INIT_MODEL(expressions, noseWrinkle, Nose Wrinkle)
    INIT_MODEL(expressions, smile, Smile)
    INIT_MODEL(expressions, smirk, Smirk)
    INIT_MODEL(expressions, upperLipRaise, Upper Lip Raise)
    
    INIT_EMOJI_MODEL(laughing, Laughing, @"😆", AFDX_EMOJI_LAUGHING)
    INIT_EMOJI_MODEL(smiley, Smiley, @"😀", AFDX_EMOJI_SMILEY)
    INIT_EMOJI_MODEL(relaxed, Relaxed, @"☺️", AFDX_EMOJI_RELAXED)
    INIT_EMOJI_MODEL(wink, Wink, @"😉", AFDX_EMOJI_WINK)
    INIT_EMOJI_MODEL(kiss, Kink, @"😗", AFDX_EMOJI_KISSING)
    INIT_EMOJI_MODEL(tongueWink, Tongue Wink, @"😜", AFDX_EMOJI_STUCK_OUT_TONGUE_WINKING_EYE)
    INIT_EMOJI_MODEL(tongueOut, Tongue Out, @"😛", AFDX_EMOJI_STUCK_OUT_TONGUE)
    INIT_EMOJI_MODEL(flushed, Flushed, @"😳", AFDX_EMOJI_FLUSHED)
    INIT_EMOJI_MODEL(disappointed, Disappointed, @"😞", AFDX_EMOJI_DISAPPOINTED)
    INIT_EMOJI_MODEL(rage, Rage, @"😡", AFDX_EMOJI_RAGE)
    INIT_EMOJI_MODEL(scream, Scream, @"😱", AFDX_EMOJI_SCREAM)
    INIT_EMOJI_MODEL(emojiSmirk, Smirk, @"😏", AFDX_EMOJI_SMIRK)
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

+ (NSArray *)emotions;
{
    return [NSArray arrayWithObjects:anger, contempt, disgust, engagement, fear, joy, sadness, surprise, valence, nil];
}

+ (NSArray *)expressions;
{
    return [NSArray arrayWithObjects:attention, browFurrow, browRaise, chinRaise, eyeClosure, innerBrowRaise, frown, lipPress, lipPucker, lipSuck, mouthOpen, noseWrinkle, smile, smirk, upperLipRaise, nil];
}

+ (NSArray *)emojis;
{
    return [NSArray arrayWithObjects:laughing, smiley, relaxed, wink, kiss, tongueWink, tongueOut, flushed, disappointed, rage, scream, emojiSmirk, nil];
}

@end
