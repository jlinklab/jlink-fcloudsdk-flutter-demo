# 快速集成

## 当前项目支持Flutter SDK 版本 3.27.5-ohos-1.0.1 https://gitcode.com/openharmony-tpc/flutter_flutter/tree/3.27.5-ohos-1.0.1

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