//
//  CEFlipAnimationController.m
//  ViewControllerTransitions
//
//  Created by Colin Eberhardt on 08/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "CETurnAnimationController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CETurnAnimationController

- (id)init {
  if (self = [super init]) {
    self.flipDirection = CEDirectionVertical;
  }
  return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
  
  // Add the toView to the container
  UIView* containerView = [transitionContext containerView];
  [containerView addSubview:toView];
  [self doAnim:fromView toV:toView duration:[self transitionDuration:transitionContext] target:self onComplete:@selector(doOnComplete:)];
}
// removes all the views other than the given view from the superview
- (void)doAnim:(UIView*)fromV toV:(UIView*)toV duration:(NSTimeInterval)duration target:(id)target onComplete:(SEL)onComplete{
  UIView* containerView = fromV.superview;
  
  // Add a perspective transform
  CATransform3D transform = CATransform3DIdentity;
  transform.m34 = -0.002;
  [containerView.layer setSublayerTransform:transform];
  
  // Give both VCs the same start frame
  CGRect initialFrame = fromV.frame;
  fromV.frame = initialFrame;
  toV.frame = initialFrame;
  
  // reverse?
  float factor = self.reverse ? 1.0 : -1.0;
  
  // flip the to VC halfway round - hiding it
  toV.layer.transform = [self rotate:factor * -M_PI_2];
  UIColor *bgColor = containerView.backgroundColor;
  containerView.backgroundColor = [UIColor blackColor];
  // animate
  [UIView animateKeyframesWithDuration:duration
                                 delay:0.0
                               options:0
                            animations:^{
                              [UIView addKeyframeWithRelativeStartTime:0.0
                                                      relativeDuration:0.5
                                                            animations:^{
                                                              // rotate the from view
                                                              fromV.layer.transform = [self rotate:factor * M_PI_2];
                                                            }];
                              [UIView addKeyframeWithRelativeStartTime:0.5
                                                      relativeDuration:0.5
                                                            animations:^{
                                                              // rotate the to view
                                                              toV.layer.transform =  [self rotate:0.0];
                                                            }];
                            } completion:^(BOOL finished) {
                              containerView.backgroundColor = bgColor;
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

- (CATransform3D) rotate:(CGFloat) angle {
  if (self.flipDirection == CEDirectionHorizontal)
    return  CATransform3DMakeRotation(angle, 1.0, 0.0, 0.0);
  else
    return  CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0);
}

@end
