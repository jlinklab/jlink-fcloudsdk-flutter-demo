# 快速集成

## 当前项目支持Flutter SDK 版本 3.27.5-ohos-1.0.1 https://gitcode.com/openharmony-tpc/flutter_flutter/tree/3.27.5-ohos-1.0.1

## 扫码库依赖说明

`qr_code_scanner` 的鸿蒙适配版本（openharmony-sig/fluttertpc_qr_code_scanner）存在以下限制：

- 指定 `path: ohos` 时，仅鸿蒙平台可用，Android/iOS 无法使用
- 不指定 `path` 时，鸿蒙端运行会抛出 `Unsupported operation` 异常

因此，**该库无法通过单一 pubspec 配置同时支持三端**。

如果需要适配3端需要将鸿蒙实现代码整合至Android/iOS内，实现三端统一依赖：

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

 ## 5. 获取 Flutter 项目的依赖包
```
flutter clean
flutter pub get
```

## 修改国际化文件.arb
- 执行 `dart run intl_utils:generate`