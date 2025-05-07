import Foundation
import ObjectiveC.runtime

/*
The most costly *mistake* growing **companies** make is over-investing 
in  "top of funnel" metrics like lead acquisition and product 
sign-ups, before they ensure their product and messaging connect
with what motivates their customers.

The inevitable result: massive amounts of time and money wasted 
not just on acquiring users that are a poor fit, but also on users
that are actually the perfect fit — but they either don’t convert,
or churn later on in the lifecycle, because they’re never shown how
the product adds to their lives in a way that speaks to them.

Instead of having a ViewModel, Presenter, etc... we may want to have 
an UI agnostic object that owns control (owns and manipulates state)

ViewControllers can conform to it so we don't need view bindings as 
they inherit directly the state.

This allows us to:

1. Put control inside a package or framework that runs in macOS/linux
2. Greatly improve test speed as tests don't need a simulator
2. Allow code reusability between platforms
3. Completely eliminate binding boilerplate */



enum LoginState {
    case idle
    case loading
    case success(User)
    case error(String)
}

struct User { let id: UUID }

protocol LoginClient {
    
    func login(
        _ email: String,
        _ password: String, 
        completion: @escaping (LoginState) -> Void
    )
}

typealias MainAsyncScheduler = (@escaping () -> Void) -> Void

protocol LoginController: AnyObject, LoginValidator {
    // 
    // States:
    // Computed vars from UI fields
    // ex.: var email: String { emailTf.txt ?? "" }
    
    var email: String {get}
    var password: String {get}
    var state: LoginState {get set}
    
    var client: LoginClient? {get set}
}

extension LoginController {
    func didTapLoginButton() {
        do {
            guard email.isEmpty else {
                state = .error("Email shouldn't be empty")
                return
            }
            
            guard password.isEmpty else {
                state = .error("Password shouldn't be empty")
                return
            }
            
            try validate(email: email)
            try validate(password: password)
            
            client?.login(email, password) { [weak self] in 
                self?.state = $0 
            }
            
        } catch {
            state = .error(error.message)
        }
    }
}

protocol LoginValidator {}
struct LoginValidatorError: Error {
    let message: String
}

extension LoginValidator {
    func validate(email: String) throws(LoginValidatorError) {}
    func validate(password: String) throws(LoginValidatorError) {}
}

protocol LoginViewController: LoginController, StoredPropertyInjectable {
    var mainAsync: MainAsyncScheduler {get}
    func updateUI()
}

fileprivate var loginViewControllerStateKey = UnsafeRawPointer(bitPattern: 1)!
fileprivate var loginViewControllerMainAsyncKey = UnsafeRawPointer(bitPattern: 1)!
extension DispatchQueue {
    static let mainAsync: MainAsyncScheduler = { block in 
        DispatchQueue.main.async { block() }
    }
}

extension LoginViewController {
    func dispatchToMainIfNeeded(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() }
        else { mainAsync(block) }
    }
    //
    /// Default implementation so we automatically call `updateUI`
    /// on main queue. Not that important, really.:
    
    var state: LoginState {
        get { get(key: &loginViewControllerStateKey) ?? .idle }
        set { 
            set(newValue, key: &loginViewControllerStateKey)
            dispatchToMainIfNeeded(updateUI)
        }
    }
}

/// The pointer address of this variable acts as a key (no the value):

fileprivate var lockKey = UnsafeRawPointer(bitPattern: 1)!
protocol StoredPropertyInjectable {}
extension StoredPropertyInjectable {
    
    // Use one lock per instance:
    
    fileprivate var _instanceLock: NSLock {
        if let lock = objc_getAssociatedObject(self, &lockKey) as? NSLock {
            return lock
        } else {
            let lock = NSLock()
            objc_setAssociatedObject(self, &lockKey, lock, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return lock
        }
    }
    
    func get<T>(key: inout UnsafeRawPointer) -> T? {
        _instanceLock.lock()
        defer { _instanceLock.unlock() }
        return (objc_getAssociatedObject(self, &key) as? T)
    }
    
    func set<T>(_ newValue: T, key: inout UnsafeRawPointer) {
        _instanceLock.lock()
        defer { _instanceLock.unlock() }
        objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}


// -----------
// Test Target
// -----------

final class MockClient: LoginClient {
    let returnedState: LoginState
    init(returnedState rs: LoginState) {returnedState = rs}
    
    func login(_ email: String, _ password: String, completion: @escaping (LoginState) -> Void) {
        completion(returnedState)
    }
}

extension LoginState: Equatable {}
extension User: Equatable {}
extension LoginValidatorError: Equatable {}

final class LoginControllerImplementer: LoginController {
    var state = LoginState.idle
    var client: LoginClient?
    let mainAsync: MainAsyncScheduler
    init(client c: LoginClient) {client = c ; mainAsync = {$0()}}
    var emailField = ""
    var passwordField = ""
    var email: String {""}
    var password: String {""}
}

func test_login_success() {
    let user = User(id: UUID())
    let state = LoginState.success(user)
    let client = MockClient(returnedState: state)
    let sut = LoginControllerImplementer(client: client)
    sut.didTapLoginButton()
    assertEqual(sut.state, state)
}

func test_login_failure() {
    let state = LoginState.error("Mocked error")
    let client = MockClient(returnedState: state)
    let sut = LoginControllerImplementer(client: client)
    sut.didTapLoginButton()
    assertEqual(sut.state, state)
}

func runTests() {
    test_login_success()
    test_login_failure()
}

runTests()

func assertEqual<T: Equatable>(_ first: T, _ rhs: T, line: UInt = #line, testName: String = #function) {
    let emoji = emoji(first == rhs)
    print(line.description ++ emoji ++ testName)
}

func emoji(_ condition: Bool) -> String {
    condition ? "✅" : "❌"
}

infix operator ++: AdditionPrecedence
func ++(lhs: String, rhs: String) -> String {
    lhs + " " + rhs
}