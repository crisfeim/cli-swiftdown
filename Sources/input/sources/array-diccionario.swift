import Foundation

// **Introducción**

// En Swift, los arrays y diccionarios son herramientas fundamentales para organizar datos.
// Mientras que los diccionarios ofrecen ergonomía para acceder y modificar elementos por clave, 
// los arrays son el tipo más común en aplicaciones que recuperan datos de apis remotas o
// soluciones de almacenamiento locales.

// En este artículo exploraremos cómo mejorar la manipulación de arrays utilizando subscripts
// personalizados para obtener la simplicidad de un diccionario.

// **Manipulación de diccionarios**

// En Swift, manipular los datos de un diccionario es bastante fácil,
// por ejemplo, si tuvieramos un modelo como este:

struct Model {
    let id: Int 
    var name: String?
}

// Y un diccionario cuyas claves fuesen del mismo tipo  que el `id`
// de ese modelo:

var dict = [Int: Model]()

// Podríamos realizar acciones CRUD de una manera muy sencilla:

/***C:***/ dict[1] = Model(id: 1, name: "Some name")
/***R:***/ _ = dict[1] 
/***U:***/ dict[1]?.name = "New name"
/***D:***/ dict[1] = nil

// **Manipulación de arrays**

// Con un array, manipularíamos los datos de una manera más verbosa:

var array = [Model]()

/***C:***/ array.append(Model(id: 1, name: "Some name"))

// *(podemos leer un elemento en el array de varias maneras)*

/***R:***/ _ = array.filter { $0.id == 1 }.first
/***R:***/ _ = array[0] // *(inseguro, puede crashear)*
/***R:***/ 
if let idx = array.firstIndex(where: {$0.id == 1}) {
    _ = array[idx]
}

/***U:***/ array[0].name = "Some name" // *(inseguro)*
/***U:***/
if let idx = array.firstIndex(where: {$0.id == 1}) {
    array[idx].name = "Some name"
}

/***D:***/
if let idx = array.firstIndex(where: {$0.id == 1}) {
    array.remove(at: idx)
}

// **Usando un subscript personalizado**:

// Cómo vemos, la ergonomía de un diccionario es mucho más práctica
// y concisa, especialmente en los casos de actualización y eliminación,
// en los que que con un array necesitamos un paso previo de recuperación
// del índice del elemento a actualizar/eliminar

// Swift nos permite crear métodos `subscript` personalizados para 
// manipular colecciones.

// Gracias a esta funcionalidad, podemos obtener una api de manipulación 
// de arrays idéntica a la de un diccionario.

// El único requisito es que los elementos de nuestro array conformen al
// protocolo `Identifiable`.

// **Implementación:**

// El subscript encapsula el boilerplate de creación, lectura, actualización
// y eliminación que generalmente declaramos de forma manual con un array:

extension Array where Element: Identifiable {
    //
    // Toma come clave el id de sus elementos...
    
    subscript(id: Element.ID) -> Element? {
        //
        // ... y al igual que un diccionario, devuelve un opcional...
        
        //
        // **Lectura:**
        
        get { first { $0.id == id } }
        set(newValue) {
            //
            // **Actualización/Eliminación:**
            // Si ya existe un elemento con el mismo ID, actualizamos
            // o eliminamos en función de si el nuevo valor es nulo o no:
            //
            if let index = firstIndex(where: { $0.id == id }) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    remove(at: index)
                }
                //
                // **Creación**
                // Si no existe, simplemente lo añadimos al array:
                //
            } else if let newValue = newValue {
                append(newValue)
            }
        }
    }
}

// **Uso:**

struct Todo: Identifiable {
    let id = UUID()
    var description: String
    var isChecked = false
    
    init(_ description: String) {
        self.description = description
    }
}

final class TodoStore: ObservableObject {
    
    @Published private(set) var data = [Todo]()
    
    // *__😎 Con subscript:__*
    
    func check_1(_ id: UUID) {
        data[id]?.isChecked.toggle()
    }
    
    // *__😫 Sin subscript:__*
    
    func check_2(_ id: UUID) {
        if let index = data.firstIndex(where: { $0.id == id }) {
            data[index].isChecked.toggle()
        }
    }
    
    // *__🎉 Más ejemplos:__*
    
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

final class ArraySubscriptTests {
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
    
    func assert(_ b: Bool, line: UInt = #line, function: String = #function) {
        let emoji = b ? "✅" : "❌"
        print()
    }
}

ArraySubscriptTests().run()

// **Conclusión**
//
// Este pequeño snippet permite obtener varias ventajas, entre ellas:
// •	Reducción del código repetitivo: Elimina la necesidad de buscar índices manualmente para operaciones comunes.
// •	Ergonomía: Ofrece una API similar a un diccionario.
// •	Flexibilidad: Combina lo mejor de ambas estructuras de datos.