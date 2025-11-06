import SpriteKit

class GameScene: SKScene {
    enum UrinalSize {
        case small, big
        
        func radius() -> CGFloat {
            switch self {
                case .small: return 25
                case .big: return 40
            }
        }
    }
    
    struct UrinalProperties {
        var isTaken: Bool
        var isDirty: Bool
        var size: UrinalSize
    }
    
    // Game state
    private var gameObjects: [SKNode] = []
    private var dynamicSpacing: CGFloat = 100
    private var dynamicRadiusMultiplier: CGFloat = 2.0
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.95, alpha: 1.0)
        print("GameScene didMove called - scene size: \(size)")
        generateLevel()
    }
    
    func generateLevel() {
        print("Generating new level...")
        
        // Clear previous level
        gameObjects.forEach { $0.removeFromParent() }
        gameObjects.removeAll()
        
        // Generate random number of urinals (1-8)
        let numberOfUrinals = Int.random(in: 1...8)
        print("Number of circles: \(numberOfUrinals)")
        
        // Determine if stalls will be added
        let hasStartStall = Bool.random()
        let hasEndStall = Bool.random()
        let totalObjects = numberOfUrinals + (hasStartStall ? 1 : 0) + (hasEndStall ? 1 : 0)
        
        // Calculate dynamic sizing to fit everything on screen
        let edgePadding: CGFloat = 40 // Padding from screen edges
        let availableWidth = size.width - (2 * edgePadding)
        
        // We need (totalObjects - 1) gaps between objects
        let numberOfGaps = totalObjects - 1
        
        // Assume average urinal radius is 32.5 (midpoint between small 25 and big 40)
        // Each object needs diameter space, plus spacing between
        let baseUrinalSize: CGFloat = 32.5
        let baseStallSize: CGFloat = 100
        
        // Estimate total width needed with base sizes
        let estimatedCircleSpace = CGFloat(numberOfUrinals) * (baseUrinalSize * 2)
        let estimatedSquareSpace = CGFloat((hasStartStall ? 1 : 0) + (hasEndStall ? 1 : 0)) * baseStallSize
        let baseSpacing: CGFloat = 40
        let estimatedSpacingNeeded = CGFloat(numberOfGaps) * baseSpacing
        let estimatedTotalWidth = estimatedCircleSpace + estimatedSquareSpace + estimatedSpacingNeeded
        
        // Calculate scale factor to fit everything
        let scaleFactor = min(1.0, availableWidth / estimatedTotalWidth)
        
        // Apply scaling
        dynamicSpacing = baseSpacing * scaleFactor
        dynamicRadiusMultiplier = scaleFactor
        
        print("Scale factor: \(scaleFactor), Dynamic spacing: \(dynamicSpacing)")
        
        // Calculate starting position
        let totalWidth = estimatedTotalWidth * scaleFactor
        let startX = (size.width - totalWidth) / 2
        
        var currentX = startX
        
        print("Scene width: \(size.width), Total width needed: \(totalWidth), Start X: \(startX)")
        
        // Potentially add square at index 0 (before first circle)
        if hasStartStall {
            let stallSize = 100 * scaleFactor
            let stall = createStallLeft(at: CGPoint(x: currentX + stallSize / 2, y: size.height / 2), size: stallSize)
            addChild(stall)
            gameObjects.append(stall)
            print("Added stall at beginning at x: \(currentX)")
            currentX += stallSize + dynamicSpacing
        }
        
        // Generate circles
        var numTaken = 0
        var numDirty = 0
        
        for i in 0..<numberOfUrinals {
            var properties = UrinalProperties(
                isTaken: false,
                isDirty: false,
                size: Bool.random() ? .small : .big
            )
            
            if (numTaken < numberOfUrinals - 1) {
                let taken = Bool.random()
                properties.isTaken = taken
                if taken {
                    numTaken += 1
                }
            }
            if (numDirty < numberOfUrinals - 1) {
                let dirty = Bool.random()
                properties.isDirty = dirty
                if dirty {
                    numDirty += 1
                }
            }
            
            let radius = properties.size.radius() * dynamicRadiusMultiplier
            let position = CGPoint(x: currentX + radius, y: size.height / 2)
            let circle = createUrinal(with: properties, at: position, index: i)
            addChild(circle)
            gameObjects.append(circle)
            print("Added circle \(i) at position: \(position)")
            currentX += radius * 2 + dynamicSpacing
        }
        
        // Potentially add square at index 11 (after last circle)
        if hasEndStall {
            let stallSize = 100 * scaleFactor
            let stall = createStallRight(at: CGPoint(x: currentX + stallSize / 2, y: size.height / 2), size: stallSize)
            addChild(stall)
            gameObjects.append(stall)
            print("Added stall at end at x: \(currentX)")
        }
        
        print("Level generation complete. Total objects: \(gameObjects.count)")
    }
    
    func createUrinal(with properties: UrinalProperties, at position: CGPoint, index: Int) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = "circle_\(index)"
        
        let radius = properties.size.radius() * dynamicRadiusMultiplier
        
        // Use a single base circle image
        let sprite = SKSpriteNode(imageNamed: "urinal")
        sprite.size = CGSize(width: radius * 2, height: radius * 2)
        sprite.zPosition = 0
        container.addChild(sprite)
        
        if properties.isDirty && !properties.isTaken {
            let dotSprite = SKSpriteNode(imageNamed: "piss")
            dotSprite.size = CGSize(width: radius, height: radius)
            dotSprite.zPosition = 1
            container.addChild(dotSprite)
        }
        
        if properties.isTaken {
            let manSprite = SKSpriteNode(imageNamed: "man")
            manSprite.size = CGSize(width: 40 * dynamicRadiusMultiplier, height: 40 * dynamicRadiusMultiplier * 2)
            manSprite.zPosition = 2
            container.addChild(manSprite)
        }
        
        return container
    }
    
    func createStallLeft(at position: CGPoint, size: CGFloat) -> SKNode {
        let sprite = SKSpriteNode(imageNamed: "bathroom_stall_left")
        sprite.position = position
        sprite.size = CGSize(width: size, height: size)
        sprite.name = "bathroom_stall_left"
        
        return sprite
    }
    
    func createStallRight(at position: CGPoint, size: CGFloat) -> SKNode {
        let sprite = SKSpriteNode(imageNamed: "bathroom_stall_right")
        sprite.position = position
        sprite.size = CGSize(width: size, height: size)
        sprite.name = "bathroom_stall_right"
        
        return sprite
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        // Check if any circle was tapped
        for node in touchedNodes {
            if let name = node.name, name.hasPrefix("circle_") {
                // Circle tapped - generate new level
                generateLevel()
                return
            }
        }
    }
}
