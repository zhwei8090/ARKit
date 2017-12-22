//
//  ViewController.swift
//  ARKit_建竖直面
//
//  Created by zhangwei on 2017/12/21.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    var trackingState = ZWState.findFirstPoint
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackingState = .findFirstPoint
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        sceneView.scene = scene
        
        //1.给sceneView添加点击事件
        sceneView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTap)))
    }
    
    //MARK: anyPlane
    func anyPlaneFrom(location:CGPoint) -> (SCNNode,SCNVector3,ARPlaneAnchor)? {
//         获取在三维空间点击的平面,type:existingPlane 忽略平面大小(无限大的平面)
        let results = sceneView.hitTest(location, types: ARHitTestResult.ResultType.existingPlane)
        print("results count =  \(results.count)")
        guard results.count > 0,
            let anchor = results[0].anchor as? ARPlaneAnchor,
            let node = sceneView.node(for: anchor)
        else { return nil }
        return (node,SCNVector3Make(results[0].worldTransform.columns.3.x, results[0].worldTransform.columns.3.y, results[0].worldTransform.columns.3.z),anchor)
    }
    func addingWallTapped(location:CGPoint){
        switch trackingState
        {
        case .findFirstPoint:
            guard let planeData = anyPlaneFrom(location: location) else { return}
            let node = TrackingNode.node(from: (planeData.1), to: nil)
            sceneView.scene.rootNode.addChildNode(node)
            trackingState = .findNextPoint(trackingNode: node, willStartPosision: planeData.1, originAnchor: planeData.2)
        case .findNextPoint(let trackingNode,let wallStartPosition,let originAnchor):
            //这里需要判断是否在同一个平面上
            guard let planeData = anyPlaneFrom(location: self.view.center),
                    originAnchor == planeData.2 else { return}
            trackingNode.removeFromParentNode()
            let wallNode = Wall.node(from: wallStartPosition, to: planeData.1)
            sceneView.scene.rootNode.addChildNode(wallNode)
            let node = TrackingNode.node(from: planeData.1, to:nil)
            sceneView.scene.rootNode.addChildNode(node)
           trackingState = . findNextPoint(trackingNode: node, willStartPosision: planeData.1, originAnchor: planeData.2)
        }
    }
    func updateNode(){
        guard case .findNextPoint(let trackingNode,let wallStartPosition,let originAnchor) = trackingState,
        let planeData = anyPlaneFrom(location: self.view.center),
        planeData.2 == originAnchor else { return }
        trackingNode.removeFromParentNode()
        let newTrackingNode = TrackingNode.node(from: wallStartPosition, to: planeData.1)
        
        sceneView.scene.rootNode.addChildNode(newTrackingNode)
        trackingState = .findNextPoint(trackingNode: newTrackingNode, willStartPosision: wallStartPosition, originAnchor: originAnchor)
    }
    //MARK: touch event
    @objc func didTap(sender:UITapGestureRecognizer){
        //2.收到点击事件,确定是在某个平面上
        let location = sender.location(in: sceneView)
        addingWallTapped(location:location)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async(execute: updateNode)
    }
}
