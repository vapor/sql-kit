import Foundation
import Logging
import SQLKit
import Testing

func expectSerialization(
    of queryBuilder: @autoclosure () throws -> some SQLQueryBuilder,
    is serialization: @autoclosure() throws -> String,
    comment: Comment? = nil,
    sourceLocation: SourceLocation = #_sourceLocation
) throws {
    #expect(try queryBuilder().simpleSerialize() == serialization(), comment, sourceLocation: sourceLocation)
}

func expectEncoding(
    _ model: @autoclosure() throws -> any Encodable,
    using encoder: @autoclosure () throws -> SQLQueryEncoder,
    outputs columns: @autoclosure () throws -> [String],
    _ values: @autoclosure () throws -> [any SQLExpression],
    comment: Comment? = nil,
    sourceLocation: SourceLocation = #_sourceLocation
) throws {
    let columns = try columns()
    let values = try values()
    let model = try model()
    let encoder = try encoder()
    let encodedData = try encoder.encode(model)
    let encodedColumns = encodedData.map(\.0), encodedValues = encodedData.map(\.1)

    #expect(columns == encodedColumns, comment, sourceLocation: sourceLocation)
    #expect(values.count == encodedValues.count, comment, sourceLocation: sourceLocation)
    for (value, encValue) in zip(values, encodedValues) {
        switch (value, encValue) {
        case (let value as SQLLiteral, let encValue as SQLLiteral): #expect(value == encValue, comment, sourceLocation: sourceLocation)
        case (let value as SQLBind, let encValue as SQLBind):       #expect(value == encValue, comment, sourceLocation: sourceLocation)
        case (let value as TestEncExpr.Enm, let encValue as TestEncExpr.Enm): #expect(value == encValue, comment, sourceLocation: sourceLocation)
        default: Issue.record("Unexpected output (expected \(String(reflecting: value)), got \(String(reflecting: encValue))) \(comment)", sourceLocation: sourceLocation)
        }
    }
}

func expectDecoding<D: Decodable & Sendable & Equatable>(
    _: D.Type,
    from row: @autoclosure () throws -> some SQLRow,
    using decoder: @autoclosure () throws -> SQLRowDecoder,
    outputs model: @autoclosure () throws -> D,
    comment: Comment? = nil,
    sourceLocation: SourceLocation = #_sourceLocation
) throws {
    let row = try row()
    let decoder = try decoder()
    let model = try model()
    let decodedModel = try decoder.decode(D.self, from: row)

    #expect(model == decodedModel, comment, sourceLocation: sourceLocation)
}

let isLoggingConfigured: Bool = {
    LoggingSystem.bootstrap { label in
        var handler = ModifiedStreamLogHandler.standardOutput(label: label)

        handler.logLevel = ProcessInfo.processInfo.environment["LOG_LEVEL"].flatMap(Logger.Level.init(rawValue:)) ?? .info
        return handler
    }
    return true
}()

struct ModifiedStreamLogHandler: LogHandler {
    static func standardOutput(label: String) -> Self { .init(label: label) }
    let label: String
    var logLevel: Logger.Level = .info, metadataProvider = LoggingSystem.metadataProvider, metadata = Logger.Metadata()
    subscript(metadataKey key: String) -> Logger.Metadata.Value? { get { self.metadata[key] } set { self.metadata[key] = newValue } }
    func log(event: LogEvent) {
        print("\(self.timestamp()) \(event.level) \(self.label) :\(self.prepMetadata(event.metadata).map { " \($0)" } ?? "") [\(event.source)] \(event.message)")
    }
    func prepMetadata(_ explicit: Logger.Metadata?) -> String? { self.prettify(self.metadata.merging(self.metadataProvider?.get() ?? [:]) { $1 }.merging(explicit ?? [:]) { $1 }) }
    func prettify(_ metadata: Logger.Metadata) -> String? { metadata.isEmpty ? nil : metadata.lazy.sorted { $0.0 < $1.0 }.map { "\($0)=\($1.prettyDescription)" }.joined(separator: " ") }
    private func timestamp() -> String { .init(unsafeUninitializedCapacity: 255) { buffer in
        var timestamp = time(nil), tm = tm()
        guard let localTime = localtime_r(&timestamp, &tm) else { return buffer.initialize(fromContentsOf: "<unknown>".utf8) }
        return strftime(buffer.baseAddress!, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
    } }
}
extension Logger.MetadataValue {
    var prettyDescription: String {
        switch self {
        case .dictionary(let dict): "[\(dict.mapValues(\.prettyDescription).lazy.sorted { $0.0 < $1.0 }.map { "\($0): \($1)" }.joined(separator: ", "))]"
        case .array(let list): "[\(list.map(\.prettyDescription).joined(separator: ", "))]"
        case .string(let str): #""\#(str)""#
        case .stringConvertible(let repr):
            switch repr {
            case let repr as Bool: "\(repr)"
            case let repr as any FixedWidthInteger: "\(repr)"
            case let repr as any BinaryFloatingPoint: "\(repr)"
            default: #""\#(repr.description)""#
            }
        }
    }
}
