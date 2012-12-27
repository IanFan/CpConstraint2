//
//  ChipmunkConstraint2Layer.m
//  BasicCocos2D
//
//  Created by Ian Fan on 29/08/12.
//
//

#import "ChipmunkConstraint2Layer.h"

#define GRABABLE_MASK_BIT (1<<31)
#define NOT_GRABABLE_MASK (~GRABABLE_MASK_BIT)

@implementation ChipmunkConstraint2Layer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	ChipmunkConstraint2Layer *layer = [ChipmunkConstraint2Layer node];
	[scene addChild: layer];
  
	return scene;
}

#pragma mark -
#pragma mark Constraint

-(void)ball {
  [self removeChipmunkObjects];
  
  float lenth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 200:100;
  
  CGSize winSize = [CCDirector sharedDirector].winSize;
  cpVect v1 = cpv(winSize.width/2-0.5*lenth, winSize.height/2);
  cpVect v2 = cpv(winSize.width/2, winSize.height/2);
  cpVect v3 = cpv(winSize.width/2+0.5*lenth, winSize.height/2);
  cpFloat ropeLenth = lenth;
  
  ChipmunkBody *body1 = [self addChipmunkBodyCircleShapeAtPos:cpvadd(v1, cpv(-ropeLenth, ropeLenth))];
  ChipmunkBody *body2 = [self addChipmunkBodyCircleShapeAtPos:v2];
  ChipmunkBody *body3 = [self addChipmunkBodyCircleShapeAtPos:v3];
  
  ChipmunkBody *staticBody = _space.staticBody;
  [_space add:[ChipmunkSlideJoint slideJointWithBodyA:staticBody bodyB:body1 anchr1:cpvadd(v1, cpv(0, ropeLenth)) anchr2:cpvzero min:0 max:ropeLenth]];
  [_space add:[ChipmunkSlideJoint slideJointWithBodyA:staticBody bodyB:body2 anchr1:cpvadd(v2, cpv(0, ropeLenth)) anchr2:cpvzero min:0 max:ropeLenth]];
  [_space add:[ChipmunkSlideJoint slideJointWithBodyA:staticBody bodyB:body3 anchr1:cpvadd(v3, cpv(0, ropeLenth)) anchr2:cpvzero min:0 max:ropeLenth]];
}

-(ChipmunkBody*)addChipmunkBodyCircleShapeAtPos:(cpVect)pos {
  cpFloat mass = 10;
  cpFloat innerRaius = 0;
  cpFloat outerRadis = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 50:25;
  
  cpFloat moment = cpMomentForCircle(mass, innerRaius, outerRadis, cpvzero);
  ChipmunkBody *body = [_space add:[ChipmunkBody bodyWithMass:mass andMoment:moment]];
  body.pos = pos;
  
  ChipmunkShape *shape = [_space add:[ChipmunkCircleShape circleWithBody:body radius:outerRadis offset:cpvzero]];
  shape.elasticity = 1.0;
  shape.friction = 0.0;
  
  return body;
}

-(void)spring {
  [self removeChipmunkObjects];
  
  CGSize winSize = [CCDirector sharedDirector].winSize;
  cpVect v0 = cpv(winSize.width/2, winSize.height/2);
  float length = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 50:25;
  
  cpFloat mass = length*3/5;
  cpFloat outerRadius = length;
  cpFloat moment = cpMomentForCircle(mass, 0, outerRadius, cpvzero);
  
  ChipmunkBody *body = [_space add:[ChipmunkBody bodyWithMass:mass andMoment:moment]];
  body.pos = cpv(winSize.width/2, winSize.height/2-length*2);
  [_space add:[ChipmunkCircleShape circleWithBody:body radius:outerRadius offset:cpvzero]];
  
  ChipmunkBody *staticBody = _space.staticBody;
  [_space addConstraint:[ChipmunkDampedSpring dampedSpringWithBodyA:staticBody bodyB:body anchr1:cpvadd(v0, cpv(0, length*4)) anchr2:cpvzero restLength:length stiffness:4*length damping:0.0]];
}

-(void)circle {
  [self removeChipmunkObjects];
  
  CGSize winSize = [CCDirector sharedDirector].winSize;
  cpVect v0 = cpv(winSize.width/2, winSize.height/2);
  float length = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 50:25;
  
  cpFloat mass = 10;
  cpFloat outerRadius = length;
  cpFloat moment = cpMomentForCircle(mass, 0, outerRadius, cpvzero);
  
  ChipmunkBody *body = [_space add:[ChipmunkBody bodyWithMass:mass andMoment:moment]];
  body.pos = cpvadd(v0, cpv(length*4, 0));
  body.vel = cpv(0, -1000);
  [_space add:[ChipmunkCircleShape circleWithBody:body radius:outerRadius offset:cpvzero]];
  
  ChipmunkBody *staticBody = _space.staticBody;
  
  [_space addConstraint:[ChipmunkPinJoint pinJointWithBodyA:staticBody bodyB:body anchr1:v0 anchr2:cpvzero]];
}

