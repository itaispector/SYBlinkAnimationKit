//
//  SYLayer.swift
//  SYBlinkAnimationKit
//
//  Created by Shohei Yokoyama on 12/13/2015.
//  Copyright © 2015年 Shohei. All rights reserved.
//

import UIKit

public enum SYLayerAnimation {
    case Border
    case BorderWithShadow
    case Background
    case Text
    case Ripple
}

public enum SYMediaTimingFunction {
    case Linear
    case EaseIn
    case EaseOut
    case EaseInEaseOut
    
    public var timingFunction : CAMediaTimingFunction {
        switch self {
        case .Linear:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        case .EaseIn:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        case .EaseOut:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        case .EaseInEaseOut:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        }
    }
}

public class SYLayer {
    
    private var superLayer: CALayer!
    private var textLayer = CATextLayer()
    private var rippleLayer = CALayer()
    private var subRippleLayer = CALayer()
    
    private var borderColorAnimtion = CABasicAnimation()
    private var borderWidthAnimation = CABasicAnimation()
    private var shadowAnimation = CABasicAnimation()
    private var backgroundColorAnimation = CABasicAnimation()
    private var textColorAnimation = CABasicAnimation()
    
    public var animationBorderColor = UIColor(red: 210/255.0, green: 77/255.0, blue: 87/255.0, alpha: 1) {
        didSet {
            self.borderColorAnimtion.toValue = self.animationBorderColor.CGColor
            self.animationShadowColor = self.animationBorderColor
        }
    }
    public var animationTextColor = UIColor(red: 189/255.0, green: 195/255.0, blue: 199/255.0, alpha: 1) {
        didSet {
            self.textColorAnimation.toValue = self.animationTextColor.CGColor
        }
    }
    public var animationBackgroundColor = UIColor(red: 89/255.0, green: 171/255.0, blue: 227/255.0, alpha: 1) {
        didSet {
            self.backgroundColorAnimation.toValue = self.animationBackgroundColor.CGColor
        }
    }
    public var animationShadowColor = UIColor(red: 210/255.0, green: 77/255.0, blue: 87/255.0, alpha: 1) {
        didSet {
            self.superLayer.shadowColor = self.animationShadowColor.CGColor
        }
    }
    public var animationRippleColor = UIColor(red: 65/255.0, green: 131/255.0, blue: 215/255.0, alpha: 1) {
        didSet {
            self.rippleLayer.backgroundColor = self.animationRippleColor.CGColor
            self.subRippleLayer.borderColor = self.animationRippleColor.CGColor
        }
    }
    
    private var animationDuration: CFTimeInterval = 1.5
    private var animationTimingFunction: SYMediaTimingFunction = .Linear
    
    public var textColor = UIColor.blackColor()
    public var backgroundColor = UIColor.whiteColor() {
        didSet {
            self.superLayer.backgroundColor = self.backgroundColor.CGColor
        }
    }
    
    public var borderWidth: CGFloat = 0.0 {
        didSet {
            self.superLayer.borderWidth = self.borderWidth
        }
    }
    public var borderColor = UIColor.clearColor() {
        didSet {
            self.superLayer.borderColor = self.borderColor.CGColor
        }
    }
    
    public var shadowRadius: CGFloat = 0.0 {
        didSet {
            self.superLayer.shadowRadius = self.shadowRadius
        }
    }
    public var shadowOpacity: Float = 0.0 {
        didSet {
            self.superLayer.shadowOpacity = self.shadowOpacity
        }
    }
    public var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {
        didSet {
            self.superLayer.shadowOffset = self.shadowOffset
        }
    }
    
    public init(superLayer: CALayer) {
        self.superLayer = superLayer
        
        self.setLayer()
    }
    
    private func setLayer() {
        self.superLayer.shadowColor = self.animationShadowColor.CGColor
        self.superLayer.borderColor = self.borderColor.CGColor
        
        self.superLayer.borderWidth = self.borderWidth
        
        self.clearSuperLayerShadow()
        self.setRippleLayer()
    }
    
    private func setRippleLayer() {
        let superLayerHeight = CGRectGetHeight(self.superLayer.frame)
        
        let rippleDiameter: CGFloat = superLayerHeight * 0.75
        let rippleCornerRadius: CGFloat = rippleDiameter / 2
        
        self.rippleLayer.backgroundColor = self.animationRippleColor.CGColor
        self.rippleLayer.opacity = 0.0
        self.rippleLayer.cornerRadius = rippleCornerRadius
        self.rippleLayer.frame = CGRect(x: (self.superLayer.bounds.width - rippleDiameter) / 2, y: (self.superLayer.bounds.height - rippleDiameter) / 2, width: rippleDiameter, height: rippleDiameter)
        self.superLayer.addSublayer(self.rippleLayer)
        
        let subRippleDiameter: CGFloat = superLayerHeight * 0.85
        let subRippleCornerRadius: CGFloat = subRippleDiameter / 2
        
        self.subRippleLayer.borderColor = self.animationRippleColor.CGColor
        self.subRippleLayer.opacity = 0.0
        self.subRippleLayer.borderWidth = 1
        self.subRippleLayer.backgroundColor = UIColor.clearColor().CGColor
        self.subRippleLayer.cornerRadius = subRippleCornerRadius
        self.subRippleLayer.frame = CGRect(x: (self.superLayer.bounds.width - subRippleDiameter) / 2, y: (self.superLayer.bounds.height - subRippleDiameter) / 2, width: subRippleDiameter, height: subRippleDiameter)
//        self.superLayer.addSublayer(self.subRippleLayer)
        self.superLayer.insertSublayer(self.subRippleLayer, atIndex: 1)
        
    }
    
