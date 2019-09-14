import Foundation
import SwiftUI

// MARK: - Our model
struct Todo: Identifiable, Hashable {
  let id = UUID()
  var isDone = false
}

// MARK: - ObservableObject so we can get a Binding for our .isDone Bool
final class Storage: ObservableObject {
  @Published var todos = [Todo]()
}

struct TodosView: View {
  @EnvironmentObject var storage: Storage
  
  var body: some View {
    List {
      // MARK: - Header (Add/Remove Buttons)
      HStack {
        Button(action: {
          self.storage.todos.insert(Todo(), at: 0)
        }, label: {Text("Add Item")})
        Button(action: {
          _ = self.storage.todos.popLast()
        }, label: {Text("Remove Last Item")})
      }
      
      // MARK: - List of todos
      ForEach(storage.todos.indexed(), id: \.1.id) { index, _ in
        HStack {
          Text("\(index)")
          Divider()
          Text("\(self.storage.todos[index].id.description)")
          Divider()
          Toggle(isOn: self.$storage.todos[index].isDone, label: {
            Text("Is Done: ")
          })
            // MARK: - SwitchToggleStyle crashes at runtime
            .toggleStyle(SwitchToggleStyle())
          // MARK: - DefaultToggleStyle/CheckboxToggleStyle works
            // .toggleStyle(DefaultToggleStyle())
        }
      }
    }
  }
}

struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
  typealias Index = Base.Index
  typealias Element = (index: Index, element: Base.Element)
  
  let base: Base
  
  var startIndex: Index { base.startIndex }
  
  var endIndex: Index { base.endIndex }
  
  func index(after i: Index) -> Index {
    base.index(after: i)
  }
  
  func index(before i: Index) -> Index {
    base.index(before: i)
  }
  
  func index(_ i: Index, offsetBy distance: Int) -> Index {
    base.index(i, offsetBy: distance)
  }
  
  subscript(position: Index) -> Element {
    (index: position, element: base[position])
  }
}

extension RandomAccessCollection {
  func indexed() -> IndexedCollection<Self> {
    IndexedCollection(base: self)
  }
}
