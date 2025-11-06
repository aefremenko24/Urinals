import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    // Override loadView to create an SKView instead of UIView
    override func loadView() {
        self.view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let skView = self.view as? SKView else {
            print("Error: view is not an SKView")
            return
        }
        
        // Debug options (optional - remove in production)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let skView = self.view as? SKView else { return }
        
        // Only create scene if it hasn't been created yet
        if skView.scene == nil {
            // Create and configure the scene with the actual view size
            let scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            
            // Present the scene
            skView.presentScene(scene)
            
            print("Scene created with size: \(skView.bounds.size)")
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