    private func setShadowForBorderWithShadowAnimation() {
        let borderWidth: CGFloat = 5
        let widthHalf: CGFloat = borderWidth / 2
        
        let pathRef: CGMutablePathRef = CGPathCreateMutable()
        CGPathMoveToPoint(pathRef, nil, -widthHalf, -widthHalf)
        CGPathAddLineToPoint(pathRef, nil, self.superLayer.frame.width + widthHalf, -widthHalf)
        CGPathAddLineToPoint(pathRef, nil, self.superLayer.frame.width + widthHalf, widthHalf)
        CGPathAddLineToPoint(pathRef, nil, widthHalf, widthHalf)
        CGPathAddLineToPoint(pathRef, nil, widthHalf, self.superLayer.frame.height - widthHalf)
        CGPathAddLineToPoint(pathRef, nil, self.superLayer.frame.width - widthHalf, self.superLayer.frame.height - widthHalf)
        CGPathAddLineToPoint(pathRef, nil, self.superLayer.frame.width - widthHalf, widthHalf)
        CGPathAddLineToPoint(pathRef, nil, self.superLayer.frame.width + widthHalf, widthHalf)
        CGPathAddLineToPoint(pathRef, nil, self.superLayer.frame.width + widthHalf, self.superLayer.frame.height + widthHalf)
        CGPathAddLineToPoint(pathRef, nil, -widthHalf, self.superLayer.frame.height + widthHalf)
        CGPathAddLineToPoint(pathRef, nil, -widthHalf, -widthHalf)
        CGPathCloseSubpath(pathRef)
        
        self.superLayer.shadowPath = pathRef
    }
    
    public func setAnimationTimingFunction(timingFunction: SYMediaTimingFunction) {
        self.animationTimingFunction = timingFunction
    }
    
    public func setAnimationDuration(animationDuration: CFTimeInterval) {
        self.animationDuration = animationDuration
    }
    
    private func getBackgroundColorExceptClearColor() -> UIColor {
        if !CGColorEqualToColor(UIColor.clearColor().CGColor, self.backgroundColor.CGColor) {
          return self.backgroundColor
        }
        
        self.setShadowForBorderWithShadowAnimation()
        return self.backgroundColor
    }
    
    public func resizeSuperLayer() {
        self.resizeRippleLayer()
        self.resizeTextLayer()
    }
    
    private func resizeRippleLayer() {
        let superLayerHeight = CGRectGetHeight(self.superLayer.frame)
        
        let rippleDiameter: CGFloat = superLayerHeight * 0.75
        let rippleCornerRadius: CGFloat = rippleDiameter / 2
        
        self.rippleLayer.frame = CGRect(x: (self.superLayer.bounds.width - rippleDiameter) / 2, y: (self.superLayer.bounds.height - rippleDiameter) / 2, width: rippleDiameter, height: rippleDiameter)
        self.rippleLayer.cornerRadius = rippleCornerRadius
        
        let subRippleDiameter: CGFloat = superLayerHeight * 0.9
        let subRippleCornerRadius: CGFloat = subRippleDiameter / 2
        
        self.subRippleLayer.cornerRadius = subRippleCornerRadius
        self.subRippleLayer.frame = CGRect(x: (self.superLayer.bounds.width - subRippleDiameter) / 2, y: (self.superLayer.bounds.height - subRippleDiameter) / 2, width: subRippleDiameter, height: subRippleDiameter)
    }
    
    private func resizeTextLayer() {
        let superLayerHeight = CGRectGetHeight(self.superLayer.frame)
        let superLayerWidth = CGRectGetWidth(self.superLayer.frame)
        
        self.textLayer.frame.origin.x = (superLayerWidth - self.textLayer.frame.width) / 2
        self.textLayer.frame.origin.y = (superLayerHeight - self.textLayer.frame.height) / 2
    }
    
    public func firstSetTextLayer(textLayer: CATextLayer) {
        self.textLayer = textLayer
        self.superLayer.insertSublayer(self.textLayer, atIndex: 0)
    }
    
    public func resetTextLayer(textLayer: CATextLayer) {
        self.textLayer = textLayer
    }
    
    private func clearSuperLayerShadow() {
        self.superLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.superLayer.shadowRadius = 0.0
        self.superLayer.shadowOpacity = 0.0
    }
    
    public var syLayerAnimation: SYLayerAnimation = .Border {
        didSet {
            switch syLayerAnimation {
            case .Border:
                self.setBorderAnimation()
            case .BorderWithShadow:
                self.setBorderWithShadowAnimation()
            default:
                return
            }
        }
    }
    
