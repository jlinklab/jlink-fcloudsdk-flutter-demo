// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) => "resend after ${count} seconds";

  static String m1(mail) => "will send verification code to ${mail}";

  static String m2(mail, phone) =>
      "you can choose either ${phone} or ${mail}, verification code will be sent to";

  static String m3(phone) => "will send verification code to ${phone}";

  static String m4(deviceId) => "${deviceId} Record List";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "TR_Audition": MessageLookupByLibrary.simpleMessage("Audition"),
    "TR_File_Size_Exceed_Max_Size": MessageLookupByLibrary.simpleMessage(
      "The File size exceeds the maximum limit",
    ),
    "TR_Please_Enter_Alarm_Tips": MessageLookupByLibrary.simpleMessage(
      "Please fill the warning message",
    ),
    "TR_Press_To_End_Record": MessageLookupByLibrary.simpleMessage(
      "Press to end recording",
    ),
    "TR_Press_To_Record": MessageLookupByLibrary.simpleMessage(
      "Start recording after pressing",
    ),
    "TR_Record_Prompt": MessageLookupByLibrary.simpleMessage("Record a beep"),
    "TR_Sex_Female": MessageLookupByLibrary.simpleMessage("female"),
    "TR_Sex_Male": MessageLookupByLibrary.simpleMessage("male"),
    "TR_Text_To_Voice": MessageLookupByLibrary.simpleMessage("Text to speech"),
    "TR_Upload_Prompt_Voice": MessageLookupByLibrary.simpleMessage(
      "Upload prompt tone",
    ),
    "Upload_F": MessageLookupByLibrary.simpleMessage("Uploading failed"),
    "Upload_S": MessageLookupByLibrary.simpleMessage("Uploaded successfully"),
    "accountCancel": MessageLookupByLibrary.simpleMessage(
      "Account Cancellation",
    ),
    "add": MessageLookupByLibrary.simpleMessage("ADD"),
    "addConnectDevFailed": MessageLookupByLibrary.simpleMessage(
      "Distribution network failure",
    ),
    "addDevice": MessageLookupByLibrary.simpleMessage("Add Device"),
    "alarm": MessageLookupByLibrary.simpleMessage("alarm"),
    "alarmRecording": MessageLookupByLibrary.simpleMessage("Alarm recording"),
    "alarmScreenshot": MessageLookupByLibrary.simpleMessage("Alarm screenshot"),
    "alarmSubscription": MessageLookupByLibrary.simpleMessage(
      "Alarm subscription",
    ),
    "album": MessageLookupByLibrary.simpleMessage("Album"),
    "areaCode": MessageLookupByLibrary.simpleMessage("Choose Area Code"),
    "audio_ability_unsupport": MessageLookupByLibrary.simpleMessage(
      "Microphone permission is not enabled",
    ),
    "baseStationHumanDetectionSwitch": MessageLookupByLibrary.simpleMessage(
      "Humanoid detection switch",
    ),
    "basicSetting": MessageLookupByLibrary.simpleMessage("Basic Settings"),
    "blueToothPermissionCancelTips": MessageLookupByLibrary.simpleMessage(
      "Without the permission to scan nearby Bluetooth devices, you cannot perform network configuration, search, or other operations using Bluetooth.",
    ),
    "bluetooth": MessageLookupByLibrary.simpleMessage("add via BT"),
    "cancel": MessageLookupByLibrary.simpleMessage("CancelAll"),
    "check": MessageLookupByLibrary.simpleMessage("confirm"),
    "cloudDownload": MessageLookupByLibrary.simpleMessage(
      "Cloud Storage Download",
    ),
    "cloudList": MessageLookupByLibrary.simpleMessage("Cloud Playback"),
    "cloudVideo": MessageLookupByLibrary.simpleMessage("Cloud Short Video"),
    "codeHint": MessageLookupByLibrary.simpleMessage("verification code"),
    "countDown": m0,
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "dev": MessageLookupByLibrary.simpleMessage("Device"),
    "devInfo": MessageLookupByLibrary.simpleMessage("device info"),
    "devName": MessageLookupByLibrary.simpleMessage("device name"),
    "devSN": MessageLookupByLibrary.simpleMessage("device serial No"),
    "device": MessageLookupByLibrary.simpleMessage("Device"),
    "deviceAddConnectBleSuccess": MessageLookupByLibrary.simpleMessage(
      "Connect Bluetooth device successfully!",
    ),
    "deviceAddConnectBleTip1": MessageLookupByLibrary.simpleMessage(
      "1.Connect Bluetooth device successfully!",
    ),
    "deviceAddConnectBleTip2": MessageLookupByLibrary.simpleMessage(
      "2.Start sending information to the device...",
    ),
    "deviceAddConnectBleTip3": MessageLookupByLibrary.simpleMessage(
      "2.Received the information successfully!",
    ),
    "deviceAddConnectBleTip4": MessageLookupByLibrary.simpleMessage(
      "3.Waiting for devices to connect to the router...",
    ),
    "deviceAddConnectBleTip5": MessageLookupByLibrary.simpleMessage(
      "3.The distribution network is successful!",
    ),
    "deviceAddConnectBledDisconnected": MessageLookupByLibrary.simpleMessage(
      "Bluetooth Disconnected",
    ),
    "deviceBluetoothCantConnect": MessageLookupByLibrary.simpleMessage(
      "Cannot connect to Bluetooth",
    ),
    "deviceList": MessageLookupByLibrary.simpleMessage("Device List"),
    "deviceNoMemoryCard": MessageLookupByLibrary.simpleMessage(
      "The device does not have a storage card",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Download Management"),
    "forgotPwd": MessageLookupByLibrary.simpleMessage("Forgot password"),
    "getCode": MessageLookupByLibrary.simpleMessage("GET CODE"),
    "goLogin": MessageLookupByLibrary.simpleMessage(
      "has account yet, go to login page",
    ),
    "goPhoneRegister": MessageLookupByLibrary.simpleMessage(
      "try phone register",
    ),
    "goRegister": MessageLookupByLibrary.simpleMessage(
      "do not have an account, register new one",
    ),
    "hd": MessageLookupByLibrary.simpleMessage("HD"),
    "image": MessageLookupByLibrary.simpleMessage("image"),
    "imageFlipLeftRight": MessageLookupByLibrary.simpleMessage(
      "Flip the image left and right",
    ),
    "imageFlipUpDown": MessageLookupByLibrary.simpleMessage(
      "Flip the image up and down",
    ),
    "info": MessageLookupByLibrary.simpleMessage("User Info"),
    "lanSearch": MessageLookupByLibrary.simpleMessage("add via lan"),
    "local": MessageLookupByLibrary.simpleMessage("en"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "mailHint": MessageLookupByLibrary.simpleMessage("mail"),
    "mailPhone": MessageLookupByLibrary.simpleMessage("mail/phone"),
    "mailRegister": MessageLookupByLibrary.simpleMessage("Mail Register"),
    "mailTip": m1,
    "mediaType": MessageLookupByLibrary.simpleMessage("media type"),
    "memoryCardError": MessageLookupByLibrary.simpleMessage(
      "Abnormal storage card",
    ),
    "message": MessageLookupByLibrary.simpleMessage("message"),
    "messageDetail": MessageLookupByLibrary.simpleMessage("Message Detail"),
    "messageList": MessageLookupByLibrary.simpleMessage("Message List"),
    "messageReporting": MessageLookupByLibrary.simpleMessage(
      "Message reporting",
    ),
    "mine": MessageLookupByLibrary.simpleMessage("Mine"),
    "myDevice": MessageLookupByLibrary.simpleMessage("Mine"),
    "name": MessageLookupByLibrary.simpleMessage("username"),
    "nameHint": MessageLookupByLibrary.simpleMessage("username/email/phone"),
    "newPwd": MessageLookupByLibrary.simpleMessage("new password"),
    "noDevice": MessageLookupByLibrary.simpleMessage("No Device Available"),
    "noFound": MessageLookupByLibrary.simpleMessage("No Device Search"),
    "noPhoneMailTip": MessageLookupByLibrary.simpleMessage(
      "Your account is not bound to any email or phone number. Clicking the button will directly cancel the account",
    ),
    "noSDCardTips": MessageLookupByLibrary.simpleMessage(
      "No SD card detected, can\'t record 24 hours recording.",
    ),
    "normalAlarm": MessageLookupByLibrary.simpleMessage("Normal Alarm"),
    "nothing": MessageLookupByLibrary.simpleMessage("Nothing!"),
    "on": MessageLookupByLibrary.simpleMessage("open"),
    "operator_failed": MessageLookupByLibrary.simpleMessage("Operation failed"),
    "other": MessageLookupByLibrary.simpleMessage("other setting"),
    "phone": MessageLookupByLibrary.simpleMessage("phone no"),
    "phoneMailTip": m2,
    "phoneRegister": MessageLookupByLibrary.simpleMessage("Phone Register"),
    "phoneRule": MessageLookupByLibrary.simpleMessage(
      "Overseas mobile phone numbers need to add area code. eg:+1:80998098979",
    ),
    "phoneTip": m3,
    "preview": MessageLookupByLibrary.simpleMessage("preview"),
    "privacyPermissionBluetooth": MessageLookupByLibrary.simpleMessage(
      "Bluetooth Access Permission",
    ),
    "privacyPermissionDevNearbyContent": MessageLookupByLibrary.simpleMessage(
      "Used to search for nearby Bluetooth devices or other devices",
    ),
    "pwdFindBack": MessageLookupByLibrary.simpleMessage("find back password"),
    "pwdHint": MessageLookupByLibrary.simpleMessage("password"),
    "pwdQuestion": MessageLookupByLibrary.simpleMessage(
      "set security question",
    ),
    "pwdRule": MessageLookupByLibrary.simpleMessage(
      "The password must be 8~64 characters, including uppercase/lowercase letters, numbers and special characters. Allow symbols: \'!@#%^&*()_[]{}?/.<>, \'\' ; : -\'",
    ),
    "qrScan": MessageLookupByLibrary.simpleMessage("Align The QR Code"),
    "recordAudio": MessageLookupByLibrary.simpleMessage("Audio Recording"),
    "recordClip": MessageLookupByLibrary.simpleMessage("Video Segment"),
    "recordList": m4,
    "recordMode": MessageLookupByLibrary.simpleMessage("REC Button"),
    "recordQuality": MessageLookupByLibrary.simpleMessage("Recording Quality"),
    "recordQualityBad": MessageLookupByLibrary.simpleMessage("Relatively Poor"),
    "recordQualityBestGood": MessageLookupByLibrary.simpleMessage("Best"),
    "recordQualityGood": MessageLookupByLibrary.simpleMessage("Good"),
    "recordQualityNormal": MessageLookupByLibrary.simpleMessage("General"),
    "recordQualityVeryBad": MessageLookupByLibrary.simpleMessage("Poor"),
    "recordQualityVeryGood": MessageLookupByLibrary.simpleMessage("Better"),
    "recordSetting": MessageLookupByLibrary.simpleMessage(
      "Video recording settings",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetDevPwd": MessageLookupByLibrary.simpleMessage(
      "reset device password",
    ),
    "resetPwd": MessageLookupByLibrary.simpleMessage("Reset Password"),
    "restartScan": MessageLookupByLibrary.simpleMessage("restart scan"),
    "routeSetting": MessageLookupByLibrary.simpleMessage("Route Setting"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "sd": MessageLookupByLibrary.simpleMessage("SD"),
    "sdList": MessageLookupByLibrary.simpleMessage("Card Storage Album"),
    "sdkVersion": MessageLookupByLibrary.simpleMessage("Current SDK version"),
    "selectAll": MessageLookupByLibrary.simpleMessage("SelectAll"),
    "setting": MessageLookupByLibrary.simpleMessage("Setting"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "shareDevice": MessageLookupByLibrary.simpleMessage("Share"),
    "smsLogin": MessageLookupByLibrary.simpleMessage("SmsLogin"),
    "startAdd": MessageLookupByLibrary.simpleMessage("start distribute"),
    "startScan": MessageLookupByLibrary.simpleMessage("start scan"),
    "stopScan": MessageLookupByLibrary.simpleMessage("stop scan"),
    "storageManagement": MessageLookupByLibrary.simpleMessage(
      "storage management",
    ),
    "toolsFeedbackLog": MessageLookupByLibrary.simpleMessage("Feedback Log"),
    "tr_common_download_management": MessageLookupByLibrary.simpleMessage(
      "Download management",
    ),
    "tr_pet_function_record_start": MessageLookupByLibrary.simpleMessage(
      "Click to Start Recording",
    ),
    "tr_pet_function_recording_state": MessageLookupByLibrary.simpleMessage(
      "Recording in progress. Click again to stop recording.",
    ),
    "tr_pet_setting_sound_record_function":
        MessageLookupByLibrary.simpleMessage("Record summoning sound"),
    "tr_recording": MessageLookupByLibrary.simpleMessage("Recording..."),
    "tr_settings_alarm_beep": MessageLookupByLibrary.simpleMessage(
      "Device alarm beep",
    ),
    "tr_settings_alarm_bell_customize": MessageLookupByLibrary.simpleMessage(
      "Custom voice",
    ),
    "tr_settings_alarm_bell_select": MessageLookupByLibrary.simpleMessage(
      "Device bell selection",
    ),
    "verCodeLogin": MessageLookupByLibrary.simpleMessage(
      "Verification code login",
    ),
    "version": MessageLookupByLibrary.simpleMessage("Version"),
    "video": MessageLookupByLibrary.simpleMessage("record"),
    "wifi": MessageLookupByLibrary.simpleMessage("add via wifi"),
    "wifiPwdHint": MessageLookupByLibrary.simpleMessage("Wifi Password"),
  };
}
