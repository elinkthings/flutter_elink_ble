import 'package:flutter/material.dart';

/// Android 指令发送失败重发次数设置控件。
class AndroidResendCountSetting extends StatelessWidget {
  /// 创建 Android 指令发送失败重发次数设置控件。
  const AndroidResendCountSetting({
    super.key,
    required this.resendCount,
    required this.onChanged,
    this.enabled = true,
  });

  /// 当前重发次数，0 表示关闭。
  final int resendCount;

  /// 重发次数变更回调。
  final ValueChanged<int> onChanged;

  /// 控件是否可操作。
  final bool enabled;

  /// 构建 Android 指令发送失败重发次数设置控件。
  @override
  Widget build(BuildContext context) {
    final currentCount = resendCount;
    final subtitle = currentCount == 0 ? 'Off' : 'Retry $currentCount times';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.replay),
      title: const Text('Android Resend Count'),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.outlined(
            tooltip: 'Decrease',
            onPressed: enabled && currentCount > 0
                ? () => onChanged(currentCount - 1)
                : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$currentCount',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton.outlined(
            tooltip: 'Increase',
            onPressed: enabled ? () => onChanged(currentCount + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
