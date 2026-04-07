package com.jf.flycam;

import android.os.Bundle;

import androidx.annotation.Nullable;

import com.lib.xcloud_flutter.XCloudFlutterSDK;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        XCloudFlutterSDK.getInstance().setAttachActivity(this);
    }
}
