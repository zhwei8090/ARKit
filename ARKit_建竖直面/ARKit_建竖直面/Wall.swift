//
//  Wall.swift
//  ARKit_建竖直面
//
//  Created by zhangwei on 2017/12/22.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import Foundation
import SceneKit
class Wall
{
    static let HEIGHT:CGFloat = 0.3
    class func wallMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.darkGray
        mat.transparency = 0.5
        mat.isDoubleSided = true
        return mat
    }
    class func node(from:SCNVector3,to:SCNVector3) -> SCNNode {
        // 计算两个向量的距离
        let distance = from.distance(vector: to)
        // 建墙
        let wall = SCNPlane(width: CGFloat(distance), height: HEIGHT)
        wall.firstMaterial = self.wallMaterial()
        let node = SCNNode(geometry: wall)
        node.renderingOrder = -10
        //位置
        node.position = SCNVector3Make(from.x + (to.x - from.x) * 0.5,
                                       from.y + Float(HEIGHT) * 0.5,
                                       from.z + (to.z - from.z) * 0.5)
        //旋转
        node.eulerAngles = SCNVector3(0,-atan2(to.x - node.position.x,from.z - node.position.z) - Float.pi * 0.5,0)
        return node;
    }
}

func +(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}
func -(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    
    return left + (right * -1.0)
}
func *(vector:SCNVector3, multiplier:SCNFloat) -> SCNVector3 {
    
    return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
}
extension SCNVector3 {
    
    func dotProduct(_ vectorB:SCNVector3) -> SCNFloat {
        
        return (x * vectorB.x) + (y * vectorB.y) + (z * vectorB.z)
    }
    
    var magnitude:SCNFloat {
        get {
            return sqrt(dotProduct(self))
        }
    }
    
    var normalized:SCNVector3 {
        get {
            let localMagnitude = magnitude
            let localX = x / localMagnitude
            let localY = y / localMagnitude
            let localZ = z / localMagnitude
            
            return SCNVector3(localX, localY, localZ)
        }
    }
    
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    
    func distance(vector: SCNVector3) -> Float {
        return (self - vector).length()
    }
}
