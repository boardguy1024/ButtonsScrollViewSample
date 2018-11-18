//
//  InstantiableFromStoryboard.swift
//  ButtonScrollViewSample
//
//  Created by park on 2018/11/15.
//  Copyright © 2018年 park. All rights reserved.
//
import UIKit

public protocol BundleSearchable {
    static func searchBundle() -> Bundle?
}

extension BundleSearchable {
    public static func searchBundle() -> Bundle? {
        if let anyClass = self as? AnyClass {
            return Bundle(for: anyClass)
        } else {
            return nil
        }
    }
}

public protocol InstantiableFromStoryboard: BundleSearchable {
    associatedtype VCType = Self
    
    static var storyboardName: String { get }
    static var defaultIdentifier: String? { get }
    
    static func instantiate() -> VCType
}

extension InstantiableFromStoryboard {
    static var storyboardName: String {
        return String(describing: VCType.self)
    }
    
    static var defaultIdentifier: String? {
        return nil
    }
    
    static func instantiate() -> VCType {
        let storyboard = UIStoryboard(name: storyboardName, bundle: searchBundle())
        
        if let identifier = defaultIdentifier {
            return storyboard.instantiateViewController(withIdentifier: identifier) as! VCType
        } else {
            return storyboard.instantiateInitialViewController() as! VCType
        }
    }
}
