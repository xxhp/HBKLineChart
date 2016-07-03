//
//  HBKLineChartViewController.swift
//  HBKLineChart
//
//  Created by xiaohaibo on 6/22/16.
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

class HBKLineChartViewController: UIViewController {
    var kLineChartView:HBKLineChartView?
    var timer:Timer!
    var items = NSMutableArray()
    var startIndex :Int = 0
    var lastIndex :Int = 0
    var touchedPoint :CGPoint?
    var MaxDrawCount :Int {
        get {
            let lineGap = Constant.lineGap
            let lineWidth = Constant.lineWidth
            let scrollViewWidth =  kLineChartView?.frame.size.width 
            let MaxDrawCount :Int = Int((scrollViewWidth! - lineGap)/(lineGap + lineWidth))
            return MaxDrawCount
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Constant.backgroundColor
       
        let zoomOutButton: UIButton = {
            let button = UIButton(type: UIButtonType.custom) as UIButton
            button.frame = CGRect(x:self.view.frame.size.width - 90 , y: 245, width: 20, height: 20)
            let image = UIImage(named: "zoom_out") as UIImage?
            button.setBackgroundImage(image, for: UIControlState())
            button.addTarget(self, action: #selector(HBKLineChartViewController.zoomOut(_:)), for:.touchUpInside)
            let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(HBKLineChartViewController.zoomOutGesture(_:)))
            longPress.minimumPressDuration = 0.3 
            button.addGestureRecognizer(longPress)
            return button
        }()
        let zoomInButton: UIButton = {
            let button = UIButton(type: UIButtonType.custom) as UIButton
            button.frame = CGRect(x: self.view.frame.size.width - 50 , y: 245, width: 20, height: 20)
            let image = UIImage(named: "zoom_in") as UIImage?
            button.setBackgroundImage(image, for: UIControlState())
            button.addTarget(self, action: #selector(HBKLineChartViewController.zoomIn(_:)), for:.touchUpInside)
            let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(HBKLineChartViewController.zoomInGesture(_:)))
            longPress.minimumPressDuration = 0.3 
            button.addGestureRecognizer(longPress)
            
            return button
        }()
        kLineChartView = HBKLineChartView(frame: CGRect(x: 5, y: 20, width: self.view.bounds.width - 10, height: 270)) 
        let panGesture:UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(HBKLineChartViewController.panGesture(_:)))
        kLineChartView?.addGestureRecognizer(panGesture)
        self.view.addSubview(kLineChartView!)
        self.view.insertSubview(zoomOutButton, aboveSubview: kLineChartView!)
        self.view.insertSubview(zoomInButton, aboveSubview: kLineChartView!)
        
        self.queryNetData()
        
    }
    func queryNetData() -> () {
        NetService.queryData(completed: {data,error in
            let dataString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
            let dataArray = dataString!.components(separatedBy: NSCharacterSet.newlines()) as NSArray!
            
            let dataReversArray = dataArray?.reverseObjectEnumerator().allObjects as NSArray!
            for  (index, string) in (dataReversArray?.enumerated())!  {
                if (index != 0 && index != (dataReversArray?.count)! - 1){
                    let stringArray = string.components(separatedBy:",") as NSArray
                    let date = stringArray.object(at: 0) as! String
                    let open = stringArray.object(at: 1) as! String
                    let high = stringArray.object(at: 2) as! String
                    let low = stringArray.object(at: 3) as! String
                    let close = stringArray.object(at: 4) as! String
                    let volume = stringArray.object(at: 5) as! String
               
                    let user = HBStockModel(low:Float(low)!, high:Float(high)!, open: Float(open)!, close: Float(close)!, date:date, volume: Float(volume)!)
                    self.items.add(user)
                }
                
            }

            DispatchQueue.main.async(execute: { () -> Void in
                self.lastIndex = self.items.count
                self.kLineChartView?.drawKLine(self.drawedModel())
            })
        })
    }
    
