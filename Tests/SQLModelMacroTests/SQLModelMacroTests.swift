import XCTest
import MacroTesting
import SQLModelMacro
import SwiftData

final class SQLKitTests: XCTestCase {
  func testSingleProperty() {
    assertMacro(["Model": SQLModelMacro.self]) {
      """
      @Model
      struct User {
        var name: String
      }
      """
    } expansion: {
      """
      struct User {
        var name: String

        static public let columnNames: [String] = ["name"]

        public var values: [any Encodable] {
          [self.name]
        }
      }
      
      extension User : SQLKit.Modelable {
      }
      """
    }
  }

  func testIgnoreModelable() {
    assertMacro(["Model": SQLModelMacro.self]) {
      """
      @Model
      struct User {
        @ModelableIgnored
        var name: String
      }
      """
    } expansion: {
      """
      struct User {
        @ModelableIgnored
        var name: String

        static public let columnNames: [String] = []

        public var values: [any Encodable] {
          []
        }
      }
      
      extension User : SQLKit.Modelable {
      }
      """
    }
  }

  func testIComputerProperty() {
    assertMacro(["Model": SQLModelMacro.self]) {
      """
      @Model
      struct User {
        var name: String {
          "SQL"
        }
      }
      """
    } expansion: {
      """
      struct User {
        var name: String {
          "SQL"
        }

        static public let columnNames: [String] = []

        public var values: [any Encodable] {
          []
        }
      }
      
      extension User : SQLKit.Modelable {
      }
      """
    }
  }

  func testSQLMacro() {
    assertMacro(["Model": SQLModelMacro.self]) {
      """
      @Model
      struct User {
        var firstName: String
        var lastName: String
      
        var fullName: String { "\\(fullName) \\(lastName)" }
        
        var age: Int

        @ModelableIgnored
        var other: String
      }
      """
    } expansion: {
      """
      struct User {
        var firstName: String
        var lastName: String
      
        var fullName: String { "\\(fullName) \\(lastName)" }
        
        var age: Int

        @ModelableIgnored
        var other: String

        static public let columnNames: [String] = ["firstName", "lastName", "age"]

        public var values: [any Encodable] {
          [self.firstName, self.lastName, self.age]
        }
      }
      
      extension User : SQLKit.Modelable {
      }
      """
    }
  }
}
