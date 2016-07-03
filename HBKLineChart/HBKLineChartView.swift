//
//  HBKLineChartView.swift
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

class HBKLineChartView: UIView {
    
    var topMargin :Float = 10
    var bottomMargin :Float = 20
    var keyMaxElement :HBStockModel?
    var keyMinElement :HBStockModel?
    var KStockModelArray :Array<HBStockModel> = []
    var selectedModel :HBStockModel?
    var selectedPoint :CGPoint!
    var scaleYAxis :Float = 0
    var maxLocalElement :Float = 0
    var minLocalElement :Float = 0
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.drawBorder(rect)
        self.drawYAxis()
        self.drawCandleStick()
        self.drawCrossLine()
        
    }
    func drawBorder(_ rect: CGRect) -> () {
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(Constant.backgroundColor.cgColor)
        context.fill(rect)
        context.setLineWidth(1)
        context.setStrokeColor(Constant.gridLineColor.cgColor)
        context.stroke(CGRect(origin: rect.origin, size:CGSize(width: rect.width, height: rect.height - CGFloat(bottomMargin))))
        
    }
    func drawKLine(_ KLineModeArray:Array<HBStockModel>) -> () {
        self.KStockModelArray = KLineModeArray
        self.prepareData()
        self.setNeedsDisplay()
    }
    func prepareData() -> () {
        
        keyMaxElement = self.KStockModelArray.max(isOrderedBefore: { (a, b) -> Bool in
            return a.high < b.high
        })
        keyMinElement = self.KStockModelArray.max(isOrderedBefore: { (a, b) -> Bool in
            return a.low > b.low
        })
        let minY :Float = topMargin
        let maxY :Float = Float(self.frame.size.height) - bottomMargin
        self.maxLocalElement = (keyMaxElement?.high)! * 1.002
        self.minLocalElement = (keyMinElement?.low)! * 0.998
        self.scaleYAxis  = (Float(maxLocalElement) - Float(minLocalElement))/(maxY - minY)
        
    }
    func drawYAxis() -> (){
        
        let context = UIGraphicsGetCurrentContext()!
        let dash:[CGFloat] = [2.0,1.0]
        context.setLineWidth(1)
        context.setLineDash (phase: 0,lengths: dash,count: 2)
        for  i in 0 ..< 5 {
            let value :Float = maxLocalElement - Float(i) * (maxLocalElement - minLocalElement)/4
            let yLine :Float = topMargin + (maxLocalElement - value)/scaleYAxis
            
            
            let size :CGSize = CGSize(width: 120, height: 23)
            var x :CGFloat = 0
            let y :CGFloat = CGFloat(yLine) - (size.height)/2
            
            //price
            context.setShouldAntialias(true)
            let textAttributes: [String: AnyObject] = [
                NSForegroundColorAttributeName : UIColor.lightGray(),
                NSFontAttributeName : UIFont.systemFont(ofSize: 11)
            ]
            let labelString = String(format:"%.2f", value)
            labelString.draw(at: CGPoint(x: x + 2, y: y ), withAttributes:textAttributes)
            //yAxis
            if i != 0 && i != 4 {
                context.setStrokeColor(Constant.gridLineColor.cgColor)
                x = (self.frame.size.width)
                context.moveTo(x:1,y: CGFloat(yLine))
                context.addLineTo(x: x,y: CGFloat(yLine))
                context.strokePath()
                
            }
            
        }
        context.setLineDash (phase: 0,lengths: nil,count: 0)
        
    }
    
    func drawCandleStick() -> () {
        
        for ( index,  stockModel) in self.KStockModelArray.enumerated() {
            
            let maxY :Float = Float(self.frame.size.height) - bottomMargin
            let xPosition:Float =  Float(Constant.lineWidth/2) + Float(index)*(Float(Constant.lineWidth) + Float(Constant.lineGap))
            let context = UIGraphicsGetCurrentContext()!
           
            let strokeColor : UIColor =  stockModel.open > stockModel.close ? Constant.downColor : Constant.upColor
            context.setStrokeColor(strokeColor.cgColor)
            let openPoint = CGPoint(x: Double(xPosition),y:Double(maxY - ( stockModel.open! - minLocalElement)/scaleYAxis))
            let closePointY = maxY - ( stockModel.close! - minLocalElement)/scaleYAxis
            let closePoint = CGPoint(x:Double(xPosition),y:Double(closePointY))
            let highPoint = CGPoint(x: Double(xPosition), y: Double(maxY) - Double(( stockModel.high! - minLocalElement)/scaleYAxis))
            let lowPoint = CGPoint(x: Double(xPosition), y: Double(maxY - ( stockModel.low! - minLocalElement)/scaleYAxis))
            
        
            context.setLineWidth(1)
            let shadowPoints = [highPoint, lowPoint]
            context.strokeLineSegments(between: shadowPoints, count: 2)
            context.setLineWidth(CGFloat(Constant.lineWidth))
            let solidPoints = [openPoint, closePoint]
            context.strokeLineSegments(between: solidPoints, count: 2)
            
            
        }
        
    }
    func drawCrossLine() -> () {
        for ( index,  stockModel) in self.KStockModelArray.enumerated() {
            
            let maxY :Float = Float(self.frame.size.height) - bottomMargin
            if selectedModel ==  stockModel {
                let context = UIGraphicsGetCurrentContext()!
                
                let fY:CGFloat = CGFloat(maxY - ((selectedModel?.close)! - minLocalElement)/scaleYAxis)
                let value :Float = (selectedModel?.close)!
                let string :String =  String(format:"%.2f", value)
                var size: CGSize = string.size(attributes:[NSFontAttributeName: UIFont.systemFont(ofSize:12.0)])
                size = CGSize(width: size.width + 4,height:size.height)
                
                var x : CGFloat = 0
                let y : CGFloat = fY - size.height/2
                //horizonal line
                context.setLineWidth(1)
                context.setStrokeColor(UIColor.white().cgColor)
                if(self.selectedPoint.x<size.width+50){
                    x = self.frame.size.width - size.width
                    context.moveTo(x: 0, y: fY)
                    context.addLineTo(x: x, y: fY)
                    context.strokePath()
                    
                }else{
                    context.moveTo(x: size.width, y: fY)
                    context.addLineTo(x: self.frame.size.width, y: fY)
                    context.strokePath()
                }
                
                let roundedRect :UIBezierPath = UIBezierPath.init(roundedRect: CGRect(origin: CGPoint(x:x,y:y),size: size), cornerRadius: 2)
                context.setFillColor(UIColor.init(colorLiteralRed: 52.0/255, green: 68.0/255, blue: 106.0/255, alpha: 1).cgColor)
                roundedRect.fill()
                
                string.draw(at:CGPoint(x:x, y:y), withAttributes:[NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.white()])
                let date = selectedModel?.date
                var datesize: CGSize = date!.size(attributes:[NSFontAttributeName: UIFont.systemFont(ofSize:12.0)])
                datesize = CGSize(width: datesize.width + 4,height:datesize.height)
                
                //vertical line
                context.setLineWidth(1)
                let xPosition :CGFloat = Constant.lineWidth/2 +  CGFloat( index) * (Constant.lineWidth + Constant.lineGap)
                context.setStrokeColor(UIColor.white().cgColor)
                context.moveTo(x: xPosition, y: 0)
                context.addLineTo(x: xPosition, y: self.frame.size.height - CGFloat(bottomMargin))
                context.strokePath()
                
                context.setFillColor(UIColor.white().cgColor)
                let circlePath : UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: xPosition,y: fY), radius: CGFloat(4), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
                circlePath.fill()
                
                //date
                var p :CGPoint = CGPoint(x:xPosition - datesize.width/2, y:self.frame.size.height - CGFloat(bottomMargin))
                if p.x < datesize.width/2 {
                    p.x = xPosition
                }
                if xPosition > self.frame.size.width - datesize.width/2 {
                    p.x = xPosition - datesize.width
                }
                let dateRect :UIBezierPath = UIBezierPath.init(roundedRect: CGRect(origin: CGPoint(x:p.x,y:self.frame.size.height - CGFloat(bottomMargin)),size: datesize), cornerRadius: 2)
                context.setFillColor(UIColor.init(colorLiteralRed: 52.0/255, green: 68.0/255, blue: 106.0/255, alpha: 1).cgColor)
                dateRect.fill()
                
                date?.draw(at:p, withAttributes:[NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.white()])
            }
        }
    }
    
    func handleLocation(_ point:CGPoint) -> () {
        for ( index,  stockModel) in self.KStockModelArray.enumerated() {
            let xPosition :CGFloat =  Constant.lineWidth/2  + CGFloat( index) * (Constant.lineGap + Constant.lineWidth)
            
            let minX  :CGFloat = xPosition - (Constant.lineGap + Constant.lineWidth/2)
            let maxX :CGFloat = xPosition +  (Constant.lineGap + Constant.lineWidth/2)
            
            if(point.x > minX && point.x < maxX)
            {
                self.selectedModel =  stockModel
                self.selectedPoint = point
                self.setNeedsDisplay()
            }
            
        }
    }
}
