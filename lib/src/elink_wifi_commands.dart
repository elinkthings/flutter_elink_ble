import 'dart:convert';
import 'dart:typed_data';

/// WiFi A6 command packet with a log name and the payload to send (WiFi A6 指令包，包含日志名称和实际下发 payload).
class ElinkWifiCommandPacket {
  /// Create one WiFi A6 command packet (创建一个 WiFi A6 指令包).
  const ElinkWifiCommandPacket({required this.name, required this.payload});

  /// Command log name (指令日志名称).
  final String name;

  /// A6 payload; the native SDK adds the A6 header, checksum, and tail (A6 payload，native SDK 会补充 A6 包头、校验和和包尾).
  final Uint8List payload;
}

/// WiFi A6 command builder shared by Android and iOS (WiFi A6 指令构造工具，保证 Android/iOS 共用同一套下发规则).
class ElinkWifiCommandBuilder {
  /// Prevent instantiating this utility class (禁止实例化工具类).
  const ElinkWifiCommandBuilder._();

  static const int _textChunkSize = 14;
  static const int _textMaxChunks = 127;

  /// Build the command for scanning nearby WiFi access points (构造扫描附近 WiFi 的指令).
  static List<ElinkWifiCommandPacket> scan() {
    return [
      _packet('scan', [0x80, 0x01]),
    ];
  }

  /// Build the command for querying the current WiFi state (构造查询 WiFi 当前状态的指令).
  static List<ElinkWifiCommandPacket> getCurrentState() {
    return [
      _packet('getCurrentState', [0x26]),
    ];
  }

  /// Build commands for setting target WiFi MAC/password and connecting (构造设置目标 WiFi MAC、密码并连接的指令序列).
  static List<ElinkWifiCommandPacket> configureAndConnect({
    required String macAddress,
    required String password,
  }) {
    return [
      _packet('setConnectWifiMac', _macPayload(macAddress)),
      ...setPassword(password),
      ...connect(),
    ];
  }

  /// Build commands for setting the WiFi password (构造设置 WiFi 密码的指令序列).
  static List<ElinkWifiCommandPacket> setPassword(String password) {
    return _textPackets('setPassword', 0x86, password);
  }

  /// Build the command for requesting WiFi connection (构造请求连接 WiFi 的指令).
  static List<ElinkWifiCommandPacket> connect() {
    return [
      _packet('connect', [0x88, 0x01]),
    ];
  }

  /// Build the command for requesting WiFi disconnection (构造请求断开 WiFi 的指令).
  static List<ElinkWifiCommandPacket> disconnect() {
    return [
      _packet('disconnect', [0x88, 0x00]),
    ];
  }

  /// Build the command for querying the connected WiFi SSID (构造查询当前连接 WiFi SSID 的指令).
  static List<ElinkWifiCommandPacket> getConnectedSsid() {
    return [
      _packet('getConnectedSsid', [0x94]),
    ];
  }

  /// Build the command for querying the saved WiFi password (构造查询当前保存 WiFi 密码的指令).
  static List<ElinkWifiCommandPacket> getConnectedPassword() {
    return [
      _packet('getConnectedPassword', [0x87]),
    ];
  }

  /// Build the command for querying the connected WiFi MAC (构造查询当前连接 WiFi MAC 的指令).
  static List<ElinkWifiCommandPacket> getConnectedMac() {
    return [
      _packet('getConnectedMac', [0x85]),
    ];
  }

  /// Build the command for querying the WiFi module SN (构造查询 WiFi 模块 SN 的指令).
  static List<ElinkWifiCommandPacket> getDeviceSn() {
    return [
      _packet('getDeviceSn', [0x93]),
    ];
  }

  /// Build commands for querying server host, port, and path (构造查询服务端 host、port、path 的指令序列).
  static List<ElinkWifiCommandPacket> getServerInfo() {
    return [...getServerHost(), ...getServerPort(), ...getServerPath()];
  }

  /// Build the command for querying the server host (构造查询服务端 host 的指令).
  static List<ElinkWifiCommandPacket> getServerHost() {
    return [
      _packet('getServerHost', [0x8C]),
    ];
  }

  /// Build the command for querying the server port (构造查询服务端 port 的指令).
  static List<ElinkWifiCommandPacket> getServerPort() {
    return [
      _packet('getServerPort', [0x8E]),
    ];
  }

  /// Build the command for querying the server path (构造查询服务端 path 的指令).
  static List<ElinkWifiCommandPacket> getServerPath() {
    return [
      _packet('getServerPath', [0x97]),
    ];
  }

  /// Build commands for setting server host, port, and path (构造设置服务端 host、port、path 的指令序列).
  static List<ElinkWifiCommandPacket> setServerInfo({
    required String host,
    required int port,
    required String path,
  }) {
    return [
      ..._textPackets('setServerHost', 0x8B, host),
      _packet('setServerPort', _portPayload(port)),
      ..._textPackets('setServerPath', 0x96, path),
    ];
  }

  /// Build the command for restarting the WiFi/BLE module (构造请求 WiFi/BLE 模块重启的指令).
  static List<ElinkWifiCommandPacket> restart() {
    return [
      _packet('restart', [0x21, 0x01]),
    ];
  }

  /// Build the command for resetting the WiFi/BLE module to factory data (构造请求 WiFi/BLE 模块恢复出厂设置的指令).
  static List<ElinkWifiCommandPacket> reset() {
    return [
      _packet('reset', [0x22, 0x01]),
    ];
  }

  /// Build one named command packet (构造一个带名称的指令包).
  static ElinkWifiCommandPacket _packet(String name, List<int> payload) {
    return ElinkWifiCommandPacket(
      name: name,
      payload: Uint8List.fromList(payload.map((byte) => byte & 0xff).toList()),
    );
  }

  /// Build chunked packets for a text WiFi command (构造文本类 WiFi 指令分包).
  static List<ElinkWifiCommandPacket> _textPackets(
    String name,
    int command,
    String text,
  ) {
    final bytes = utf8.encode(text);
    if (bytes.length > _textMaxChunks * _textChunkSize) {
      throw RangeError.range(
        bytes.length,
        0,
        _textMaxChunks * _textChunkSize,
        'text.length',
      );
    }
    if (bytes.isEmpty) {
      return [
        _packet(name, [command, 0x00]),
      ];
    }
    final packets = <ElinkWifiCommandPacket>[];
    var offset = 0;
    while (offset < bytes.length) {
      final end = offset + _textChunkSize < bytes.length
          ? offset + _textChunkSize
          : bytes.length;
      final hasMore = end < bytes.length;
      packets.add(
        _packet(name, [
          command,
          hasMore ? 0x01 : 0x00,
          ...bytes.sublist(offset, end),
        ]),
      );
      offset = end;
    }
    return packets;
  }

  /// Build the little-endian payload for setting WiFi MAC (构造设置 WiFi MAC 的小端序 payload).
  static List<int> _macPayload(String macAddress) {
    final hex = macAddress.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (hex.length != 12) {
      throw FormatException('Invalid WiFi MAC address', macAddress);
    }
    final bytes = <int>[];
    for (var index = 0; index < hex.length; index += 2) {
      bytes.add(int.parse(hex.substring(index, index + 2), radix: 16));
    }
    return [0x84, ...bytes.reversed];
  }

  /// Build the big-endian payload for setting server port (构造设置服务端端口的大端序 payload).
  static List<int> _portPayload(int port) {
    if (port < 0 || port > 0xffff) {
      throw RangeError.range(port, 0, 0xffff, 'port');
    }
    return [0x8D, (port >> 8) & 0xff, port & 0xff];
  }
}
