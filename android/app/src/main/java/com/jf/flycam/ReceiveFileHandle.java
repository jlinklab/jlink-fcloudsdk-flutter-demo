package com.jf.flycam;

import com.lib.xcloud_flutter.media.QueuingEventSink;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;

/**
 * 接收分享文件结果事件通道
 * 原生拦截到第三方 App 分享的固件文件后，通过 EventChannel 将结果码
 * 通知 Flutter 层（0 成功，负数错误码）。
 * 使用 SDK 提供的 QueuingEventSink 缓冲事件，Flutter 层监听尚未建立时
 * 结果码也不会丢失（冷启动分享场景）。
 */
public class ReceiveFileHandle {

    // 不支持该分享方式（如 file scheme）
    public static final int NOT_SUPPORT = -1;

    // 解析源文件失败或复制失败
    public static final int NEED_OPEN_APP = -2;

    // 无文件读取权限
    public static final int NO_PERMISSION = -3;

    // 文件类型不合法（非 .bin/.img）
    public static final int NOT_SUPPORT_TYPE = -4;

    private final QueuingEventSink eventSink = new QueuingEventSink();

    public void initEventChannel(FlutterEngine flutterEngine) {
        EventChannel eventChannel = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),
                "app/receive_file_channel");
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink.setDelegate(events);
            }

            @Override
            public void onCancel(Object arguments) {
                eventSink.setDelegate(null);
            }
        });
    }

    public void success() {
        eventSink.success(0);
    }

    public void error(int code) {
        eventSink.success(code);
    }
}
