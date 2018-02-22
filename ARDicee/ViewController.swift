//
//  ViewController.swift
//  ARDicee
//
//  Created by Raymond Kim on 1/16/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interrupting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start ARSession
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - IBActions
    
    @IBAction func resetBtnTapped(_ sender: UIBarButtonItem) {
        resetTracking()
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - ARSCNViewDelegateMethods
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let anchorNode = SCNNode()
        
        guard let anchor = anchor as? ARPlaneAnchor else {
            return nil
        }
        
        let planeNode = createPlane(withPlaneAnchor: anchor)
        
        anchorNode.addChildNode(planeNode)
        
        // return ARAnchorNode
        return anchorNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        // convert ARAnchor to ARPlaneAnchor to get access to ARPlaneAnchor's extent and center vals
        guard let anchor = anchor as? ARPlaneAnchor,
            let updatedNode = node.childNodes.first,
            let plane = updatedNode.geometry as? SCNPlane
            else { return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform
        updatedNode.simdPosition = float3(x: anchor.center.x, y: 0, z: anchor.center.z)
        updatedNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "mondrianpainting")
        
        // Plane estimation may also extent planes or merge its extent into another
        plane.width = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
    }
    
    // MARK: - Plane Rendering Methods
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        
        let planeNode = SCNNode()
        
        // create plane geometry
        planeNode.geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        // transform node
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "mondrianpainting")
        planeNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
        
        return planeNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

}
