/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { AbilityConstant, Want } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { ReceiveFilePlugin } from '../plugins/ReceiveFilePlugin';
import { FileUtils } from '../utils/FileUtils';

export default class EntryAbility extends FlutterAbility {
  private receiveFilePlugin: ReceiveFilePlugin = new ReceiveFilePlugin()

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    super.onCreate(want, launchParam);
    // 冷启动拦截系统分享的文件
    this.handleFileShare(want);
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    super.onNewWant(want, launchParams);
    // 热启动拦截系统分享的文件
    this.handleFileShare(want);
  }

  /**
   * 处理系统分享面板传入的固件文件：
   * 校验 .bin/.img 后复制到 App 内固件接收目录，并通知 Flutter 层
   */
  handleFileShare(want: Want) {
    systemShare.getSharedData(want).then((data: systemShare.SharedData) => {
      let records: systemShare.SharedRecord[] = data.getRecords();
      records.forEach(async (record: systemShare.SharedRecord) => {
        if (!record.uri) {
          this.receiveFilePlugin.error(-2)
          return
        }
        console.log('接收文件' + record.uri);
        if (!record.uri.endsWith('.bin') && !record.uri.endsWith('.img')) {
          this.receiveFilePlugin.error(-4)
          return
        }
        try {
          FileUtils.handleSharedFile(this.context, record.uri)
          this.receiveFilePlugin.success()
        } catch (e) {
          this.receiveFilePlugin.error(-2)
        }
      });
    })
  }

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    // 初始化接收文件事件通道
    this.receiveFilePlugin.initEventChannel(flutterEngine);
  }
}
