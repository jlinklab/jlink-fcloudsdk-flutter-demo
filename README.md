# 快速集成

## 当前项目支持Flutter SDK 版本 3.22.1-ohos-1.0.0 https://gitcode.com/openharmony-tpc/flutter_flutter/tree/3.22.1-ohos-1.0.0

## 1. Android端快速集成
### 1.1 在/android/build.gradle中修改成自己的签名配置
```
    signingConfigs {
        debug {
            keyAlias '换成自己的'
            keyPassword '换成自己的'
            storeFile file('换成自己的.jks')
            storePassword '换成自己的'
        }

        release {
            keyAlias '换成自己的'
            keyPassword '换成自己的'
            storeFile file('换成自己的.jks')
            storePassword '换成自己的'
        }
    }
```
 
 ## 2. iOS端快速集成
### 2.1 xcode中修改Bundle Id,证书

 ## 3. ohos端快速集成
### 3.1 DevEco中修改.p12等，目前项目里用的自动签名

 ## 4. 获取appkey等信息
### 4.1 在开放平台账号获取到appkey等信息后，在项目/lib/utils/app_config.dart中修改对应平台等相关信息
https://aops.jftech.com/#/product

## 5. Ohos 切 iOS/Android 环境（项目目前环境是鸿蒙的）

### 5.1 修改 .vscode/中的 setting.json (替换成对应环境的flutter SDK路径)
```
    "dart.flutterSdkPath": "/Users/xxx/flutter_sdk/flutter_ohos/bin",
    "dart.env": {
     "PUB_CACHE": "/Users/xxx/ohflutter_cache"`
    }
```
### 5.2 执行脚本
#### 5.2.1 鸿蒙 
`dart run flutter_import_update.dart ohos`
#### 5.2.2 iOS/Android 
`dart run flutter_import_update.dart default`
#### 5.2.3 
```
flutter clean
flutter pub get
```

## 修改国际化文件.arb
- 执行 `dart run intl_utils:generate`