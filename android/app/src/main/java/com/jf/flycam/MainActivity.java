package com.jf.flycam;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.lib.xcloud_flutter.XCloudFlutterSDK;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

/**
 * 应用主 Activity
 * 拦截第三方 App 分享固件文件（.bin/.img）的 Intent：
 * - ACTION_VIEW + content scheme：文件管理器"打开方式"
 * - ACTION_SEND + EXTRA_STREAM：微信/QQ 等分享面板
 * 文件复制到 App 内固件接收目录后通过 EventChannel 通知 Flutter 层。
 */
public class MainActivity extends FlutterActivity {
    private static final String TAG = MainActivity.class.getSimpleName();

    private static final int PERMISSION_REQUEST_CODE = 10000;

    // 分享文件的源路径（复制到接收目录后的路径）
    private String mFileAbsolutePath;

    private final ReceiveFileHandle receiveFileHandle = new ReceiveFileHandle();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        XCloudFlutterSDK.getInstance().setAttachActivity(this);
        dealWithIntentData(getIntent());
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        // 初始化接收文件事件通道
        receiveFileHandle.initEventChannel(flutterEngine);
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        dealWithIntentData(intent);
    }

    private void dealWithIntentData(Intent intent) {
        mFileAbsolutePath = null;
        if (intent == null) {
            return;
        }
        String action = intent.getAction();
        if (Intent.ACTION_VIEW.equals(action)) {
            Uri uri = intent.getData();
            if (uri == null) {
                return;
            }
            if ("file".equalsIgnoreCase(uri.getScheme())) {
                // 弹出提示，不支持该应用分享文件到App
                Log.e(TAG, "不支持 file scheme 分享文件到App");
                receiveFileHandle.error(ReceiveFileHandle.NOT_SUPPORT);
            } else {
                mFileAbsolutePath = ReceiveFileUtils.resolveToReceiveFile(this, uri);
                checkReceivedFile();
            }
        } else if (Intent.ACTION_SEND.equals(action)) {
            Uri uri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
            // Android 10 以下读取外部存储文件需要运行时权限
            if (uri != null && "file".equalsIgnoreCase(uri.getScheme())
                    && Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                if (checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                        == PackageManager.PERMISSION_DENIED) {
                    requestPermissions(new String[] { Manifest.permission.READ_EXTERNAL_STORAGE },
                            PERMISSION_REQUEST_CODE);
                    return;
                }
            }
            mFileAbsolutePath = ReceiveFileUtils.resolveToReceiveFile(this, uri);
            checkReceivedFile();
        }
    }

    private void checkReceivedFile() {
        if (TextUtils.isEmpty(mFileAbsolutePath)) {
            // 固件分享失败，请先打开App再进行分享操作
            Log.e(TAG, "固件分享失败");
            receiveFileHandle.error(ReceiveFileHandle.NEED_OPEN_APP);
            return;
        }
        // 判断文件是否合法，.bin/.img 结尾合法
        String fileName = mFileAbsolutePath.substring(mFileAbsolutePath.lastIndexOf("/") + 1);
        if (!fileName.endsWith(".bin") && !fileName.endsWith(".img")) {
            receiveFileHandle.error(ReceiveFileHandle.NOT_SUPPORT_TYPE);
            return;
        }
        Log.e(TAG, "Receive File AbsolutePath: " + mFileAbsolutePath);
        receiveFileHandle.success();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
            @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // 授权后继续解析分享文件
                dealWithIntentData(getIntent());
            } else {
                // 没有外部存储读写权限，分享固件时使用
                receiveFileHandle.error(ReceiveFileHandle.NO_PERMISSION);
            }
        }
    }
}
