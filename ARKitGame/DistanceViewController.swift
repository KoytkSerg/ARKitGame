//
//  DistanceViewController.swift
//  ARKitGame
//
//  Created by Sergii Kotyk on 16/2/2022.
//

import UIKit
import ARKit
import SceneKit

class DistanceViewController: UIViewController, SCNPhysicsContactDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var infoLabel: UILabel!
    
    private var location = CGPoint(x: 0, y: 0)
    private var hitPoint =  SCNVector3(x: 0, y: 0, z: 0)

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
//        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        infoLabel.isHidden = true

    }
    override func viewWillAppear(_ animated: Bool) {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    override func viewWillDisappear(_ animated: Bool) {
        sceneView.session.pause()
    }
    
    // тап по экрану и сохранение координат косания
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        infoLabel.isHidden = false
        if let touch = touches.first{
            location = touch.location(in: sceneView)
        }
        infoLabel.text = "\(Int(distance(from: getUserVector(), to: hitPoint) * 100)) см"
    }
    
    // нахождение устройства в пространстве
    func getUserVector() -> SCNVector3{
        if let frame = self.sceneView.session.currentFrame{
            let mat = SCNMatrix4(frame.camera.transform)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            return pos
        }
        return  SCNVector3(0, 0, -0.2)
    }
    
    // подсчет дистанции между двумя векторами
    func distance(from startPoint: SCNVector3, to endPoint: SCNVector3) -> Float {
        let vector = SCNVector3Make(startPoint.x - endPoint.x, startPoint.y - endPoint.y, startPoint.z - endPoint.z)
        let distance = sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        return distance
    }


}
extension DistanceViewController: ARSCNViewDelegate{
    // рендер в реальном времени
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        measure()
    }
    // перевод координат точки на экране в вектор в пространстве
    private func measure() {
        let hitResults = sceneView.hitTest(location, types: [.featurePoint])
        if let hit = hitResults.first {
            let hitTransform = SCNMatrix4(hit.worldTransform)
            hitPoint = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        }
        
    }
}