    private func setBorderAnimation() {
        self.setBorderColorAnimation()
        self.setBorderWidthAnimation(0.0, toValue: 1.0)
    }
    
    private func setBorderWithShadowAnimation() {
        self.setBorderColorAnimation()
        self.setShadowAnimation(0.0, toValue: 0.5)
        self.setBorderWidthAnimation(0.0, toValue: 0.6)
    }
    
    private func setBorderColorAnimation() {
        borderColorAnimtion = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimtion.fromValue = UIColor.clearColor().CGColor
        borderColorAnimtion.toValue = self.animationBorderColor.CGColor
    }
    
    private func setBorderWidthAnimation(fromValue: CGFloat, toValue: CGFloat) {
        borderWidthAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidthAnimation.fromValue = fromValue
        borderWidthAnimation.toValue = toValue
    }
    
    private func setShadowAnimation(fromValue: Float, toValue: Float) {
        shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowAnimation.fromValue = fromValue
        shadowAnimation.toValue = toValue
        self.superLayer.shadowOpacity = toValue //ここら辺かな
    }
    
    public func startAnimation() {
        switch syLayerAnimation {
            
        case .Border:
            self.animateBorderOrBorderWithShadow()
        case .BorderWithShadow:
            self.animateBorderOrBorderWithShadow()
        case .Background:
            self.animateBackground()
        case .Text:
            self.animateText()
        case .Ripple:
            self.animateRipple()
        }
    }
    
    public func stopAnimation() {
        self.superLayer.removeAllAnimations()
        self.textLayer.removeAllAnimations()
        self.subRippleLayer.removeAllAnimations()
        self.rippleLayer.removeAllAnimations()
        
        self.clearSuperLayerShadow()
        self.superLayer.backgroundColor = self.backgroundColor.CGColor
        self.textLayer.foregroundColor = self.textColor.CGColor
    }
    
    public func animateBorderOrBorderWithShadow() {
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = self.animationDuration
        groupAnimation.animations = [borderColorAnimtion, borderWidthAnimation]
        groupAnimation.timingFunction = self.animationTimingFunction.timingFunction
        groupAnimation.delegate = self
        groupAnimation.autoreverses = true
        groupAnimation.repeatCount = 1e100
        syLayerAnimation == .BorderWithShadow ? self.animateBorderWithShadow(groupAnimation) : self.superLayer.addAnimation(groupAnimation, forKey: "Border")
    }
    
    private func animateBorderWithShadow(groupAnimation: CAAnimationGroup) {
        self.superLayer.masksToBounds = false
//        self.superLayer.backgroundColor = self.backgroundColor.CGColor//clearの場合
        self.superLayer.backgroundColor = self.getBackgroundColorExceptClearColor().CGColor
        self.superLayer.shadowRadius = 5.0
        groupAnimation.animations?.append(self.shadowAnimation)
        self.superLayer.addAnimation(groupAnimation, forKey: "BorderWithShadow")
    }
    
    private func animateBackground() {
        self.backgroundColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        self.backgroundColorAnimation.fromValue = UIColor.clearColor().CGColor
        self.backgroundColorAnimation.toValue = self.animationBackgroundColor.CGColor
        self.superLayer.backgroundColor = self.animationBackgroundColor.CGColor
        self.backgroundColorAnimation.duration = self.animationDuration
        self.backgroundColorAnimation.autoreverses = true
        self.backgroundColorAnimation.repeatCount = 1e100
        self.backgroundColorAnimation.timingFunction = self.animationTimingFunction.timingFunction
        self.superLayer.addAnimation(backgroundColorAnimation, forKey: "Background")
    }
    
    private func animateText() {
        self.textColorAnimation = CABasicAnimation(keyPath: "foregroundColor")
        self.textColorAnimation.duration = self.animationDuration
        self.textColorAnimation.autoreverses = true
        self.textColorAnimation.repeatCount = 1e100
        self.textColorAnimation.timingFunction = self.animationTimingFunction.timingFunction
        self.textColorAnimation.fromValue = self.animationTextColor.colorWithAlphaComponent(0.15).CGColor
        self.textColorAnimation.toValue = self.animationTextColor.CGColor
        self.textLayer.foregroundColor = self.animationTextColor.CGColor
        self.textLayer.addAnimation(textColorAnimation, forKey: "TextColor")
    }
    
    private func animateRipple() {
        let fadeOutOpacity = CABasicAnimation(keyPath: "opacity")
        fadeOutOpacity.fromValue = 1.0
        fadeOutOpacity.toValue = 0.0
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.4
        scale.toValue = 1.0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = self.animationDuration
        animationGroup.repeatCount = 1e100
        animationGroup.timingFunction = animationTimingFunction.timingFunction
        animationGroup.animations = [fadeOutOpacity, scale]
        
        self.rippleLayer.addAnimation(animationGroup, forKey: nil)
        self.subRippleLayer.addAnimation(animationGroup, forKey: nil)
    }
}
