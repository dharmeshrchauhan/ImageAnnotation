//
//  Line.swift
//  ImageAnnotation
//
//  Created by Sagar on 13/02/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

import UIKit

class Line {
    var start: CGPoint
    var end: CGPoint
    var color: UIColor
    var l_width: CGFloat
    
    init(start _start:CGPoint, end _end:CGPoint, color _color: UIColor!, l_width _l_width:CGFloat) {
        start = _start
        end = _end
        color = _color
        l_width = _l_width
    }
    
}