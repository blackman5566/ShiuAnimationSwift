//
//  BrowseAnimation.swift
//  ShiuAnimationSwift
//
//  Created by AllenShiu on 2017/2/10.
//  Copyright © 2017年 AllenShiu. All rights reserved.
//

import UIKit

enum StyleType {
    case StyleTypeFadeIn
    case StyleTypeDismissNone
}

class BrowseAnimation: NSObject,UIViewControllerAnimatedTransitioning {
    var styleType:StyleType
    let ScreenWidth = UIScreen.main.bounds.size.width
    let ScreenHeight = UIScreen.main.bounds.size.height
    
    // MARK: override
    
    override init() {
       self.styleType = .StyleTypeFadeIn
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return 0.3;
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        
        switch self.styleType {
        case .StyleTypeFadeIn:
            toViewController?.view.frame = frame;
            let container = transitionContext.containerView
            container.insertSubview((toViewController?.view)!, belowSubview: (fromViewController?.view)!)
            
            toViewController?.view.alpha = 0;
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations:{
                toViewController?.view.alpha = 1;
            }, completion: { (finished: Bool) in
                toViewController?.view.alpha = 1;
                transitionContext.completeTransition(true)
            })
            break
        case .StyleTypeDismissNone:
            fromViewController?.view.frame = CGRect.zero;
            transitionContext.completeTransition(true)
            break
        }
    }
}