-(void)rope {
  [self removeChipmunkObjects];
  
  CGSize winSize = [CCDirector sharedDirector].winSize;
  float length = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 10:5;
  cpFloat outerRadius = length;
  int amount = 25;
  
  NSMutableArray *bodyMArray = [NSMutableArray array];
  
  for (int i=0; i<amount; i++) {
    cpFloat mass = 1;
    
    cpFloat moment = cpMomentForCircle(mass, 0, outerRadius, cpvzero);
    
    ChipmunkBody *body = [_space add:[ChipmunkBody bodyWithMass:mass andMoment:moment]];
    body.pos = cpv(winSize.width/4 + 2*outerRadius*i, winSize.height/2);
    ChipmunkShape *shape = [_space add:[ChipmunkCircleShape circleWithBody:body radius:outerRadius offset:cpvzero]];
    shape.elasticity = 0; shape.friction = 0;
    
    [bodyMArray addObject:body];
  }
  
  for (int i=0; i<amount-1; i++) {
    ChipmunkBody *bodyA = [bodyMArray objectAtIndex:i];
    ChipmunkBody *bodyB = [bodyMArray objectAtIndex:i+1];
    [_space add:[ChipmunkPinJoint pinJointWithBodyA:bodyA bodyB:bodyB anchr1:cpvzero anchr2:cpvzero]];
  }
  
  ChipmunkBody *firstBody = [bodyMArray objectAtIndex:0];
  [_space add:[ChipmunkPinJoint pinJointWithBodyA:_space.staticBody bodyB:firstBody anchr1:firstBody.pos anchr2:cpvzero]];
  
  ChipmunkBody *lastBody = [bodyMArray objectAtIndex:[bodyMArray count]-1];
  [_space add:[ChipmunkPinJoint pinJointWithBodyA:_space.staticBody bodyB:lastBody anchr1:lastBody.pos anchr2:cpvzero]];
}

-(void)balloon {
  [self removeChipmunkObjects];
  
  CGSize winSize = [CCDirector sharedDirector].winSize;
  
  ballonMArray = [[NSMutableArray alloc]init];
  
  float length = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 50:25;
  
  for (int i=0; i<3; i++) {
    cpVect pos = cpv(winSize.width/2, winSize.height/2);
    cpFloat ropeLenth = 6*length;
    cpFloat mass = 1;
    cpFloat innerRaius = 0;
    cpFloat outerRadis = length;
    
    cpFloat moment = cpMomentForCircle(mass, innerRaius, outerRadis, cpvzero);
    
    ChipmunkBody *body = [_space add:[ChipmunkBody bodyWithMass:mass andMoment:moment]];
    body.pos = pos;
    
    ChipmunkShape *shape = [_space add:[ChipmunkCircleShape circleWithBody:body radius:outerRadis offset:cpvzero]];
    shape.elasticity = 0.0;
    shape.friction = 0.0;
    
    ChipmunkBody *staticBody = _space.staticBody;
    ChipmunkConstraint *constraint = [ChipmunkSlideJoint slideJointWithBodyA:staticBody bodyB:body anchr1:cpvadd(pos, cpv(0, -ropeLenth)) anchr2:cpv(0, -outerRadis) min:0 max:ropeLenth];
    constraint.maxBias = 100;
    [_space add:constraint];
    
    [ballonMArray addObject:body];
  }
  
}

-(void)removeChipmunkObjects {
  for (ChipmunkBody *body in _space.bodies) {
    if ([_space contains:body]) [_space smartRemove:body];
  }
  
  for (ChipmunkShape *shape in _space.shapes) {
    if ([_space contains:shape]) [_space smartRemove:shape];
  }
  
  for (ChipmunkConstraint *cs in _space.constraints) {
    if ([_space contains:cs]) [_space smartRemove:cs];
  }
}

#pragma mark -
#pragma mark Constraint Menu

