#if swift(>=5.8)

@_documentation(visibility: internal) @_exported import protocol NIOCore.EventLoop
@_documentation(visibility: internal) @_exported import class NIOCore.EventLoopFuture
@_documentation(visibility: internal) @_exported import struct Logging.Logger

#else

@_exported import protocol NIOCore.EventLoop
@_exported import class NIOCore.EventLoopFuture
@_exported import struct Logging.Logger

#endif
