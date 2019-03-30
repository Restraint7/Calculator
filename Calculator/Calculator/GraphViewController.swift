//
//  GraphViewController.swift
//  Caculator
//
//  Created by 凯琦牟 on 2017/7/27.
//  Copyright © 2017年 凯琦牟. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView!  {
        didSet{
            let changeScaleHandler = #selector(GraphView.changescale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: changeScaleHandler)
            graphView.addGestureRecognizer(pinchRecognizer)
            let moveViewHandler = #selector(GraphView.moveView(byReactingTo:))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: moveViewHandler)
            graphView.addGestureRecognizer(panRecognizer)
            updateExpression()
            let originViewHandler = #selector(GraphView.originView(byReactingTo:))
            let doublePanRecognizer = UITapGestureRecognizer(target: graphView, action: originViewHandler)
            doublePanRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doublePanRecognizer)
        }
    }
    
    var result = VariableNumber(vairablename: nil,numberpart: nil,variablepart: [variablenumber](),newvariable: nil)
    
    func updateExpression(){
        graphView.expression = result
    }
    
}