    func zoomInGesture(_ sender:UILongPressGestureRecognizer){
        
        if(sender.state == UIGestureRecognizerState.ended){
            timer.invalidate()
            timer = nil 
        }
        if sender.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(HBKLineChartViewController.zoomIn(_:)), userInfo: nil, repeats: true)
        }
        
    }
    func zoomOutGesture(_ sender:UILongPressGestureRecognizer){
        
        if(sender.state == UIGestureRecognizerState.ended){
            timer.invalidate()
            timer = nil 
        }
        if sender.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(HBKLineChartViewController.zoomOut(_:)), userInfo: nil, repeats: true)
        }
        
    }
    
    
    
    func zoomOut(_ sender: AnyObject) {
        Constant.lineWidth -= 0.5
        self.kLineChartView?.selectedModel = nil
        self.kLineChartView?.drawKLine(self.drawedModel()) 
        
    }
    func zoomIn(_ sender: UIButton) {
        Constant.lineWidth += 0.5
        self.kLineChartView?.selectedModel = nil
        self.kLineChartView?.drawKLine(self.drawedModel()) 
    }
    func panGesture(_ sender:UILongPressGestureRecognizer){
        switch sender.state {
        case sender.state where sender.state != UIGestureRecognizerState.ended:
            let location = sender.location(in: kLineChartView) 
            self.handleLocation(location)
            break
        case  UIGestureRecognizerState.ended:
            if (timer != nil) {
                timer.invalidate()
                timer = nil
            }
            break
        default:
            break
        }
        
        
    }
    func handleLocation(_ point:CGPoint) -> () {
        touchedPoint = point
        if (timer != nil) {
            timer.invalidate()
            timer = nil
        }
        
        for (idx, kLineModel) in (kLineChartView?.KStockModelArray.enumerated())! {
            let xPosition :CGFloat =  Constant.lineWidth/2  + CGFloat(idx) * (Constant.lineGap + Constant.lineWidth) 
            
            let minX  :CGFloat = xPosition - (Constant.lineGap + Constant.lineWidth/2)
            let maxX :CGFloat = xPosition +  (Constant.lineGap + Constant.lineWidth/2)
            
            if(point.x > minX && point.x < maxX)
            {
                kLineChartView?.selectedModel = kLineModel
                if idx == 0 {
                    timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(HBKLineChartViewController.moveLeft(_:)), userInfo: nil, repeats: true)
                }
                if idx == (kLineChartView?.KStockModelArray.count)! - 1 {
                    timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(HBKLineChartViewController.moveRight(_:)), userInfo: nil, repeats: true)
                }
                
                
                kLineChartView?.selectedPoint = point
                kLineChartView?.setNeedsDisplay()
            }
            
        }
        
    }
    func moveLeft(_ sender: AnyObject) {
        if self.lastIndex - self.MaxDrawCount - 1 >= 0{
            self.lastIndex -= 1 
        } else {
            if (self.items.count < self.MaxDrawCount) {
                self.lastIndex = self.items.count 
            } else {
                self.lastIndex = self.MaxDrawCount 
            }
        }
        self.kLineChartView?.drawKLine(self.drawedModel()) 
        kLineChartView?.handleLocation(touchedPoint!)
    }
    
    func moveRight(_ sender: AnyObject) {
        if (self.lastIndex + 1 < self.items.count) {
            
            self.lastIndex += 1 
        } else {
            
            self.lastIndex = self.items.count 
        }
        self.kLineChartView?.drawKLine(self.drawedModel()) 
        kLineChartView?.handleLocation(touchedPoint!)    }
    

    func drawedModel() -> Array<HBStockModel> {
        let  count :Int = self.items.count
        var  startIndex:Int = 0
        if  lastIndex <= self.items.count {
            if (lastIndex  >= self.MaxDrawCount){
                startIndex = lastIndex - self.MaxDrawCount
                let array = self.items.subarray(with: NSMakeRange(startIndex,self.MaxDrawCount)) as? Array<HBStockModel>
                return array!
            } else {
                startIndex = 0
                let  rightEdgeIndex :Int = self.items.count < self.MaxDrawCount ? self.items.count :self.MaxDrawCount 
                let  array = self.items.subarray(with: NSMakeRange(startIndex,rightEdgeIndex)) as? Array<HBStockModel>
                
                return array!
            }
        } else {
            let array = self.items.subarray(with: NSMakeRange(0,count)) as? Array<HBStockModel>
            return array!
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




