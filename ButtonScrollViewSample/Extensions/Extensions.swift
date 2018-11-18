//
//  Extensions.swift
//  ButtonScrollViewSample
//
//  Created by Park on 2018/11/15.
//  Copyright © 2018年 park. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension UIColor {
    
    convenience init(hex: String) {
        
        var r: Float = 1
        var g: Float = 1
        var b: Float = 1
        var a: Float = 1
        var hexStr: String
        
        let tmpStr = String(hex[hex.index(after: hex.startIndex)..<hex.endIndex])
        let strCount: Int = tmpStr.count
        
        if strCount > 7 {
            // add alpha
            let alphaStr = tmpStr.prefix(2)
            if let num = Int(alphaStr, radix: 16) {
                a = Float(num) / 255.0
            }
            
            //add hex
            hexStr = String(tmpStr[tmpStr.index(tmpStr.startIndex, offsetBy: 2)...tmpStr.index(before: tmpStr.endIndex)])
            if let num = Int(hexStr, radix: 16) {
                r = Float((num >> 16) & 0xFF) / 255.0
                g = Float((num >> 8) & 0xFF) / 255.0
                b = Float((num) & 0xFF) / 255.0
            }
            
        }
        else if strCount == 6 {
            let hexRange = NSRange(location: 0, length: hex.count)
            hexStr = (hex as NSString).replacingOccurrences(of: "[^0-9a-fA-F]", with: "", options: .regularExpression, range: hexRange)
            
            if let num = Int(hexStr, radix: 16) {
                r = Float((num >> 16) & 0xFF) / 255.0
                g = Float((num >> 8) & 0xFF) / 255.0
                b = Float((num) & 0xFF) / 255.0
            }
        }
        else {
            hexStr = "FFFFFF"
        }
        
        self.init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
    
    class func hexStr ( _ hexStr: NSString, alpha: CGFloat) -> UIColor {
        let hexStr = hexStr.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        }
        else {
            print("invalid hex string")
            return UIColor.white
        }
    }
    class func rgb(_ r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return rgba(r, g: g, b: b, a: 1.0)
    }
    
    class func rgba(_ r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        
        let denominator: CGFloat = 255.0
        
        let red = r / denominator
        let green = g / denominator
        let blue = b / denominator
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: a)
        return color
    }
    
    func toImage(_ size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func circleImage(_ size: CGSize) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(self.cgColor)
        context?.fillEllipse(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func dark(ratio: CGFloat) -> UIColor {
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness * ratio, alpha: alpha)
    }

}

enum ScrollDirection {
    case None
    case Up
    case Down
    case Left
    case Right
}
extension UIScrollView {
    var rx_reachedBottom: Observable<Void> {
        
        return Observable.zip(rx.contentOffset.asObservable(), rx.contentOffset.skip(1)) { ($0, $1) }
            .flatMap { [weak self] offsets -> Observable<Void> in
                guard let scrollView = self else {
                    return Observable.empty()
                }
                
                let contentOffset: CGPoint = offsets.1
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                
                // 閾値を超えた場合は、一度しか川が流れないように制御する
                // 通信エラー時に閾値を超えてoffSetが変化し続けることで川が流れ続けてしまうのを防ぐ
                
                let prevContentOffset: CGPoint = offsets.0
                if prevContentOffset.y > threshold {
                    return Observable.empty()
                }
                return y > threshold ? Observable.just(Void()) : Observable.empty()
        }
    }
    
    var rx_contentOffsetDiff: Observable<(CGPoint, CGPoint)> {
        return Observable.zip(rx.contentOffset.asObservable(), rx.contentOffset.skip(1)) { ($0, $1) }
    }
    
    var rx_verticalScrollDirection: Observable<ScrollDirection> {
        return rx_contentOffsetDiff.flatMap { (old, new) in
            Observable<ScrollDirection>.create { observe in
                let direction = old.y < new.y ? ScrollDirection.Up : old.y > new.y ? .Down : .None
                observe.onNext(direction)
                observe.onCompleted()
                return Disposables.create {}
            }
        }
    }
    
    var rx_HorizontalScrollDirection: Observable<ScrollDirection> {
        return rx_contentOffsetDiff.flatMap { (old, new) in
            Observable<ScrollDirection>.create { observe in
                
                let direction = old.x < new.x ? ScrollDirection.Left : old.x > new.x ? .Right : .None
                observe.onNext(direction)
                observe.onCompleted()
                return Disposables.create {}
            }
        }
    }
    
}

