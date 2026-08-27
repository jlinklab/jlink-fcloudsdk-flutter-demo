import { EventChannel, FlutterEngine } from '@ohos/flutter_ohos';
import { EventSink } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import { QueuingEventSink } from 'fcloudsdk/src/main/ets/components/media/QueuingEventSink';

/**
 * 接收分享文件结果事件通道
 * 系统分享面板拦截到固件文件后，通过 EventChannel 将结果码通知 Flutter 层
 * （0 成功，负数错误码）。
 * 使用 SDK 提供的 QueuingEventSink 缓冲事件，Flutter 层监听尚未建立时
 * 结果码也不会丢失（冷启动分享场景）。
 */
export class ReceiveFilePlugin {
  private eventChannel?: EventChannel
  private eventSink = new QueuingEventSink()

  public initEventChannel(flutterEngine: FlutterEngine) {
    this.eventChannel = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), 'app/receive_file_channel')
    let that = this
    this.eventChannel.setStreamHandler({
      onListen: (args: Object, events: EventSink): void => {
        that.eventSink?.setDelegate(events)
      },
      onCancel: (args: Object): void => {
        that.eventSink?.setDelegate(null)
      }
    })
  }

  public success() {
    this.eventSink?.success(0)
  }

  public error(code: number) {
    this.eventSink?.success(code)
  }
}
