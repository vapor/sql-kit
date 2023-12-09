import SwiftDiagnostics

private let domain = "PropertyName"

enum Diagnostics: String, Error {
  case appliedTypeFail
}

extension Diagnostics: DiagnosticMessage {
  var diagnosticID: MessageID {
    MessageID(domain: domain, id: rawValue)
  }
  
  var message: String {
    switch self {
    case .appliedTypeFail:
      "This macro can be applied to a class or struct or actor"
    }
  }
  
  var severity: DiagnosticSeverity {
    switch self {
    case .appliedTypeFail:
        .error
    }
  }
}
