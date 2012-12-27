//
//  ChipmunkConstraint2Layer.h
//  BasicCocos2D
//
//  Created by Ian Fan on 29/08/12.
//
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "CPDebugLayer.h"

@interface ChipmunkConstraint2Layer : CCLayer
{
  ChipmunkSpace *_space;
  ChipmunkMultiGrab *_multiGrab;
  CPDebugLayer *_debugLayer;
  
  NSMutableArray *ballonMArray;
}

+(CCScene *) scene;

@end
