import AILinkBleSDK
import CoreBluetooth
import Flutter
import Foundation

/// ElinkBlePlugin 的握手、广播和协议数据辅助扩展。
extension ElinkBlePlugin {
  func decryptBroadcast(_ payload: Data) -> Data {
    guard payload.count >= 20 else { return payload }
    let bytes = [UInt8](payload)
    let cid = bytes[0]
    let vid = bytes[1]
    let pid = bytes[2]
    let sum = bytes[9]
    let encrypted = payload.subdata(in: 10..<20)
    let check = [UInt8](encrypted).reduce(UInt8(0)) { partial, byte in
      partial &+ byte
    }
    guard sum == check else { return payload }
    return ELEncryptTool.broadcastDecryptTEA(encrypted, cid: cid, vid: vid, pid: pid)
  }

  func handshakePayload(from packet: Data) -> Data? {
    // SDK 握手包是完整 A6 包；用于校验/加密的是第 3~18 位 payload。
    // SDK handshake packets are A6 full packets; the encrypted payload lives at byte 3...18.
    if packet.count == 16 {
      return packet
    }
    guard packet.count >= 19 else {
      return nil
    }
    return packet.subdata(in: 3..<19)
  }

  /// 从 MethodChannel 参数中读取可选 remoteId。
  func remoteIdArgument(from arguments: Any?) -> String? {
    let remoteId = (arguments as? [String: Any])?["remoteId"] as? String
    return remoteId?.isEmpty == false ? remoteId : nil
  }

  /// 从 MethodChannel 参数中读取握手 payload，兼容旧版直接传二进制参数。
  func handshakePayloadArgument(from arguments: Any?) -> Data? {
    if let payload = arguments as? FlutterStandardTypedData {
      return payload.data
    }
    return ((arguments as? [String: Any])?["payload"] as? FlutterStandardTypedData)?.data
  }

  /// 保存握手 seed；带 remoteId 时按设备隔离，缺省时保留旧版全局行为。
  func storeHandshakeSeed(_ seed: Data?, remoteId: String?) {
    guard let seed else { return }
    if let remoteId {
      handshakeSeeds[remoteId] = seed
      return
    }
    defaultHandshakeSeed = seed
  }

  /// 获取握手 seed；优先按 remoteId 获取，缺省时使用旧版全局 seed。
  func handshakeSeed(for remoteId: String?) -> Data? {
    if let remoteId {
      return handshakeSeeds[remoteId]
    }
    return defaultHandshakeSeed
  }

  /// 清理指定设备的握手 seed。
  func clearHandshakeSeed(remoteId: String) {
    handshakeSeeds.removeValue(forKey: remoteId)
  }

  func normalizeA6ProtocolData(_ packet: Data) -> Data {
    if let payload = a6Payload(from: packet) {
      return payload
    }
    if packet.count > 1, packet.first == 0xA6, packet[packet.index(packet.startIndex, offsetBy: 1)] == 0xA6 {
      let withoutExtraHead = packet.dropFirst()
      if let payload = a6Payload(from: Data(withoutExtraHead)) {
        return payload
      }
    }
    return packet
  }

  func a6Payload(from packet: Data) -> Data? {
    guard packet.count >= 4 else {
      return nil
    }
    let bytes = [UInt8](packet)
    guard bytes.first == 0xA6, bytes.last == 0x6A else {
      return nil
    }
    let payloadLength = Int(bytes[1])
    guard packet.count == payloadLength + 4 else {
      return nil
    }
    let checksumBytes = bytes[1..<(bytes.count - 2)]
    let checksum = checksumBytes.reduce(UInt8(0)) { partial, byte in
      partial &+ byte
    }
    guard checksum == bytes[bytes.count - 2] else {
      return nil
    }
    return packet.subdata(in: 2..<(2 + payloadLength))
  }

  func remoteId(for peripheral: CBPeripheral) -> String {
    peripheral.identifier.uuidString
  }

  /// 获取已就绪的 iOS 连接 session；未就绪时同时返回 MethodChannel 错误并发出事件。
  func requireReadySession(
    remoteId: String
  ) -> (session: ElinkIosDeviceSession?, error: FlutterError?) {
    guard let session = deviceSessions[remoteId], session.connectionReady else {
      return (nil, deviceNotConnectedError(remoteId: remoteId))
    }
    return (session, nil)
  }

  /// 构建设备未连接错误，并同步发出 EventChannel 错误事件。
  func deviceNotConnectedError(remoteId: String) -> FlutterError {
    let code = "device_not_connected"
    let message = "Device is not connected: \(remoteId)"
    emitError(code: code, message: message)
    return FlutterError(code: code, message: message, details: nil)
  }
}
