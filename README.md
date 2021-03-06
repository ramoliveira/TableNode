# TableNode
A TableView made of SpriteKit Nodes.

[![CocoaPod Badge](https://img.shields.io/badge/CocoaPods-1.0.0-red)](https://cocoapods.org/pods/TableNode)

## CocoaPods

Add this line of code to your `.podfile`:

```ruby
pod 'TableNode'
```

For example:

```ruby
platform :ios, '13.2'

target 'teste' do
  use_frameworks!

  pod 'TableNode'

end
```

## How can you use it?

1. You must import the `TableNode`to your SKScene class.

```swift
import TableNode
```

2. Create a variable of type `TableNode`, in the instance, you should set the frame and view. Later, set it's `Delegate` and `DataSource` to self.
  
```swift
var tableNode: TableNode!
  
override func didMove(to view: SKView) {
  self.tableNode = TableNode(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height), view: self.view!)
    
  self.tableNode.delegate = self
  self.tableNode.dataSource = self
    
  self.addChild(self.tableNode)
}
```

  * If you want, and I encourage you to do so. Set some position to your `TableNode`.

```swift
var tableNode: TableNode!
  
override func didMove(to view: SKView) {
  self.tableNode = TableNode(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height), view: self.view!)
    
  self.tableNode.delegate = self
  self.tableNode.dataSource = self
  self.tableNode.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
    
  self.addChild(self.tableNode)
}
```

3. Implement the `Delegate`'s methods:

```swift
extension GameScene: TableNodeDelegate {
    func tableNode(_ tableNode: TableNode, didSelectCell: TableNodeCell, at: IndexPath) {
        print("\(String(describing: didSelectCell.name))")
    }
}
```

4. Implement the `DataSource`'s methods:

```swift
extension GameScene: TableNodeDataSource {
    func numberOfRows(inSection section: Int) -> Int {
        return array.count
    }
    
    func tableNode(_ tableNode: TableNode, rowHeight indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableNode(_ tableNode: TableNode, cellForRowAt indexPath: IndexPath) -> TableNodeCell {
        let cell = tableNode.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.addChild(nodes[indexPath.row])
        return cell
    }
}
```

5. Everything is working. 🎉

If you have any doubt about how **TableNode** works, you can get help here: [Wiki](https://github.com/ramoliveira/TableNode/wiki)

**Disclaimer:** The `TableNode` has more methods than was shown here. And I write about then on Git's Wiki. They have default implementation, and works fine in this way. But, in the future, I expect to make the `TableNode` more customable. 👍🏽
