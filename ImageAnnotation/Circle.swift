//
//  Circle.swift
//  ImageAnnotation
//
//  Created by Sagar on 15/04/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

import Foundation

class Circle {
    var color: UIColor
    var l_width: CGFloat
    var start: CGPoint
    var end: CGPoint
    
    init(color _color: UIColor!, l_width _l_width:CGFloat, start _start: CGPoint, end _end: CGPoint) {
        color = _color
        l_width = _l_width
        start = _start
        end = _end
    }
}