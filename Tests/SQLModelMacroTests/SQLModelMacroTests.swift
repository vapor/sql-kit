import XCTest
import MacroTesting
import SQLModelMacro

final class SQLKitTests: XCTestCase {
  func testSingleProperty() {
    assertMacro(["Model": SQLModelMacro.self]) {
      """
      @Model
      struct Person {
        var name: String
      }
      """
    } expansion: {
      """
      struct Person {
        var name: String

        public var fields: [(name: String, value: any Encodable)] {
          [("name", self.name)]
        }
      }
      
      extension Person : Modelable {
      }
      """
    }
  }
  
  func testIgnoreModelable() {
    assertMacro(["Model": SQLModelMacro.self]) {
      """
      @Model
      struct Person {
        @ModelableIgnored
        var name: String
      }
      """
    } expansion: {
      """
      struct Person {
        @ModelableIgnored
        var name: String

        public var fields: [(name: String, value: any Encodable)] {
          []
        }
      }
      
      extension Person : Modelable {
      }
      """
    }
  }
  
  func testIComputerProperty() {
    assertMacro(["Model": SQLModelMacro.self]) {
      """
      @Model
      struct Person {
        var name: String {
          "SQL"
        }
      }
      """
    } expansion: {
      """
      struct Person {
        var name: String {
          "SQL"
        }

        public var fields: [(name: String, value: any Encodable)] {
          []
        }
      }
      
      extension Person : Modelable {
      }
      """
    }
  }
  
  func testSQLMacro() {
    assertMacro(["Model": SQLModelMacro.self]) {
      """
      @Model
      struct Person {
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
      struct Person {
        var firstName: String
        var lastName: String
      
        var fullName: String { "\\(fullName) \\(lastName)" }
        
        var age: Int

        @ModelableIgnored
        var other: String

        public var fields: [(name: String, value: any Encodable)] {
          [("firstName", self.firstName), ("lastName", self.lastName), ("age", self.age)]
        }
      }
      
      extension Person : Modelable {
      }
      """
    }
  }
}
