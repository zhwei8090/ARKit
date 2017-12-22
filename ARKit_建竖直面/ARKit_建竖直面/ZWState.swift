//
//  ZWState.swift
//  ARKit_建竖直面
//
//  Created by zhangwei on 2017/12/21.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import Foundation
import ARKit
import SceneKit
enum ZWState {
    case findFirstPoint
    case findNextPoint(trackingNode:SCNNode,willStartPosision:SCNVector3,originAnchor:ARPlaneAnchor)
}
