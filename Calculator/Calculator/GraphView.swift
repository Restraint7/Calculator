//
//  GraphView.swift
//  Caculator
//
//  Created by 凯琦牟 on 2017/7/27.
//  Copyright © 2017年 凯琦牟. All rights reserved.
//

import UIKit

class GraphView: UIView {

    var scale : CGFloat = 40.0 { didSet { setNeedsDisplay() } }
    var color : UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    var axesColor : UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() } }
    var origin = CGPoint.zero { didSet { setNeedsDisplay() } }
    var expression = VariableNumber(vairablename: nil,numberpart: nil,variablepart: [variablenumber](),newvariable: nil)
    
    var originIsSet = false
    
    private var axesDrawer = AxesDrawer()
    
    override func draw(_ rect: CGRect) {
        if originIsSet == false{
            origin = center
            originIsSet = true
        }
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.color = axesColor
        axesDrawer.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
        if expression.variablepart.isEmpty == false {
            drawCurve(variableExpression: expression)
        }
    }
    
    func changescale (byReactingTo pinchRecognizer : UIPinchGestureRecognizer){
        switch pinchRecognizer.state{
        case .changed,.ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    
    var startOrigin : CGPoint!
    
    func moveView (byReactingTo panRecognizer : UIPanGestureRecognizer){
        switch panRecognizer.state{
        case .began:
            startOrigin = origin
        case .changed,.ended:
            let neworigin = CGPoint(x: startOrigin.x + panRecognizer.translation(in: self).x, y: startOrigin.y + panRecognizer.translation(in: self).y)
            origin = neworigin
        default:
            startOrigin = nil
            break
        }
    }
    
    func originView (byReactingTo panRecognizer : UIPanGestureRecognizer){
        switch panRecognizer.state{
        case .changed,.ended:
            origin = center
        default:
            break
        }
    }
    
    func drawCurve (variableExpression:VariableNumber){
        let minOfDomain = Double((bounds.minX - origin.x)/scale)
        color.set()
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        var startDraw = false
        for i in 0...Int(bounds.size.width){
            let x = Double(i)/Double(scale) + minOfDomain
            let y = calculateResult(variableExpression, variableValue: x) ?? 0.0
            if y.isNaN == false {
                if startDraw == false {
                    path.move(to: CGPoint(x: CGFloat(i), y: origin.y - bounds.minY - CGFloat(y)*scale))
                    startDraw = true
                }else{
                    path.addLine(to: CGPoint(x: CGFloat(i), y: origin.y - bounds.minY - CGFloat(y)*scale))
                }
            }else{
                startDraw = false
            }
            path.stroke()
        }
    }
    
}
