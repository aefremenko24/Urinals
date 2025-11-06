import SpriteKit

class GameScene: SKScene {
    
    // Circle properties
    enum CircleColor {
        case red, yellow
        
        func toSKColor() -> SKColor {
            switch self {
                case .red: return .red
                case .yellow: return .yellow
            }
        }
    }
    
    enum CircleSize {
        case small, big
        
        func radius() -> CGFloat {
            switch self {
                case .small: return 25
                case .big: return 40
            }
        }
    }
    
    struct CircleProperties {
        let color: CircleColor
        let hasDot: Bool
        let size: CircleSize
    }
    
    // Game state
    private var gameObjects: [SKNode] = []
    private var dynamicSpacing: CGFloat = 100
    private var dynamicRadiusMultiplier: CGFloat = 1.0
    
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
        
        // Generate random number of circles (1-10)
        let numberOfCircles = Int.random(in: 1...10)
        print("Number of circles: \(numberOfCircles)")
        
        // Determine if squares will be added
        let hasStartSquare = Bool.random()
        let hasEndSquare = Bool.random()
        let totalObjects = numberOfCircles + (hasStartSquare ? 1 : 0) + (hasEndSquare ? 1 : 0)
        
        // Calculate dynamic sizing to fit everything on screen
        let edgePadding: CGFloat = 40 // Padding from screen edges
        let availableWidth = size.width - (2 * edgePadding)
        
        // We need (totalObjects - 1) gaps between objects
        let numberOfGaps = totalObjects - 1
        
        // Assume average circle radius is 32.5 (midpoint between small 25 and big 40)
        // Each object needs diameter space, plus spacing between
        let baseCircleRadius: CGFloat = 32.5
        let baseSquareSize: CGFloat = 50
        
        // Estimate total width needed with base sizes
        let estimatedCircleSpace = CGFloat(numberOfCircles) * (baseCircleRadius * 2)
        let estimatedSquareSpace = CGFloat((hasStartSquare ? 1 : 0) + (hasEndSquare ? 1 : 0)) * baseSquareSize
        let baseSpacing: CGFloat = 100
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
        if hasStartSquare {
            let squareSize = 50 * scaleFactor
            let square = createSquare(at: CGPoint(x: currentX + squareSize / 2, y: size.height / 2), size: squareSize)
            addChild(square)
            gameObjects.append(square)
            print("Added square at beginning at x: \(currentX)")
            currentX += squareSize + dynamicSpacing
        }
        
        // Generate circles
        for i in 0..<numberOfCircles {
            let properties = CircleProperties(
                color: Bool.random() ? .red : .yellow,
                hasDot: Bool.random(),
                size: Bool.random() ? .small : .big
            )
            
            let radius = properties.size.radius() * dynamicRadiusMultiplier
            let position = CGPoint(x: currentX + radius, y: size.height / 2)
            let circle = createCircle(with: properties, at: position, index: i)
            addChild(circle)
            gameObjects.append(circle)
            print("Added circle \(i) at position: \(position)")
            currentX += radius * 2 + dynamicSpacing
        }
        
        // Potentially add square at index 11 (after last circle)
        if hasEndSquare {
            let squareSize = 50 * scaleFactor
            let square = createSquare(at: CGPoint(x: currentX + squareSize / 2, y: size.height / 2), size: squareSize)
            addChild(square)
            gameObjects.append(square)
            print("Added square at end at x: \(currentX)")
        }
        
        print("Level generation complete. Total objects: \(gameObjects.count)")
    }
    
    func createCircle(with properties: CircleProperties, at position: CGPoint, index: Int) -> SKNode {
        let container = SKNode()
        container.position = position
        container.name = "circle_\(index)"
        
        // Create main circle with dynamic sizing
        let radius = properties.size.radius() * dynamicRadiusMultiplier
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = properties.color.toSKColor()
        circle.strokeColor = .black
        circle.lineWidth = 2 * dynamicRadiusMultiplier
        
        container.addChild(circle)
        
        // Add dot if needed
        if properties.hasDot {
            let dot = SKShapeNode(circleOfRadius: radius * 0.2)
            dot.fillColor = .black
            dot.strokeColor = .black
            container.addChild(dot)
        }
        
        return container
    }
    
    func createSquare(at position: CGPoint, size: CGFloat) -> SKNode {
        let square = SKShapeNode(rectOf: CGSize(width: size, height: size))
        square.position = position
        square.fillColor = .blue
        square.strokeColor = .black
        square.lineWidth = 2 * dynamicRadiusMultiplier
        square.name = "square"
        
        return square
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
