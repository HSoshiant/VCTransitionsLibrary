//
//  CubeNavigationAnimator.m
//  MovieQuiz
//
//  Created by Andrés Brun on 27/10/13.
//  Copyright (c) 2013 Andrés Brun. All rights reserved.
//

#import "CECubeAnimationController.h"

#define PERSPECTIVE -1.0 / 200.0
#define ROTATION_ANGLE M_PI_2

@implementation CECubeAnimationController

- (id)init
{
  self = [super init];
  if (self) {
    self.cubeAnimationWay = CubeAnimationWayHorizontal;
  }
  return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView
{
  //We create a content view for do the translate animation
  UIView *generalContentView = [transitionContext containerView];
  //Add the to- view
  [generalContentView addSubview:toView];
  
  [self doAnim:fromView toV:toView duration:[self transitionDuration:transitionContext] target:self onComplete:@selector(doOnComplete:)];
}
// removes all the views other than the given view from the superview
- (void)doAnim:(UIView*)fromV toV:(UIView*)toV duration:(NSTimeInterval)duration target:(id)target onComplete:(SEL)onComplete{
  //Calculate the direction
  int dir = self.reverse ? 1 : -1;
  
  //Create the differents 3D animations
  CATransform3D viewFromTransform;
  CATransform3D viewToTransform;
  
  //We create a content view for do the translate animation
  UIView *generalContentView = [fromV superview];
  
  switch (self.cubeAnimationWay) {
    case CubeAnimationWayHorizontal:
      viewFromTransform = CATransform3DMakeRotation(dir*ROTATION_ANGLE, 0.0, 1.0, 0.0);
      viewToTransform = CATransform3DMakeRotation(-dir*ROTATION_ANGLE, 0.0, 1.0, 0.0);
      [toV.layer setAnchorPoint:CGPointMake(dir==1?0:1, 0.5)];
      [fromV.layer setAnchorPoint:CGPointMake(dir==1?1:0, 0.5)];
      
      [generalContentView setTransform:CGAffineTransformMakeTranslation(dir*(generalContentView.frame.size.width)/2.0, 0)];
      break;
      
    case CubeAnimationWayVertical:
      viewFromTransform = CATransform3DMakeRotation(-dir*ROTATION_ANGLE, 1.0, 0.0, 0.0);
      viewToTransform = CATransform3DMakeRotation(dir*ROTATION_ANGLE, 1.0, 0.0, 0.0);
      [toV.layer setAnchorPoint:CGPointMake(0.5, dir==1?0:1)];
      [fromV.layer setAnchorPoint:CGPointMake(0.5, dir==1?1:0)];
      
      [generalContentView setTransform:CGAffineTransformMakeTranslation(0, dir*(generalContentView.frame.size.height)/2.0)];
      break;
      
    default:
      break;
  }
  
  viewFromTransform.m34 = PERSPECTIVE;
  viewToTransform.m34 = PERSPECTIVE;
  
  toV.layer.transform = viewToTransform;
  
  //Create the shadow
  UIView *fromShadow = [self addOpacityToView:fromV withColor:[UIColor blackColor]];
  UIView *toShadow = [self addOpacityToView:toV withColor:[UIColor blackColor]];
  [fromShadow setAlpha:0.0];
  [toShadow setAlpha:1.0];
  
  UIColor *bgColor = generalContentView.backgroundColor;
  generalContentView.backgroundColor = [UIColor blackColor];
  [UIView animateWithDuration:duration animations:^{
    switch (self.cubeAnimationWay) {
      case CubeAnimationWayHorizontal:
        [generalContentView setTransform:CGAffineTransformMakeTranslation(-dir*generalContentView.frame.size.width/2.0, 0)];
        break;
        
      case CubeAnimationWayVertical:
        [generalContentView setTransform:CGAffineTransformMakeTranslation(0, -dir*(generalContentView.frame.size.height)/2.0)];
        break;
        
      default:
        break;
    }
    
    fromV.layer.transform = viewFromTransform;
    toV.layer.transform = CATransform3DIdentity;
    
    [fromShadow setAlpha:1.0];
    [toShadow setAlpha:0.0];
    
  } completion:^(BOOL finished) {
    
    //Set the final position of every elements transformed
    [generalContentView setTransform:CGAffineTransformIdentity];
    fromV.layer.transform = CATransform3DIdentity;
    toV.layer.transform = CATransform3DIdentity;
    [fromV.layer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    [toV.layer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    
    [fromShadow removeFromSuperview];
    [toShadow removeFromSuperview];
    
    // remove all the temporary views
    if ((self.transitionContext == nil && !finished) ||
        (self.transitionContext != nil && [self.transitionContext transitionWasCancelled])) {
      [toV removeFromSuperview];
    } else {
      [fromV removeFromSuperview];
    }
    
    generalContentView.backgroundColor = bgColor;
    
    if ([target respondsToSelector:onComplete]) {
      ((void (*)(id, SEL, BOOL))[target methodForSelector:onComplete])
      (target, onComplete, finished);
    }
    
  }];
}
// animation finished
-(void)doOnComplete:(BOOL)isDone{
  //inform the context of completion
  [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
}

- (UIView *)addOpacityToView:(UIView *) view withColor:(UIColor *)theColor
{
  UIView *shadowView = [[UIView alloc] initWithFrame:view.bounds];
  [shadowView setBackgroundColor:[theColor colorWithAlphaComponent:0.8]];
  [view addSubview:shadowView];
  return shadowView;
}

@end
