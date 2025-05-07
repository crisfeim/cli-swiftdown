import Foundation

// **Introduction**

// In Swift, arrays and dictionaries are fundamental tools for data
// manipulation.

// While dictionaries offer ergonomic access and modification via keys, 
// arrays are the most common type in applications retrieving data 
// from remote APIs or local storage solutions.

// In this article, we will explore array manipulation enhancing using custom
// subscripts to achieve dictionnary ergonomics.

// **Dictionary Manipulation**

// In Swift, manipulating dictionary data is pretty straightforward. 

// For example, if we have a model like this:

struct Model {
    let id: Int 
    var name: String?
}

// And a dictionary whose keys match the `id` type of that model:

var dict = [Int: Model]()

// We can perform "CRUD" operations quite easily:

// ***Note**: While this example uses the term "CRUD" *
// *(Create, Read, Update, Delete), it's applied here more conceptually*
// *rather than in its traditional database context.*

/***C:***/ dict[1] = Model(id: 1, name: "Some name")
/***R:***/ _ = dict[1] 
/***U:***/ dict[1]?.name = "New name"
/***D:***/ dict[1] = nil

// **Array Manipulation**

// With an array, manipulating the data is more verbose:

var array = [Model]()

/***C:***/ array.append(Model(id: 1, name: "Some name"))
/***R:***/ _ = array.filter { $0.id == 1 }.first
/***R:***/ 
if let idx = array.firstIndex(where: { $0.id == 1 }) {
    _ = array[idx]
}

/***U:***/
if let idx = array.firstIndex(where: { $0.id == 1 }) {
    array[idx].name = "Some name"
}

/***D:***/
if let idx = array.firstIndex(where: { $0.id == 1 }) {
    array.remove(at: idx)
}

// **Using a Custom Subscript**

// As we can see, the ergonomics of a dictionary are much more practical 
// and concise, especially in update and delete cases, 
// where with an array, we need a preliminary step to retrieve the index 
// of the element to update/delete.

// Swift allows us to create custom `subscript` methods for 
// manipulating collections.

// With this functionality, we can achieve an array manipulation API 
// identical to that of a dictionary.

// The only requirement is that the elements of our array conform to the 
// `Identifiable` protocol.

// **Implementation**

// The subscript encapsulates the boilerplate that we usually
// manually declare when performing crud operations against an array:

extension Array where Element: Identifiable {
    //
    // It uses the element IDs as keys...
    
    subscript(id: Element.ID) -> Element? {
        //
        // ... and just like a dictionary, returns an optional...
        
        get { first { $0.id == id } }
        set(newValue) {
            
            // **Create/Update/Delete**:
            
            if let index = firstIndex(where: { $0.id == id }) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    remove(at: index)
                }
            } else if let newValue = newValue {
                append(newValue)
            }
        }
    }
}

// **Usage:**

struct Todo: Identifiable {
    let id = UUID()
    var description: String
    var isChecked = false
}

final class TodoStore: ObservableObject {
    
    @Published private(set) var data = [Todo]()
    
    // *__😎 With subscript:__*
    
    func check_1(_ id: UUID) {
        data[id]?.isChecked.toggle()
    }
    
    // *__😫 Without subscript:__*
    
    func check_2(_ id: UUID) {
        if let index = data.firstIndex(where: { $0.id == id }) {
            data[index].isChecked.toggle()
        }
    }
    
    // *__🎉 More examples:__*
    
    func upsert(item: Todo) {
        data[item.id] = item
    }
    
    func read(id: UUID) -> Todo? {
        data[id]
    }
    
    func delete(id: UUID) {
        data[id] = nil
    }
}


// **Conclusion**
//
// This small snippet offers several advantages, including:
// •	Reduction of repetitive code: Removes the need to manually search for indices in common operations.
// •	Ergonomics: Provides an API similar to a dictionary.
// •	Flexibility: Combines the best of both data structures.


// **Tests**

// Run with `alt`+ `R` 😉

final class Tests {
    struct User: Identifiable, Equatable {
        var id = UUID()
        var firstName: String
        var lastName: String
    }
    
    func test_create() {
        let user = User(firstName: "Cristian", lastName: "Patiño")
        var sut = [User]()
        sut[user.id] = user
        assert(sut[user.id]?.firstName == "Cristian")
    }
    
    func test_update() {
        var user = User(firstName: "Cristian", lastName: "Patiño")
        var sut = [User]()
        sut[user.id] = user
        
        // Update
        user.firstName = "Cristian Felipe"
        sut[user.id] = user
        
        assert(sut[user.id]?.firstName == "Cristian Felipe")
    }
    
    func test_delete() {
        let user = User(firstName: "Cristian", lastName: "Patiño")
        var sut = [User]()
        sut[user.id] = user
        assert(sut[user.id] != nil)
        sut[user.id] = nil
        assert(sut[user.id] == nil)
    }
    
    func run() {
        test_create()
        test_update()
        test_delete()
    }
    
    func assert(
        _ b: Bool,
        line: UInt = #line,
        function: String = #function
    ) {
        let emoji = b ? "✅" : "❌"
        print(line, emoji + " " + function)
    }
}

Tests().run()