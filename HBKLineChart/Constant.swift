//
//  Constant.swift
//  HBKLineChart
//
//  Created by xiaohaibo on 6/23/16.
//  Copyright © 2016 xiaohaibo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

struct Constant {
    static let upColor = UIColor.init(colorLiteralRed: 226.0/255, green: 35.0/255, blue: 26.0/255, alpha: 1)
    static let downColor = UIColor.init(colorLiteralRed: 1.0/255, green: 186.0/255, blue: 80.0/255, alpha: 1)
    static let backgroundColor = UIColor.init(colorLiteralRed: 16.0/255, green: 20.0/255, blue: 25.0/255, alpha: 1)
    static let gridLineColor = UIColor.init(colorLiteralRed: 45.0/255, green: 45.0/255, blue: 45.0/255, alpha: 1)
    static var lineGap :CGFloat = 1
    static var lineWidth :CGFloat = 10  {
        didSet{
            if lineWidth > 20 {
                lineWidth = 20
            }
            if lineWidth < 0.1 {
                lineWidth = 0.1
            }
            
            
        }
        
    }
}

