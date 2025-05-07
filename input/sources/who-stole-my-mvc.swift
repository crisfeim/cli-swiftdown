import Foundation

// As x(@todo) said:

// > *The MVC is the pattern that iOS developpers love to hate.*

// What is a ViewModel ?

// As Kanlou said: a very confusing pattern
// From one side you have the models that drive the view
// From the other side, you have an object that retrieves data
// and pass it to the view

// The MV* family design patterns aim to solve
// the Massive View Controller problem, yet
// do they?

// Let's take a common example: a list fetched items that navigate to the
// detail.

// For the sake of the example, lets say the domain
// is a recipes app.

import AppKit 

// For this example will be using AppKit

// This would be a terrible implementation

final class RecipeListViewController_1: NSViewController {
	
	struct Recipes {}
	var items: [Recipes]?
}

@frozen public enum Axis2D {
	case horizontal
	case vertical
}

let axis = Axis2D.horizontal
switch axis {
	default: break
}

print("hello world testing")