-(void)setConstraintMenu {
  int fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 20:14;
  
  CCLabelTTF *label1 = [CCLabelTTF labelWithString:@"Ball" fontName:@"Helvetica" fontSize:fontSize];
  CCMenuItemLabel *menuItemLabel1 = [CCMenuItemLabel itemWithLabel:label1 target:self selector:@selector(ball)];
  
  
  CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Spring" fontName:@"Helvetica" fontSize:fontSize];
  CCMenuItemLabel *menuItemLabel2 = [CCMenuItemLabel itemWithLabel:label2 target:self selector:@selector(spring)];
  
  CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"Circle" fontName:@"Helvetica" fontSize:fontSize];
  CCMenuItemLabel *menuItemLabel3 = [CCMenuItemLabel itemWithLabel:label3 target:self selector:@selector(circle)];
  
  CCLabelTTF *label4 = [CCLabelTTF labelWithString:@"Rope" fontName:@"Helvetica" fontSize:fontSize];
  CCMenuItemLabel *menuItemLabel4 = [CCMenuItemLabel itemWithLabel:label4 target:self selector:@selector(rope)];
  
  CCLabelTTF *label5 = [CCLabelTTF labelWithString:@"Balloon" fontName:@"Helvetica" fontSize:fontSize];
  CCMenuItemLabel *menuItemLabel5 = [CCMenuItemLabel itemWithLabel:label5 target:self selector:@selector(balloon)];
  
  CCMenu *menu = [CCMenu menuWithItems:menuItemLabel1,menuItemLabel2,menuItemLabel3,menuItemLabel4,menuItemLabel5, nil];
  [menu alignItemsVertically];
  CGSize winSize = [CCDirector sharedDirector].winSize;
  [menu setPosition:CGPointMake(winSize.width/6, winSize.height/2)];
  [self addChild:menu];
}

#pragma mark -
#pragma mark Update

-(void)update:(ccTime)dt {
  [_space step:dt];
  
  
  for (ChipmunkBody *body in ballonMArray) {
    if ([_space contains:body]) {
      body.force = cpv(0, 1000);
      body.vel = cpv(body.vel.x*0.9, body.vel.y);
      body.angle *= 0.9;
    }
  }
  
}

#pragma mark -
#pragma mark Touch Event

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
  for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
    [_multiGrab beginLocation:point];
  }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
  for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
    [_multiGrab updateLocation:point];
  }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
    [_multiGrab endLocation:point];
  }
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
  [self ccTouchEnded:touch withEvent:event];
}

#pragma mark -
#pragma mark ChipmunkMultiGrab

-(void)setMultiGrab {
  cpFloat grabForce = 1e5;
  cpFloat smoothing = cpfpow(0.3,60);
  
  _multiGrab = [[ChipmunkMultiGrab alloc]initForSpace:_space withSmoothing:smoothing withGrabForce:grabForce];
  _multiGrab.layers = GRABABLE_MASK_BIT;
  _multiGrab.grabFriction = grabForce*0.1;
  _multiGrab.grabRotaryFriction = 1e3;
  _multiGrab.grabRadius = 20.0;
  _multiGrab.pushMass = 1.0;
  _multiGrab.pushFriction = 0.7;
  _multiGrab.pushMode = FALSE;
}

#pragma mark -
#pragma mark CpDebugLayer

-(void)setDebugLayer {
  _debugLayer = [[CPDebugLayer alloc]initWithSpace:_space.space options:nil];
  [self addChild:_debugLayer z:999];
}

#pragma mark -
#pragma mark ChipmunkSpace

-(void)setSpace {
  CGSize winSize = [CCDirector sharedDirector].winSize;
  
  _space = [[ChipmunkSpace alloc]init];
  [_space addBounds:CGRectMake(0, 0, winSize.width, winSize.height) thickness:60.0 elasticity:1.0 friction:0.2 layers:NOT_GRABABLE_MASK group:nil collisionType:nil];
  _space.gravity = cpv(0, -600);
  _space.iterations = 30;
}

/*
 Target:
 Play many kind of Constraint
 
 1. Set ChipmunkSpace, ChipmunkMultiGrab and ChipmunkDebugLayer.
 2. Set a ball.
 3. Set constraint menu
 4. Set constraint function, including ball, spring, circle, rope, ballon, etc..
 */

#pragma mark -
#pragma mark Init

-(id) init {
	if((self = [super init])) {
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.1],[CCCallBlock actionWithBlock:^(id sender){
      self.isTouchEnabled = YES;
    }], nil]];
    
    [self setConstraintMenu];
    
    [self setSpace];
    
    [self ball];
    
    [self setMultiGrab];
    
    [self setDebugLayer];
    
    [self schedule:@selector(update:)];
	}
	return self;
}

- (void) dealloc {
  if (ballonMArray != nil) [ballonMArray release], ballonMArray = nil;
  
  [_space release];
  [_multiGrab release];
  [_debugLayer release];
  
	[super dealloc];
}

@end
