//
//  ViewController.swift
//  ARKitGame
//
//  Created by Sergii Kotyk on 15/2/2022.
//Разработайте свою игру, в которой при запуске в 3D-AR-пространстве будет генерироваться 100 кубов случайных цветов (шесть любых цветов на ваш выбор). Внизу экрана должна быть панель, в которой можно выбрать один из этих цветов. По нажатии на экран в AR-пространство должен вылетать шар выбранного цвета. При столкновении с кубом такого же цвета оба объекта должны исчезать. При столкновении с кубом другого цвета должен исчезать только шар.
//Реализуйте проект, в котором показывается камера, а при нажатии на экран в нижней части показывается приблизительное расстояние до точки, на которую нажал пользователь.

import UIKit
import SceneKit
import ARKit

struct CollisionCategory: OptionSet{
    let rawValue: Int

    static let missleCategory = CollisionCategory(rawValue: 1 << 0)
    static let targetCategory = CollisionCategory(rawValue: 1 << 1)

}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var aimHor: UIView!
    @IBOutlet weak var aimVert: UIView!
    
    let colours = [
        UIColor.green,
        UIColor.red,
        UIColor.purple,
        UIColor.gray,
        UIColor.orange,
        UIColor.yellow]
    
    var currentColourName = "green"
    
    @IBAction func greenButton(_ sender: Any) {
        aimSetings(colour: colours[0])
        currentColourName = "green"
    }
    @IBAction func redButton(_ sender: Any) {
        aimSetings(colour: colours[1])
        currentColourName = "red"
    }
    @IBAction func purpleButton(_ sender: Any) {
        aimSetings(colour: colours[2])
        currentColourName = "purple"
    }
    @IBAction func blackButton(_ sender: Any) {
        aimSetings(colour: colours[3])
        currentColourName = "gray"
    }
    @IBAction func orangeButton(_ sender: Any) {
        aimSetings(colour: colours[4])
        currentColourName = "orange"
    }
    @IBAction func yellowButton(_ sender: Any) {
        aimSetings(colour: colours[5])
        currentColourName = "yellow"
    }
    // MARK: - настройка кнопок и прицела
    func buttonsSettings(){
        let radius = UIScreen.main.bounds.width / 12
        let buttons = [
        greenButton,
        redButton,
        purpleButton,
        blackButton,
        orangeButton,
        yellowButton]

        for i in 0...5 {
            buttonSetings(button: buttons[i]!, colour: colours[i], radius: radius)
        }
    }
    func buttonSetings(button: UIButton, colour: UIColor, radius: CGFloat){
        button.backgroundColor = colour
        button.layer.cornerRadius = radius
        button.setTitle("", for: .normal)
        
    }
    
    func aimSetings(colour: UIColor){
        aimHor.backgroundColor = colour
        aimVert.backgroundColor = colour
    }
    
    
    // MARK: - базовые функции
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        aimSetings(colour: colours[0])
        addBoxes()
        buttonsSettings()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - создания кубов
    // функция для создания 1 куба
    func addBox(colour: UIColor, xPos: Float, yPos: Float, zPos: Float) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(xPos, yPos, -1)
        
        switch colour{
        case colours[0]:
            boxNode.name = "green"
        case colours[1]:
            boxNode.name = "red"
        case colours[2]:
            boxNode.name = "purple"
        case colours[3]:
            boxNode.name = "gray"
        case colours[4]:
            boxNode.name = "orange"
        default:
            boxNode.name = "yellow"
        }
        
        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.locksAmbientWithDiffuse = true
        boxNode.geometry?.materials = [material]
        
        boxNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        boxNode.physicsBody?.isAffectedByGravity = false
        boxNode.physicsBody?.categoryBitMask = CollisionCategory.targetCategory.rawValue
        boxNode.physicsBody?.contactTestBitMask = CollisionCategory.missleCategory.rawValue
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    // рандомаизер
    func randomPosition(from: Float, to: Float) -> Float{
        return Float(arc4random()) / Float(UInt32.max) * (from - to) + to
    }
    // задаём рандомные позиции для кубов
    func addRandomPositionBoxes(number: Int, colour: UIColor){
        for _ in 1...number{
            let xPos = randomPosition(from: -1.5, to: 1.5)
            let yPos = randomPosition(from: -1.5, to: 1.5)
            let zPos = randomPosition(from: -4, to: 0)
            addBox(colour: colour, xPos: xPos, yPos: yPos, zPos: zPos)
            
        }
    }
    // добавляем по 16 кубов каждого из 6 цветов
    func addBoxes(){
        for i in colours{
            addRandomPositionBoxes(number: 16, colour: i)
        }
    }
//MARK: - создание шара(пули)
    func createBall(colour: UIColor) -> SCNNode{
        let ball = SCNSphere(radius: 0.03)
        let ballNode = SCNNode()
        ballNode.geometry = ball
        ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        ballNode.physicsBody?.isAffectedByGravity = false
        
        let material = SCNMaterial()
        material.diffuse.contents = colour
        material.locksAmbientWithDiffuse = true
        ballNode.geometry?.materials = [material]
        
        switch colour{
        case colours[0]:
            ballNode.name = "green"
        case colours[1]:
            ballNode.name = "red"
        case colours[2]:
            ballNode.name = "purple"
        case colours[3]:
            ballNode.name = "gray"
        case colours[4]:
            ballNode.name = "orange"
        default:
            ballNode.name = "yellow"
        }
        
        ballNode.physicsBody?.categoryBitMask = CollisionCategory.missleCategory.rawValue
        ballNode.physicsBody?.contactTestBitMask = CollisionCategory.targetCategory.rawValue
        
        return ballNode
    }
//MARK: - запуск
    func fire(colour: UIColor){
        let node = createBall(colour: colour)
        let (direction, position) = getUserVector()
        node.position = position
        let nodeDirection = SCNVector3(direction.x*4, direction.y*4, direction.z*4)
        node.physicsBody?.applyForce(nodeDirection, at: SCNVector3(0.1, 0, 0), asImpulse: true)
        sceneView.scene.rootNode.addChildNode(node)
        
    }
    // поиск позиции и вектора устройства в прострвнстве
    func getUserVector() -> (SCNVector3, SCNVector3){
        if let frame = self.sceneView.session.currentFrame{
            let mat = SCNMatrix4(frame.camera.transform)
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    // запуск при косании к экрану
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fire(colour: aimHor.backgroundColor!)

    }
    

}
//MARK: - обработка столкновений
extension ViewController: SCNPhysicsContactDelegate{
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if contact.nodeA.name == contact.nodeB.name{
            DispatchQueue.main.async {
                contact.nodeA.removeFromParentNode()
                contact.nodeB.removeFromParentNode()
            }
        }
    }
}

