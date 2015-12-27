//
//  CEZoomAnimationController.m
//  TransitionsDemo
//
//  Created by Colin Eberhardt on 22/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "CECardsAnimationController.h"

@implementation CECardsAnimationController



- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
  
  if(self.reverse){
    [self executeReverseAnimation:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
  } else {
    [self executeForwardsAnimation:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
  }
  
}
- (void)doAnim:(UIView*)fromV toV:(UIView*)toV duration:(NSTimeInterval)duration target:(id)target onComplete:(SEL)onComplete{
  if(self.reverse){
    [self doAnimBackward:fromV.superview fromV:fromV toV:toV duration:duration target:target onComplete:onComplete];
  } else {
    [self doAnimForward:fromV.superview fromV:fromV toV:toV duration:duration target:target onComplete:onComplete];
  }
}
#define ZOOM_SCALE 0.8
- (void)executeForwardsAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
  
  UIView *containerView = [transitionContext containerView];
  [self doAnimForward:containerView fromV:fromView toV:toView duration:[self transitionDuration:transitionContext] target:self onComplete:@selector(doOnComplete:)];
}
- (void)doAnimForward:(UIView*)containerView fromV:(UIView*)fromV toV:(UIView*)toV duration:(NSTimeInterval)duration target:(id)target onComplete:(SEL)onComplete{
  
  
  // positions the to- view off the bottom of the sceen
  CGRect frame = fromV.frame;
  CGRect offScreenFrame = frame;
  offScreenFrame.origin.y = offScreenFrame.size.height;
  toV.frame = offScreenFrame;
  
  [containerView insertSubview:toV aboveSubview:fromV];
  
  CATransform3D t1 = [self firstTransform];
  CATransform3D t2 = [self secondTransformWithView:fromV];

  UIColor *bgColor = containerView.backgroundColor;
  containerView.backgroundColor = [UIColor blackColor];
  [UIView animateKeyframesWithDuration:self.duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
    
    // push the from- view to the back
    [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.4f animations:^{
      fromV.layer.transform = t1;
      fromV.alpha = 0.6;
    }];
    [UIView addKeyframeWithRelativeStartTime:0.2f relativeDuration:0.4f animations:^{
      fromV.layer.transform = t2;
    }];
    
    // slide the to- view upwards. In his original implementation Tope used a 'spring' animation, however
    // this does not work with keyframes, so we siulate it by overshooting the final location in
    // the first keyframe
    [UIView addKeyframeWithRelativeStartTime:0.6f relativeDuration:0.2f animations:^{
      toV.frame = CGRectOffset(toV.frame, 0.0, -30.0);
    }];
    [UIView addKeyframeWithRelativeStartTime:0.8f relativeDuration:0.2f animations:^{
      toV.frame = frame;
    }];
    
  } completion:^(BOOL finished) {
    containerView.backgroundColor = bgColor;
    BOOL b = ((self.transitionContext == nil && !finished) ||
              (self.transitionContext != nil && [self.transitionContext transitionWasCancelled]));
    if ([target respondsToSelector:onComplete]) {
      ((void (*)(id, SEL, BOOL))[target methodForSelector:onComplete])
      (target, onComplete, b);
    }
  }];
  
  
}

- (void)executeReverseAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
  
  UIView *containerView = [transitionContext containerView];
  // Add the from-view to the container
  [containerView addSubview:fromView];
  
  // add the to- view and send offscreen (we need to do this in order to allow snapshotting)
  [containerView addSubview:toView];
  [self doAnimBackward:containerView fromV:fromView toV:toView duration:[self transitionDuration:transitionContext] target:self onComplete:@selector(doOnComplete:)];
  
}
- (void)doAnimBackward:(UIView*)containerView fromV:(UIView*)fromV toV:(UIView*)toV duration:(NSTimeInterval)duration target:(id)target onComplete:(SEL)onComplete{
  
  // positions the to- view behind the from- view
  CGRect frame = fromV.frame;
  toV.frame = frame;
  CATransform3D scale = CATransform3DIdentity;
  toV.layer.transform = CATransform3DScale(scale, 0.6, 0.6, 1);
  toV.alpha = 0.6;
  
  [containerView insertSubview:toV belowSubview:fromV];
  
  CGRect frameOffScreen = frame;
  frameOffScreen.origin.y = frame.size.height;
  
  CATransform3D t1 = [self firstTransform];
  
  UIColor *bgColor = containerView.backgroundColor;
  containerView.backgroundColor = [UIColor blackColor];
  [UIView animateKeyframesWithDuration:self.duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
    
    // push the from- view off the bottom of the screen
    [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.5f animations:^{
      fromV.frame = frameOffScreen;
    }];
    
    // animate the to- view into place
    [UIView addKeyframeWithRelativeStartTime:0.35f relativeDuration:0.35f animations:^{
      toV.layer.transform = t1;
      toV.alpha = 1.0;
    }];
    [UIView addKeyframeWithRelativeStartTime:0.75f relativeDuration:0.25f animations:^{
      toV.layer.transform = CATransform3DIdentity;
    }];
  } completion:^(BOOL finished) {
    containerView.backgroundColor = bgColor;
    BOOL b = ((self.transitionContext == nil && !finished) ||
            (self.transitionContext != nil && [self.transitionContext transitionWasCancelled]));
    if (b) {
      toV.layer.transform = CATransform3DIdentity;
      toV.alpha = 1.0;
    }
    if ([target respondsToSelector:onComplete]) {
      ((void (*)(id, SEL, BOOL))[target methodForSelector:onComplete])
      (target, onComplete, b);
    }
  }];
}
// animation finished
-(void)doOnComplete:(BOOL)isDone{
  //inform the context of completion
  [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
}


-(CATransform3D)firstTransform{
  CATransform3D t1 = CATransform3DIdentity;
  t1.m34 = 1.0/-900;
  t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
  t1 = CATransform3DRotate(t1, 15.0f * M_PI/180.0f, 1, 0, 0);
  return t1;
  
}

-(CATransform3D)secondTransformWithView:(UIView*)view{
  
  CATransform3D t2 = CATransform3DIdentity;
  t2.m34 = [self firstTransform].m34;
  t2 = CATransform3DTranslate(t2, 0, view.frame.size.height*-0.08, 0);
  t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
  
  return t2;
}

@end
