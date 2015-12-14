//
//  ZENPortalAnimationController.h
//  ZEN BabyBook
//
//  Created by Frédéric ADDA on 07/12/2013.
//  Copyright (c) 2013 Frédéric ADDA. All rights reserved.
//

#import "CEReversibleAnimationController.h"

/*
 Animates between the two view controllers using a portal-opening transition.
 */

@interface CEPortalAnimationController : CEReversibleAnimationController
- (void)doAnimForward:(UIView*)containerView fromV:(UIView*)fromV toV:(UIView*)toV duration:(NSTimeInterval)duration target:(id)target onComplete:(SEL)onComplete;
- (void)doAnimBackward:(UIView*)containerView fromV:(UIView*)fromV toV:(UIView*)toV duration:(NSTimeInterval)duration target:(id)target onComplete:(SEL)onComplete;
@end
