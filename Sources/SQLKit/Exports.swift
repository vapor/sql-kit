#if swift(>=5.8)

@_documentation(visibility: internal) @_exported import protocol NIO.EventLoop
@_documentation(visibility: internal) @_exported import class NIO.EventLoopFuture
@_documentation(visibility: internal) @_exported import struct Logging.Logger

#else

@_exported import protocol NIO.EventLoop
@_exported import class NIO.EventLoopFuture
@_exported import struct Logging.Logger

#endif
