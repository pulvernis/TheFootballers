//
//  ShowAlert.swift
//  TheFootballers
//
//  Created by Ran Pulvernis on 27/01/2017.
//  Copyright © 2017 RanPulvernis. All rights reserved.
//

import UIKit

class ShowAlert {

public func showAlert(backgroundColor:UIColor, textColor:UIColor, message:String)
{
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let label = UILabel(frame: CGRectZero)
    label.textAlignment = NSTextAlignment.Center
    label.text = message
    label.font = UIFont(name: NEWFONT_NAVIGATIONBAR, size: NEWFONT_NAVIGATIONBAR_SIZE)
    label.adjustsFontSizeToFitWidth = true
    
    label.backgroundColor =  backgroundColor //UIColor.whiteColor()
    label.textColor = textColor //TEXT COLOR
    
    label.sizeToFit()
    label.numberOfLines = 4
    label.layer.shadowColor = UIColor.grayColor().CGColor
    label.layer.shadowOffset = CGSizeMake(4, 3)
    label.layer.shadowOpacity = 0.3
    label.frame = CGRectMake(320, 64, appDelegate.window!.frame.size.width, 44)
    label.alpha = 1
    
    appDelegate.window!.addSubview(label)
    
    var basketTopFrame: CGRect = label.frame;
    basketTopFrame.origin.x = 0;
    
    UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
        label.frame = basketTopFrame
    },  completion: {
        (value: Bool) in
        UIView.animateWithDuration(2.0, delay: 2.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            label.alpha = 0
        },  completion: {
            (value: Bool) in
            label.removeFromSuperview()
        })
    })
}

