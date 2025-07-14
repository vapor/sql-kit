#if os(WASI)
@_documentation(visibility: internal) @_exported import protocol NIOCore.EventLoop
@_documentation(visibility: internal) @_exported import class NIOCore.EventLoopFuture
#else
@_documentation(visibility: internal) @_exported import protocol NIO.EventLoop
@_documentation(visibility: internal) @_exported import class NIO.EventLoopFuture
#endif
@_documentation(visibility: internal) @_exported import struct Logging.Logger
