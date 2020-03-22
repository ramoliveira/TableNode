/*
 
MIT License

Copyright (c) 2020 Ramón Dias de Oliveira de Almeida

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 
*/

import Foundation
import SpriteKit

//MARK: - TableNode
public class TableNode: SKNode {
    //MARK: - Delegate and Data Source Atributes
    weak open var delegate   : TableNodeDelegate?
    weak open var dataSource : TableNodeDataSource? { didSet { self.reloadData() } }
    
    //MARK: - DataSource Atributes
    private var index   : IndexPath = IndexPath.init(item: 0, section: 0)
    private var rowHeight : CGFloat {
        return (dataSource?.tableNode(self, rowHeight: index))!
    }
    private var numberOfSections: Int {
        return dataSource?.numberOfSections() ?? 1
    }
    private var numberOfRows: Int {
        return (dataSource?.numberOfRows(inSection: self.numberOfSections))!
    }
    
    //MARK: - Atributes TableNode
    fileprivate var view: SKView!
    fileprivate var cells: [SKCropNode] = []
    fileprivate lazy var panGesture: UIPanGestureRecognizer! = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
    fileprivate var tableFrame: CGRect!

    //MARK: - Inits
    public init(frame: CGRect, view: SKView) {
        self.view = view
        super.init()
        self.tableFrame = frame
        self.isUserInteractionEnabled = true
        
        self.view.addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Deinit
    deinit {
        self.removeAllChildren()
        self.removeAllActions()
        self.view.removeGestureRecognizer(panGesture)
    }
    
    override public func removeFromParent() {
        super.removeFromParent()
        self.view.removeGestureRecognizer(panGesture)
    }
    
    //MARK: - Description
    public override var description: String {
        return "TableNode"
    }
    
    //MARK: - Methods
    /**
     *  Reloads the data of the table
     *
     * - parameters: none
     * - returns: void
     * - version: 0.0.3
     */
    public func reloadData() {
        removeAllChildren()
        cells.removeAll()
        
        for i in 0..<dataSource!.numberOfSections() {
            for j in 0..<dataSource!.numberOfRows(inSection: i) {
                if let item = dataSource?.tableNode(self, cellForRowAt: IndexPath(row: j, section: i)) {
                    cells.append(item)
                    self.addChild(item)
                    index.row += 1
                }
            }
            index.section += 1
        }
        
        setCellsPosition()
    }
    
    /**
     *   Gives the cell necessary to
     *
     * - parameters:
     *   - identifier: The name that will identify the cell.
     *   - indexPath: The index path that guides the cell.
     * - returns: A TableNode's Cell.
     * - version: 0.0.1
     */
    public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> TableNodeCell {
        let identifier = identifier+"\(indexPath)"
        let cell = TableNodeCell(name: identifier, index: indexPath, tableNode: self)
        return cell
    }
    
    /**
     *  Defines how the pan gesture should be handled
     *
     * - parameters:
     *    - sender: The UIPanGestureRecognizer that will be handled
     * - requires: That the UIPanGestureRecognizer was add at the view.
     * - returns: Void
     * - version: 0.0.7
     */
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            let damping = CGFloat(sender.velocity(in: self.view).y >= 500 ? 0.05 : 0.03)
            cells.forEach { $0.run(SKAction.moveBy(x: 0, y: -sender.translation(in: self.view).y * damping, duration: 0)) }
        case .ended, .cancelled, .failed:
            sender.setTranslation(.zero, in: self.view)
        default:
            return
        }
    }
    
    /**
     *  Set the Cells Position on the table
     *
     * - parameters: none
     * - returns: void
     * - version: 0.0.3
     */
    private var previousCellPosition: CGFloat!
    private func setCellsPosition() {
        guard let sections = dataSource?.numberOfSections() else { return }
        for i in 0..<sections {
            guard let rows = dataSource?.numberOfRows(inSection: i) else { return }
            for j in 0..<rows {
                if j == 0 {
                    cells[j].position.y = self.tableFrame.height * 0.4
                } else {
                    cells[j].position.y = self.previousCellPosition - self.rowHeight
                }
                self.previousCellPosition = cells[j].position.y
            }
        }
    }
}

