//
//  ZENPortalAnimationController.m
//  ZEN BabyBook
//
//  Created by Frédéric ADDA on 07/12/2013.
//  Copyright (c) 2013 Frédéric ADDA. All rights reserved.
//

#import "CEPortalAnimationController.h"

@implementation CEPortalAnimationController

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
  // Add a reduced snapshot of the toView to the container
  UIView *toViewSnapshot = [toV resizableSnapshotViewFromRect:toV.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
  CATransform3D scale = CATransform3DIdentity;
  toViewSnapshot.layer.transform = CATransform3DScale(scale, ZOOM_SCALE, ZOOM_SCALE, 1);
  [containerView addSubview:toViewSnapshot];
  [containerView sendSubviewToBack:toViewSnapshot];
  
  // Create two-part snapshots of the from- view
  
  // snapshot the left-hand side of the from- view
  CGRect leftSnapshotRegion = CGRectMake(0, 0, fromV.frame.size.width / 2, fromV.frame.size.height);
  UIView *leftHandView = [fromV resizableSnapshotViewFromRect:leftSnapshotRegion  afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
  leftHandView.frame = leftSnapshotRegion;
  [containerView addSubview:leftHandView];
  
  // snapshot the right-hand side of the from- view
  CGRect rightSnapshotRegion = CGRectMake(fromV.frame.size.width / 2, 0, fromV.frame.size.width / 2, fromV.frame.size.height);
  UIView *rightHandView = [fromV resizableSnapshotViewFromRect:rightSnapshotRegion  afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
  rightHandView.frame = rightSnapshotRegion;
  [containerView addSubview:rightHandView];
  
  // remove the view that was snapshotted
  [fromV removeFromSuperview];
  
  // animate
  
  [UIView animateWithDuration:duration
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     // Open the portal doors of the from-view
                     leftHandView.frame = CGRectOffset(leftHandView.frame, - leftHandView.frame.size.width, 0);
                     rightHandView.frame = CGRectOffset(rightHandView.frame, rightHandView.frame.size.width, 0);
                     
                     // zoom in the to-view
                     toViewSnapshot.center = toV.center;
                     toViewSnapshot.frame = toV.frame;
                     
                   } completion:^(BOOL finished) {
                     
                     // remove all the temporary views
                     if ((self.transitionContext == nil && !finished) ||
                         (self.transitionContext != nil && [self.transitionContext transitionWasCancelled])) {
                       [containerView addSubview:fromV];
                       [self removeOtherViews:fromV];
                     } else {
                       [containerView addSubview:toV];
                       [self removeOtherViews:toV];
                     }
                     
                     if ([target respondsToSelector:onComplete]) {
                       ((void (*)(id, SEL, BOOL))[target methodForSelector:onComplete])
                       (target, onComplete, finished);
                     }
                   }];
  
}



- (void)executeReverseAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
  UIView *containerView = [transitionContext containerView];
  // Add the from-view to the container
  [containerView addSubview:fromView];

  // add the to- view and send offscreen (we need to do this in order to allow snapshotting)
  toView.frame = CGRectOffset(toView.frame, toView.frame.size.width, 0);
  [containerView addSubview:toView];
  [self doAnimBackward:containerView fromV:fromView toV:toView duration:[self transitionDuration:transitionContext] target:self onComplete:@selector(doOnComplete:)];

}
- (void)doAnimBackward:(UIView*)containerView fromV:(UIView*)fromV toV:(UIView*)toV duration:(NSTimeInterval)duration target:(id)target onComplete:(SEL)onComplete{
    // Create two-part snapshots of the to- view
    
    // snapshot the left-hand side of the to- view
    CGRect leftSnapshotRegion = CGRectMake(0, 0, toV.frame.size.width / 2, toV.frame.size.height);
    UIView *leftHandView = [toV resizableSnapshotViewFromRect:leftSnapshotRegion  afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    leftHandView.frame = leftSnapshotRegion;
    // reverse animation : start from beyond the edges of the screen
    leftHandView.frame = CGRectOffset(leftHandView.frame, - leftHandView.frame.size.width, 0);
    [containerView addSubview:leftHandView];
    
    // snapshot the right-hand side of the to- view
    CGRect rightSnapshotRegion = CGRectMake(toV.frame.size.width / 2, 0, toV.frame.size.width / 2, toV.frame.size.height);
    UIView *rightHandView = [toV resizableSnapshotViewFromRect:rightSnapshotRegion  afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    rightHandView.frame = rightSnapshotRegion;
    // reverse animation : start from beyond the edges of the screen
    rightHandView.frame = CGRectOffset(rightHandView.frame, rightHandView.frame.size.width, 0);
    [containerView addSubview:rightHandView];
    
    // animate
  
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         // Close the portal doors of the to-view
                         leftHandView.frame = CGRectOffset(leftHandView.frame, leftHandView.frame.size.width, 0);
                         rightHandView.frame = CGRectOffset(rightHandView.frame, - rightHandView.frame.size.width, 0);
                         
                         // Zoom out the from-view
                         CATransform3D scale = CATransform3DIdentity;
                         fromV.layer.transform = CATransform3DScale(scale, ZOOM_SCALE, ZOOM_SCALE, 1);

                         
                     } completion:^(BOOL finished) {
                         
                         // remove all the temporary views
                       if ((self.transitionContext == nil && !finished) ||
                           (self.transitionContext != nil && [self.transitionContext transitionWasCancelled])) {
                         [self removeOtherViews:fromV];
                       } else {
                         [self removeOtherViews:toV];
                         toV.frame = containerView.bounds;
                       }
                       
                       // inform the context of completion
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

// removes all the views other than the given view from the superview
- (void)removeOtherViews:(UIView*)viewToKeep {
    UIView *containerView = viewToKeep.superview;
    for (UIView *view in containerView.subviews) {
        if (view != viewToKeep) {
            [view removeFromSuperview];
        }
    }
}

@end
