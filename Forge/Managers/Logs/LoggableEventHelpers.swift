//
//  LoggableEventHelpers.swift
//  Forge
//
//  Default implementations for LoggableEvent to reduce boilerplate.
//

// MARK: - Default Implementations

/// These default implementations reduce boilerplate in Event enums.
/// Only override `parameters` when you have actual parameters to pass.
/// Only override `type` when you need something other than `.analytic`.
extension LoggableEvent {

    /// Default to nil parameters - override only when needed
    var parameters: [String: Any]? { nil }

    /// Default to analytic type - override for errors (.severe) or other types
    var type: LogType { .analytic }
}

// MARK: - Usage Example
/*
 BEFORE (verbose - every property required):

 enum Event: LoggableEvent {
     case onAppear(delegate: HomeDelegate)
     case buttonTapped
     case errorOccurred(error: Error)

     var eventName: String {
         switch self {
         case .onAppear: return "HomeView_Appear"
         case .buttonTapped: return "HomeView_ButtonTapped"
         case .errorOccurred: return "HomeView_Error"
         }
     }

     var parameters: [String: Any]? {
         switch self {
         case .onAppear(let delegate):
             return delegate.eventParameters
         case .errorOccurred(let error):
             return error.eventParameters
         default:
             return nil  // Most cases return nil
         }
     }

     var type: LogType {
         switch self {
         case .errorOccurred:
             return .severe
         default:
             return .analytic  // Most cases return .analytic
         }
     }
 }

 AFTER (concise - only override when needed):

 enum Event: LoggableEvent {
     case onAppear(delegate: HomeDelegate)
     case buttonTapped
     case errorOccurred(error: Error)

     var eventName: String {
         switch self {
         case .onAppear: return "HomeView_Appear"
         case .buttonTapped: return "HomeView_ButtonTapped"
         case .errorOccurred: return "HomeView_Error"
         }
     }

     // Only override parameters for cases that have them
     var parameters: [String: Any]? {
         switch self {
         case .onAppear(let delegate): return delegate.eventParameters
         case .errorOccurred(let error): return error.eventParameters
         default: return nil
         }
     }

     // Only override type for non-analytic events
     var type: LogType {
         switch self {
         case .errorOccurred: return .severe
         default: return .analytic
         }
     }
 }

 // Or even simpler for screens with no parameters and no errors:

 enum Event: LoggableEvent {
     case onAppear
     case buttonTapped
     case itemSelected

     var eventName: String {
         switch self {
         case .onAppear: return "SimpleView_Appear"
         case .buttonTapped: return "SimpleView_ButtonTapped"
         case .itemSelected: return "SimpleView_ItemSelected"
         }
     }
     // parameters and type use defaults - no need to implement!
 }
 */