//MARK: - Delegate Protocol
public protocol TableNodeDelegate: class {
    /**
     *  Sets a view for the TableNode
     *
     * - parameter tableNode: the TableNode
     * - parameter view: the view that will be defined for the TableNode
     * - returns: void
     * - version: 0.0.1
     */
    func tableNode(_ tableNode: TableNode, set view: SKView)
    
    /**
     *  Sets what will happen to the TableNode's cell when is selected.
     *
     * - parameter tableNode: the TableNode
     * - parameter didSelectCell: the TableNodeCell that was select
     * - parameter at: Index Path of the cell
     * - returns: void
     * - version: 0.0.1
     */
    func tableNode(_ tableNode: TableNode, didSelectCell: TableNodeCell, at: IndexPath)
}

//MARK: - Delegate's Extesion
// This is where default values of the delegate were defined.
public extension TableNodeDelegate {
    func tableNode(_ tableNode: TableNode, set view: SKView) {
        tableNode.view = view
    }
    
    func tableNode(_ tableNode: TableNode, didSelectCell: TableNodeCell, at: IndexPath) {
        print("cell selected: \(String(describing: didSelectCell.name))no:\(didSelectCell.index.row)")
    }
}

//MARK: - DataSource Protocol
public protocol TableNodeDataSource: class {
    /**
        Defines the number of rows in a Section
        - parameter section: Respective section of the row
        - returns: Number of rows
        - version: 0.0.1
     */
    func numberOfRows(inSection section: Int) -> Int
    
    /**
        Defines the number of sections in a Table
        - parameter: none
        - returns: Number of sections
        - version: 0.0.1
     */
    func numberOfSections() -> Int
    
    /**
        Defines row height in a Table
        - parameter tableNode: The table node that possesses the row.
        - parameter indexPath: Index of that row.
        - returns: Size of the row
     */
    func tableNode(_ tableNode: TableNode, rowHeight indexPath: IndexPath) -> CGFloat
    
    /**
     *  Defines the number of rows in a section of the table
     *
     * - parameter tableNode: The table node that contains the sections and rows.
     * - parameter section: The section that will be defined the number of rows.
     * - returns: The number of the rows in the section.
     * - version: 0.0.1
     */
    func tableNode(_ tableNode: TableNode, numberOfRowsInSection section: Int) -> Int
    
    /**
     *  Defines the cell that will be used by the TableNode
     *
     * - parameter tableNdoe: the TableNode that will receive the cell.
     * - parameter indexPath: the indexPath of the cell.
     * - returns: the cell that will be used by the TableNode
     * - version: 0.0.1
     */
    func tableNode(_ tableNode: TableNode, cellForRowAt indexPath: IndexPath) -> TableNodeCell
}

//MARK: - DataSource's Extesion
// This is where default values of the data source were defined.
public extension TableNodeDataSource {
    func numberOfSections() -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: TableNode, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(inSection: 1)
    }
}

//MARK: - TableNodeCell
public class TableNodeCell: SKCropNode {
    fileprivate var index: IndexPath
    fileprivate var table: TableNode?
    
    private var cellBackground: SKSpriteNode!
    
    public override var description: String {
        return "\(String(describing: self.name))\(self.index)"
    }
    
    required init(name: String, index: IndexPath, tableNode: TableNode) {
        self.index = index
        self.table = tableNode
        super.init()
        self.name = name
        self.isUserInteractionEnabled = true
        if let dataSource = table?.dataSource, let table = self.table {
            let height = dataSource.tableNode(table, rowHeight: index)
            let width = table.tableFrame.width
            let size = CGSize(width: width, height: height)
            let sprite = SKSpriteNode(color: .red, size: size)
            self.maskNode = sprite
            self.cellBackground = SKSpriteNode(color: .clear, size: CGSize(width: width, height: height))
            self.cellBackground.name = self.name
            self.cellBackground.alpha = 0.001
        }
        self.addChild(self.cellBackground)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func checkIfWasTouchedAt(touchLocation location: CGPoint) -> Bool {
        for node in nodes(at: location) {
            for child in self.children {
                if node === child {
                    return true
                }
            }
        }
        return false
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: self)
            let cell = self.checkIfWasTouchedAt(touchLocation: location) ? self : nil
            guard let table = self.table, let delegate = table.delegate, let tableNodeCell = cell else { return }
            delegate.tableNode(table, didSelectCell: tableNodeCell, at: tableNodeCell.index)
        }
    }
}
