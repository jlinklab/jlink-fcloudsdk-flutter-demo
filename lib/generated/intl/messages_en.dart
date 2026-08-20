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

  static String m0(param0, param1) =>
      "Show ${param0} frames in ${param1} seconds.";

  static String m1(param0, param1, param2) =>
      "AOV Frame Rate ${param0}, AOV Alarm Interval ${param1}, Maximum Event Recording Duration ${param2}";

  static String m2(param0) =>
      "AOV frame rate is ${param0}fps, with card recording";

  static String m3(param0) =>
      "AOV frame rate ${param0}fps, with infrared illumination and card recording";

  static String m4(param0) =>
      "Current battery level is below ${param0}. In a low battery mode, recording and alarm notifications will stop, and preview is only available through remote wake-up via app.";

  static String m5(param0, param1, param2) =>
      "AOV Frame Rate ${param0}, AOV Alarm Interval ${param1}, Maximum Event Recording Duration ${param2}, Infrared Fill Light";

  static String m6(param0) =>
      "Auto-switches to AOV mode when battery below ${param0}";

  static String m7(level, isCharging) =>
      "Battery level [${level}], charging [${isCharging}]";

  static String m8(account) => "Are you sure to cancel share to ${account}?";

  static String m9(account) => "Are you sure to share device to ${account}?";

  static String m10(count) => "resend after ${count} seconds";

  static String m11(mail) => "will send verification code to ${mail}";

  static String m12(mail, phone) =>
      "you can choose either ${phone} or ${mail}, verification code will be sent to";

  static String m13(phone) => "will send verification code to ${phone}";

  static String m14(deviceId) => "${deviceId} Record List";

  static String m15(level) => "4G signal level [${level}]";

  static String m16(level) => "WiFi signal level [${level}]";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "Done": MessageLookupByLibrary.simpleMessage("Done"),
        "Show_traces": MessageLookupByLibrary.simpleMessage("Show smart trace"),
        "TR_AOV_Alarm_interval":
            MessageLookupByLibrary.simpleMessage("AOV Alarm Interval"),
        "TR_AOV_Fps": MessageLookupByLibrary.simpleMessage("AOV frame rate"),
        "TR_AutoLight": MessageLookupByLibrary.simpleMessage("Auto Light"),
        "TR_AutoLightDetail": MessageLookupByLibrary.simpleMessage("Automatically turn lights on and off based on environment"),
        "TR_Alert_Set_Alert_Line_Tip": MessageLookupByLibrary.simpleMessage(
            "Please set the alert line, drag both ends to adjust"),
        "TR_Audition": MessageLookupByLibrary.simpleMessage("Audition"),
        "TR_Capture_Failed":
            MessageLookupByLibrary.simpleMessage("Capture failed"),
        "TR_Capture_Success":
            MessageLookupByLibrary.simpleMessage("Capture successful"),
        "TR_File_Size_Exceed_Max_Size": MessageLookupByLibrary.simpleMessage(
            "The File size exceeds the maximum limit"),
        "Bright": MessageLookupByLibrary.simpleMessage("Brightness"),
        "Double_Light_Vision": MessageLookupByLibrary.simpleMessage("Dual Light Alert"),
        "Full_Color_Vision": MessageLookupByLibrary.simpleMessage("Starlight Full Color"),
        "General_Night_Vision": MessageLookupByLibrary.simpleMessage("IR Night Vision"),
        "Intelligent_sensitivity": MessageLookupByLibrary.simpleMessage("Smart Sensitivity"),
        "TR_Intelligent_Warning_Switch":
            MessageLookupByLibrary.simpleMessage("Smart Alert Switch"),
        "TR_Keep_On": MessageLookupByLibrary.simpleMessage("Always On"),
        "TR_Light_Settings":
            MessageLookupByLibrary.simpleMessage("Light Settings"),
        "TR_LightSensitivitySubTitle": MessageLookupByLibrary.simpleMessage(""),
        "TR_Low_Light_Control":
            MessageLookupByLibrary.simpleMessage("Low light control"),
        "TR_Low_Light_Control_Tip": MessageLookupByLibrary.simpleMessage(
            "When the low-light switch is turned on, the night scene will undergo low-light supplementation in AOV mode"),
        "TR_Modify_S":
            MessageLookupByLibrary.simpleMessage("Modified successfully"),
        "TR_Night_VisionLight": MessageLookupByLibrary.simpleMessage("IR Night Vision Light"),
        "TR_PIR_Higher": MessageLookupByLibrary.simpleMessage("Higher"),
        "TR_PIR_Hightext": MessageLookupByLibrary.simpleMessage("Highest"),
        "TR_PIR_Lower": MessageLookupByLibrary.simpleMessage("Lower"),
        "TR_PIR_lowest": MessageLookupByLibrary.simpleMessage("Lowest"),
        "TR_Please_Enter_Alarm_Tips": MessageLookupByLibrary.simpleMessage(
            "Please fill the warning message"),
        "TR_Press_To_End_Record":
            MessageLookupByLibrary.simpleMessage("Press to end recording"),
        "TR_Press_To_Record": MessageLookupByLibrary.simpleMessage(
            "Start recording after pressing"),
        "TR_QR_Code_Has_Been_Used_Generate_Again":
            MessageLookupByLibrary.simpleMessage(
                "QR code has been used, please contact the device owner to regenerate"),
        "TR_Record_Prompt":
            MessageLookupByLibrary.simpleMessage("Record a beep"),
        "TR_Rule_Setting":
            MessageLookupByLibrary.simpleMessage("Smart Alert Rule"),
        "TR_Set_Aov_Fps_Tips": m0,
        "TR_Setting_4G_Network_Switching":
            MessageLookupByLibrary.simpleMessage("4G Network Switching"),
        "TR_Setting_AOV_BlackLight_Blance_Tips": m1,
        "TR_Setting_AOV_BlackLight_FPS_Description": m2,
        "TR_Setting_AOV_Device_Config":
            MessageLookupByLibrary.simpleMessage("AOV Device Settings"),
        "TR_Setting_AOV_FPS_Description": m3,
        "TR_Setting_AOV_Low_Battery_Mode_Description": m4,
        "TR_Setting_AOV_Low_Light_Human_Detected_White_Light_Color":
            MessageLookupByLibrary.simpleMessage(
                "In low light, AOV mode records in black and white, real-time view is black and white with infrared light on, and switches to color with white light when human is detected"),
        "TR_Setting_AOV_Low_Light_IR_BlackWhite":
            MessageLookupByLibrary.simpleMessage(
                "In low light, AOV mode records in black and white, real-time view is black and white with infrared light on"),
        "TR_Setting_AOV_Low_Light_White_Light_Color":
            MessageLookupByLibrary.simpleMessage(
                "In low light, AOV mode records in black and white, real-time view becomes color when white light is on"),
        "TR_Setting_AOV_Work_Mode":
            MessageLookupByLibrary.simpleMessage("AOV Mode"),
        "TR_Setting_Aov_Blance_tips": m5,
        "TR_Setting_Aov_RecordLength": MessageLookupByLibrary.simpleMessage(
            "Maximum Event Recording Duration"),
        "TR_Setting_Battery": MessageLookupByLibrary.simpleMessage("Battery"),
        "TR_Setting_BatteryThreshold":
            MessageLookupByLibrary.simpleMessage("Battery Threshold"),
        "TR_Setting_BatteryThreshold_Desc": m6,
        "TR_Setting_Battery_Management":
            MessageLookupByLibrary.simpleMessage("Battery management"),
        "TR_Setting_Battery_Statistic":
            MessageLookupByLibrary.simpleMessage("Battery statistics"),
        "TR_Setting_Current_Battery_Level":
            MessageLookupByLibrary.simpleMessage("Current battery level"),
        "TR_Setting_Device_Indicator_Light":
            MessageLookupByLibrary.simpleMessage("Device Indicator Light"),
        "TR_Setting_Last_Week":
            MessageLookupByLibrary.simpleMessage("Last week"),
        "TR_Setting_Low_Power_Mode":
            MessageLookupByLibrary.simpleMessage("Low battery mode"),
        "TR_Setting_Low_Power_Mode_Description":
            MessageLookupByLibrary.simpleMessage(
                "When the battery level falls below the set threshold, the device operating mode will automatically switch to the low-power mode."),
        "TR_Setting_Mode_Of_Work":
            MessageLookupByLibrary.simpleMessage("Working mode"),
        "TR_Setting_Number_Of_Alarms":
            MessageLookupByLibrary.simpleMessage("Number of alarms"),
        "TR_Setting_Performance":
            MessageLookupByLibrary.simpleMessage("Performance mode"),
        "TR_Setting_Power_Level":
            MessageLookupByLibrary.simpleMessage("Battery level"),
        "TR_Setting_Power_Saving_Mode":
            MessageLookupByLibrary.simpleMessage("Power Saving Mode"),
        "TR_Setting_Power_Supply_Mode":
            MessageLookupByLibrary.simpleMessage("Power supply method"),
        "TR_Setting_Preview_Time":
            MessageLookupByLibrary.simpleMessage("Preview time"),
        "TR_Setting_Signal": MessageLookupByLibrary.simpleMessage("Signal"),
        "TR_Setting_Wake_Up_Time":
            MessageLookupByLibrary.simpleMessage("Wake-up time"),
        "TR_Sex_Female": MessageLookupByLibrary.simpleMessage("female"),
        "TR_Sex_Male": MessageLookupByLibrary.simpleMessage("male"),
        "TR_Show_Traces_Tip": MessageLookupByLibrary.simpleMessage(
            "Draw a frame around the person who appears in front of the camera"),
        "TR_Text_To_Voice":
            MessageLookupByLibrary.simpleMessage("Text to speech"),
        "TR_TimingLight": MessageLookupByLibrary.simpleMessage("Timed Light"),
        "TR_TimingLightDetail": MessageLookupByLibrary.simpleMessage("Customize your light-on time"),
        "TR_Today": MessageLookupByLibrary.simpleMessage("Today"),
        "TR_Unknow": MessageLookupByLibrary.simpleMessage("Unknown"),
        "TR_Upload_Prompt_Voice":
            MessageLookupByLibrary.simpleMessage("Upload prompt tone"),
        "TR_White_Light_Switch": MessageLookupByLibrary.simpleMessage("White Light Switch"),
        "TR_Wakeup_Failed":
            MessageLookupByLibrary.simpleMessage("Wake-up failed"),
        "TR_Wakeup_In_Progress":
            MessageLookupByLibrary.simpleMessage("Waking up..."),
        "TR_Wakeup_Success":
            MessageLookupByLibrary.simpleMessage("Wake-up successful"),
        "Upload_F": MessageLookupByLibrary.simpleMessage("Uploading failed"),
        "Upload_S":
            MessageLookupByLibrary.simpleMessage("Uploaded successfully"),
        "acceptFailed":
            MessageLookupByLibrary.simpleMessage("Accept share failed"),
        "acceptShare": MessageLookupByLibrary.simpleMessage("Accept"),
        "acceptShareDevice":
            MessageLookupByLibrary.simpleMessage("Accept device share"),
        "acceptSuccess":
            MessageLookupByLibrary.simpleMessage("Accept share success"),
        "accountCancel":
            MessageLookupByLibrary.simpleMessage("Account Cancellation"),
        "add": MessageLookupByLibrary.simpleMessage("ADD"),
        "addConnectDevFailed": MessageLookupByLibrary.simpleMessage(
            "Distribution network failure"),
        "addDevice": MessageLookupByLibrary.simpleMessage("Add Device"),
        "advanced_set":
            MessageLookupByLibrary.simpleMessage("Advanced Settings"),
        "alarm": MessageLookupByLibrary.simpleMessage("alarm"),
        "alarmRecording":
            MessageLookupByLibrary.simpleMessage("Alarm recording"),
        "alarmScreenshot":
            MessageLookupByLibrary.simpleMessage("Alarm screenshot"),
        "alarmSubscription":
            MessageLookupByLibrary.simpleMessage("Alarm subscription"),
        "album": MessageLookupByLibrary.simpleMessage("Album"),
        "areaCode": MessageLookupByLibrary.simpleMessage("Choose Area Code"),
        "audio_ability_unsupport": MessageLookupByLibrary.simpleMessage(
            "Microphone permission is not enabled"),
        "baseStationHumanDetectionSwitch":
            MessageLookupByLibrary.simpleMessage("Humanoid detection switch"),
        "basicSetting": MessageLookupByLibrary.simpleMessage("Basic Settings"),
        "batteryInfo": m7,
        "blueToothPermissionCancelTips": MessageLookupByLibrary.simpleMessage(
            "Without the permission to scan nearby Bluetooth devices, you cannot perform network configuration, search, or other operations using Bluetooth."),
        "bluetooth": MessageLookupByLibrary.simpleMessage("add via BT"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelBtn": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelShare": MessageLookupByLibrary.simpleMessage("Cancel Share"),
        "cancelShareContent": m8,
        "cancelShareFailed":
            MessageLookupByLibrary.simpleMessage("Cancel share failed"),
        "cancelShareSuccess":
            MessageLookupByLibrary.simpleMessage("Cancel share success"),
        "chargingNo": MessageLookupByLibrary.simpleMessage("No"),
        "chargingYes": MessageLookupByLibrary.simpleMessage("Yes"),
        "check": MessageLookupByLibrary.simpleMessage("confirm"),
        "clickToShare": MessageLookupByLibrary.simpleMessage("Tap to share"),
        "cloudDownload":
            MessageLookupByLibrary.simpleMessage("Cloud Storage Download"),
        "cloudList": MessageLookupByLibrary.simpleMessage("Cloud Playback"),
        "cloudVideo": MessageLookupByLibrary.simpleMessage("Cloud Short Video"),
        "codeHint": MessageLookupByLibrary.simpleMessage("verification code"),
        "commonConfig": MessageLookupByLibrary.simpleMessage("Common Settings"),
        "confirmBtn": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmShare": MessageLookupByLibrary.simpleMessage("Confirm Share"),
        "confirmShareContent": m9,
        "countDown": m10,
        "customerServiceCenter":
            MessageLookupByLibrary.simpleMessage("Customer Service Center"),
        "dayNightAuto": MessageLookupByLibrary.simpleMessage("Auto Switch"),
        "dayNightAutoTip": MessageLookupByLibrary.simpleMessage(
            "Auto switch day/night mode by ambient light"),
        "dayNightDay": MessageLookupByLibrary.simpleMessage("Force Day"),
        "dayNightDayTip":
            MessageLookupByLibrary.simpleMessage("Force switch to day mode"),
        "dayNightMode":
            MessageLookupByLibrary.simpleMessage("Day/Night Switch"),
        "dayNightNight": MessageLookupByLibrary.simpleMessage("Force Night"),
        "dayNightNightTip":
            MessageLookupByLibrary.simpleMessage("Force switch to night mode"),
        "dayNightSensitivity":
            MessageLookupByLibrary.simpleMessage("Sensitivity"),
        "dayNightTiming": MessageLookupByLibrary.simpleMessage("Timing Switch"),
        "dayNightTimingTip": MessageLookupByLibrary.simpleMessage(
            "Switch by scheduled time period"),
        "days": MessageLookupByLibrary.simpleMessage("day"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "dev": MessageLookupByLibrary.simpleMessage("Device"),
        "devInfo": MessageLookupByLibrary.simpleMessage("device info"),
        "devName": MessageLookupByLibrary.simpleMessage("device name"),
        "devSN": MessageLookupByLibrary.simpleMessage("device serial No"),
        "device": MessageLookupByLibrary.simpleMessage("Device"),
        "deviceAddConnectBleSuccess": MessageLookupByLibrary.simpleMessage(
            "Connect Bluetooth device successfully!"),
        "deviceAddConnectBleTip1": MessageLookupByLibrary.simpleMessage(
            "1.Connect Bluetooth device successfully!"),
        "deviceAddConnectBleTip2": MessageLookupByLibrary.simpleMessage(
            "2.Start sending information to the device..."),
        "deviceAddConnectBleTip3": MessageLookupByLibrary.simpleMessage(
            "2.Received the information successfully!"),
        "deviceAddConnectBleTip4": MessageLookupByLibrary.simpleMessage(
            "3.Waiting for devices to connect to the router..."),
        "deviceAddConnectBleTip5": MessageLookupByLibrary.simpleMessage(
            "3.The distribution network is successful!"),
        "deviceAddConnectBledDisconnected":
            MessageLookupByLibrary.simpleMessage("Bluetooth Disconnected"),
        "deviceBluetoothCantConnect":
            MessageLookupByLibrary.simpleMessage("Cannot connect to Bluetooth"),
        "deviceFirmwareUpgrade":
            MessageLookupByLibrary.simpleMessage("Device Firmware Upgrade"),
        "deviceLanguage":
            MessageLookupByLibrary.simpleMessage("Device Language"),
        "deviceList": MessageLookupByLibrary.simpleMessage("Device List"),
        "deviceNoMemoryCard": MessageLookupByLibrary.simpleMessage(
            "The device does not have a storage card"),
        "deviceReset": MessageLookupByLibrary.simpleMessage("Device Reset"),
        "deviceResetTip": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to factory reset the device?"),
        "deviceRestart": MessageLookupByLibrary.simpleMessage("Device Restart"),
        "deviceRestartTip": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to restart the device?"),
        "deviceShare": MessageLookupByLibrary.simpleMessage("Device Share"),
        "download": MessageLookupByLibrary.simpleMessage("Download Management"),
        "dynamic_alarm": MessageLookupByLibrary.simpleMessage("Alarm Settings"),
        "endTime": MessageLookupByLibrary.simpleMessage("End Time"),
        "factoryResetAndDeleteDev": MessageLookupByLibrary.simpleMessage(
            "Factory reset and delete device"),
        "firmwareCheckUpdate":
            MessageLookupByLibrary.simpleMessage("Check for Updates"),
        "firmwareChecking": MessageLookupByLibrary.simpleMessage("Checking..."),
        "firmwareCurrentVersion":
            MessageLookupByLibrary.simpleMessage("Current Version"),
        "firmwareDownloadFailed":
            MessageLookupByLibrary.simpleMessage("Firmware download failed"),
        "firmwareDownloadFile":
            MessageLookupByLibrary.simpleMessage("Downloading firmware"),
        "firmwareDownloadSuccess":
            MessageLookupByLibrary.simpleMessage("Firmware download complete"),
        "firmwareDownloadingToFirmware": MessageLookupByLibrary.simpleMessage(
            "Downloading firmware file to local"),
        "firmwareLatest":
            MessageLookupByLibrary.simpleMessage("Already up to date"),
        "firmwareLocalUpgrade":
            MessageLookupByLibrary.simpleMessage("Local Upgrade"),
        "firmwareNewVersion":
            MessageLookupByLibrary.simpleMessage("New Version"),
        "firmwareNoLocalFile": MessageLookupByLibrary.simpleMessage(
            "No local firmware file found"),
        "firmwareOnlineUpgrade":
            MessageLookupByLibrary.simpleMessage("Online Upgrade"),
        "firmwarePidFail": MessageLookupByLibrary.simpleMessage(
            "Failed to get PID, unable to check for updates"),
        "firmwareSelectLocalFile":
            MessageLookupByLibrary.simpleMessage("Select Local Firmware File"),
        "firmwareSendFile":
            MessageLookupByLibrary.simpleMessage("Sending firmware to device"),
        "firmwareUpgradeAvailable":
            MessageLookupByLibrary.simpleMessage("New version available"),
        "firmwareUpgradeConfirm": MessageLookupByLibrary.simpleMessage(
            "Are you sure to upgrade the device firmware?"),
        "firmwareUpgradeFailed":
            MessageLookupByLibrary.simpleMessage("Upgrade failed"),
        "firmwareUpgradeNow":
            MessageLookupByLibrary.simpleMessage("Upgrade Now"),
        "firmwareUpgradeSuccess": MessageLookupByLibrary.simpleMessage(
            "Upgrade successful, restarting..."),
        "firmwareUpgradeTip": MessageLookupByLibrary.simpleMessage(
            "Do not disconnect device power during upgrade"),
        "firmwareUpgrading": MessageLookupByLibrary.simpleMessage("Upgrading"),
        "firmwareVersionCheckFailed":
            MessageLookupByLibrary.simpleMessage("Version check failed"),
        "forgotPwd": MessageLookupByLibrary.simpleMessage("Forgot password"),
        "fullDuplexIntercom":
            MessageLookupByLibrary.simpleMessage("Full-duplex Intercom"),
        "getCode": MessageLookupByLibrary.simpleMessage("GET CODE"),
        "goLogin": MessageLookupByLibrary.simpleMessage(
            "has account yet, go to login page"),
        "goPhoneRegister":
            MessageLookupByLibrary.simpleMessage("try phone register"),
        "goRegister": MessageLookupByLibrary.simpleMessage(
            "do not have an account, register new one"),
        "hd": MessageLookupByLibrary.simpleMessage("HD"),
        "image": MessageLookupByLibrary.simpleMessage("image"),
        "imageConfig": MessageLookupByLibrary.simpleMessage("Image Settings"),
        "imageFlipLeftRight": MessageLookupByLibrary.simpleMessage(
            "Flip the image left and right"),
        "imageFlipUpDown":
            MessageLookupByLibrary.simpleMessage("Flip the image up and down"),
        "info": MessageLookupByLibrary.simpleMessage("User Info"),
        "inputAccountHint":
            MessageLookupByLibrary.simpleMessage("Enter username/phone/email"),
        "inputDeviceNameHint":
            MessageLookupByLibrary.simpleMessage("Please enter device name"),
        "invalidShareQR":
            MessageLookupByLibrary.simpleMessage("Invalid share QR code"),
        "labelDevSN": MessageLookupByLibrary.simpleMessage("Device SN"),
        "labelDeviceName": MessageLookupByLibrary.simpleMessage("Device name"),
        "lanSearch": MessageLookupByLibrary.simpleMessage("add via lan"),
        "local": MessageLookupByLibrary.simpleMessage("en"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "mailHint": MessageLookupByLibrary.simpleMessage("mail"),
        "mailPhone": MessageLookupByLibrary.simpleMessage("mail/phone"),
        "mailRegister": MessageLookupByLibrary.simpleMessage("Mail Register"),
        "mailTip": m11,
        "mediaType": MessageLookupByLibrary.simpleMessage("media type"),
        "memoryCardError":
            MessageLookupByLibrary.simpleMessage("Abnormal storage card"),
        "message": MessageLookupByLibrary.simpleMessage("message"),
        "messageDetail": MessageLookupByLibrary.simpleMessage("Message Detail"),
        "messageList": MessageLookupByLibrary.simpleMessage("Message List"),
        "messageReporting":
            MessageLookupByLibrary.simpleMessage("Message reporting"),
        "micVolume": MessageLookupByLibrary.simpleMessage("Microphone Volume"),
        "mine": MessageLookupByLibrary.simpleMessage("Mine"),
        "mode_customize": MessageLookupByLibrary.simpleMessage("Custom Mode"),
        "myDevice": MessageLookupByLibrary.simpleMessage("Mine"),
        "name": MessageLookupByLibrary.simpleMessage("username"),
        "nameHint":
            MessageLookupByLibrary.simpleMessage("username/email/phone"),
        "newPwd": MessageLookupByLibrary.simpleMessage("new password"),
        "noDevice": MessageLookupByLibrary.simpleMessage("No Device Available"),
        "noFound": MessageLookupByLibrary.simpleMessage("No Device Search"),
        "noPermissionTip":
            MessageLookupByLibrary.simpleMessage("No permission"),
        "noPhoneMailTip": MessageLookupByLibrary.simpleMessage(
            "Your account is not bound to any email or phone number. Clicking the button will directly cancel the account"),
        "noSDCardTips": MessageLookupByLibrary.simpleMessage(
            "No SD card detected, can\'t record 24 hours recording."),
        "noSharedAccount":
            MessageLookupByLibrary.simpleMessage("No shared accounts"),
        "normalAlarm": MessageLookupByLibrary.simpleMessage("Normal Alarm"),
        "nothing": MessageLookupByLibrary.simpleMessage("Nothing!"),
        "on": MessageLookupByLibrary.simpleMessage("open"),
        "onlyFactoryReset":
            MessageLookupByLibrary.simpleMessage("Factory reset only"),
        "operator_failed":
            MessageLookupByLibrary.simpleMessage("Operation failed"),
        "other": MessageLookupByLibrary.simpleMessage("other setting"),
        "pendingShareDevices":
            MessageLookupByLibrary.simpleMessage("Pending Share Devices"),
        "permAlarmPush": MessageLookupByLibrary.simpleMessage("Alarm Push"),
        "permDeviceConfig":
            MessageLookupByLibrary.simpleMessage("Device Config"),
        "permIntercom": MessageLookupByLibrary.simpleMessage("Intercom"),
        "permSdRecord": MessageLookupByLibrary.simpleMessage("SD Card Record"),
        "phone": MessageLookupByLibrary.simpleMessage("phone no"),
        "phoneMailTip": m12,
        "phoneRegister": MessageLookupByLibrary.simpleMessage("Phone Register"),
        "phoneRule": MessageLookupByLibrary.simpleMessage(
            "Overseas mobile phone numbers need to add area code. eg:+1:80998098979"),
        "phoneTip": m13,
        "preview": MessageLookupByLibrary.simpleMessage("preview"),
        "privacyPermissionBluetooth":
            MessageLookupByLibrary.simpleMessage("Bluetooth Access Permission"),
        "privacyPermissionDevNearbyContent":
            MessageLookupByLibrary.simpleMessage(
                "Used to search for nearby Bluetooth devices or other devices"),
        "push_setting": MessageLookupByLibrary.simpleMessage("Push Settings"),
        "pwdFindBack":
            MessageLookupByLibrary.simpleMessage("find back password"),
        "pwdHint": MessageLookupByLibrary.simpleMessage("password"),
        "pwdQuestion":
            MessageLookupByLibrary.simpleMessage("set security question"),
        "pwdRule": MessageLookupByLibrary.simpleMessage(
            "The password must be 8~64 characters, including uppercase/lowercase letters, numbers and special characters. Allow symbols: \'!@#%^&*()_[]{}?/.<>, \'\' ; : -\'"),
        "qrCodeShare": MessageLookupByLibrary.simpleMessage("QR Code Share"),
        "qrScan": MessageLookupByLibrary.simpleMessage("Align The QR Code"),
        "rebootFailed": MessageLookupByLibrary.simpleMessage("Restart failed"),
        "rebootSuccess":
            MessageLookupByLibrary.simpleMessage("Device restarting..."),
        "recordAudio": MessageLookupByLibrary.simpleMessage("Audio Recording"),
        "recordClip": MessageLookupByLibrary.simpleMessage("Video Segment"),
        "recordList": m14,
        "recordMode": MessageLookupByLibrary.simpleMessage("REC Button"),
        "recordQuality":
            MessageLookupByLibrary.simpleMessage("Recording Quality"),
        "recordQualityBad":
            MessageLookupByLibrary.simpleMessage("Relatively Poor"),
        "recordQualityBestGood": MessageLookupByLibrary.simpleMessage("Best"),
        "recordQualityGood": MessageLookupByLibrary.simpleMessage("Good"),
        "recordQualityNormal": MessageLookupByLibrary.simpleMessage("General"),
        "recordQualityVeryBad": MessageLookupByLibrary.simpleMessage("Poor"),
        "recordQualityVeryGood": MessageLookupByLibrary.simpleMessage("Better"),
        "recordSetting":
            MessageLookupByLibrary.simpleMessage("Video recording settings"),
        "refuseFailed":
            MessageLookupByLibrary.simpleMessage("Refuse share failed"),
        "refuseShare": MessageLookupByLibrary.simpleMessage("Refuse"),
        "refuseSuccess":
            MessageLookupByLibrary.simpleMessage("Refuse share success"),
        "reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "resetDevPwd":
            MessageLookupByLibrary.simpleMessage("reset device password"),
        "resetFailed":
            MessageLookupByLibrary.simpleMessage("Factory reset failed"),
        "resetPwd": MessageLookupByLibrary.simpleMessage("Reset Password"),
        "resetSuccess": MessageLookupByLibrary.simpleMessage(
            "Factory reset successful, restarting..."),
        "restartScan": MessageLookupByLibrary.simpleMessage("restart scan"),
        "routeSetting": MessageLookupByLibrary.simpleMessage("Route Setting"),
        "sHour": MessageLookupByLibrary.simpleMessage("Hour"),
        "sMin": MessageLookupByLibrary.simpleMessage("Minute"),
        "sSec": MessageLookupByLibrary.simpleMessage("Seconds"),
        "auto": MessageLookupByLibrary.simpleMessage("Auto"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "level_middle": MessageLookupByLibrary.simpleMessage("Medium"),
        "set_finish": MessageLookupByLibrary.simpleMessage("End Time"),
        "start_time": MessageLookupByLibrary.simpleMessage("Start Time"),
        "Start_And_End_Time_Unable_Equal":
            MessageLookupByLibrary.simpleMessage("Start and end time cannot be the same"),
        "Save_Success": MessageLookupByLibrary.simpleMessage("Saved successfully"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveFailed": MessageLookupByLibrary.simpleMessage("Save failed"),
        "saveSuccess":
            MessageLookupByLibrary.simpleMessage("Saved successfully"),
        "saving": MessageLookupByLibrary.simpleMessage("Saving..."),
        "scanShareDevice":
            MessageLookupByLibrary.simpleMessage("Scan to add shared device"),
        "sd": MessageLookupByLibrary.simpleMessage("SD"),
        "sdList": MessageLookupByLibrary.simpleMessage("Card Storage Album"),
        "sdkVersion":
            MessageLookupByLibrary.simpleMessage("Current SDK version"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "searchFailed": MessageLookupByLibrary.simpleMessage("Search failed"),
        "selectAll": MessageLookupByLibrary.simpleMessage("SelectAll"),
        "selectPlaybackSpeed":
            MessageLookupByLibrary.simpleMessage("Select playback speed"),
        "setDeviceName":
            MessageLookupByLibrary.simpleMessage("Set Device Name"),
        "setting": MessageLookupByLibrary.simpleMessage("Setting"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "shareAccepted": MessageLookupByLibrary.simpleMessage("Accepted"),
        "shareDevice": MessageLookupByLibrary.simpleMessage("Share"),
        "shareExpired": MessageLookupByLibrary.simpleMessage("Expired"),
        "shareFailed": MessageLookupByLibrary.simpleMessage("Share failed"),
        "shareFrom": MessageLookupByLibrary.simpleMessage("Shared from"),
        "sharePending": MessageLookupByLibrary.simpleMessage("Pending"),
        "sharePermission":
            MessageLookupByLibrary.simpleMessage("Share Permission"),
        "shareQRCode": MessageLookupByLibrary.simpleMessage("Share QR Code"),
        "shareQRTips": MessageLookupByLibrary.simpleMessage(
            "Scan QR code to add device share"),
        "shareRejected": MessageLookupByLibrary.simpleMessage("Rejected"),
        "shareSuccess": MessageLookupByLibrary.simpleMessage("Share success"),
        "shareTo": MessageLookupByLibrary.simpleMessage("Share to"),
        "sharedAccounts":
            MessageLookupByLibrary.simpleMessage("Shared Accounts"),
        "signal4GLevel": m15,
        "smart_analyze_line_left":
            MessageLookupByLibrary.simpleMessage("Left to Right"),
        "smart_analyze_line_middle":
            MessageLookupByLibrary.simpleMessage("Bidirectional"),
        "smart_analyze_line_right":
            MessageLookupByLibrary.simpleMessage("Right to Left"),
        "smart_analyze_restore":
            MessageLookupByLibrary.simpleMessage("Restore"),
        "smart_analyze_revoke": MessageLookupByLibrary.simpleMessage("Revoke"),
        "smart_analyze_shape_concave":
            MessageLookupByLibrary.simpleMessage("Concave"),
        "smart_analyze_shape_l_sel":
            MessageLookupByLibrary.simpleMessage("L-shape"),
        "smart_analyze_shape_pentagram":
            MessageLookupByLibrary.simpleMessage("Pentagon"),
        "smart_analyze_shape_rectangle":
            MessageLookupByLibrary.simpleMessage("Rectangle"),
        "smart_analyze_shape_triangle":
            MessageLookupByLibrary.simpleMessage("Triangle"),
        "smsLogin": MessageLookupByLibrary.simpleMessage("SmsLogin"),
        "speakerVolume": MessageLookupByLibrary.simpleMessage("Speaker Volume"),
        "startAdd": MessageLookupByLibrary.simpleMessage("start distribute"),
        "startScan": MessageLookupByLibrary.simpleMessage("start scan"),
        "startTime": MessageLookupByLibrary.simpleMessage("Start Time"),
        "statusLightSwitch":
            MessageLookupByLibrary.simpleMessage("Status Light"),
        "stopScan": MessageLookupByLibrary.simpleMessage("stop scan"),
        "storageManagement":
            MessageLookupByLibrary.simpleMessage("storage management"),
        "toolsFeedbackLog":
            MessageLookupByLibrary.simpleMessage("Feedback Log"),
        "tr_common_download_management":
            MessageLookupByLibrary.simpleMessage("Download management"),
        "tr_pet_function_record_start":
            MessageLookupByLibrary.simpleMessage("Click to Start Recording"),
        "tr_pet_function_recording_state": MessageLookupByLibrary.simpleMessage(
            "Recording in progress. Click again to stop recording."),
        "tr_pet_setting_sound_record_function":
            MessageLookupByLibrary.simpleMessage("Record summoning sound"),
        "tr_recording": MessageLookupByLibrary.simpleMessage("Recording..."),
        "tr_settings_alarm_alert_have_intersection":
            MessageLookupByLibrary.simpleMessage(
                "The area boundaries intersect, please redraw"),
        "tr_settings_alarm_beep":
            MessageLookupByLibrary.simpleMessage("Device alarm beep"),
        "tr_settings_alarm_bell_customize":
            MessageLookupByLibrary.simpleMessage("Custom voice"),
        "tr_settings_alarm_bell_select":
            MessageLookupByLibrary.simpleMessage("Device bell selection"),
        "type_alert_area": MessageLookupByLibrary.simpleMessage("Alert Area"),
        "type_alert_line": MessageLookupByLibrary.simpleMessage("Alert Line"),
        "userNotFound": MessageLookupByLibrary.simpleMessage("User not found"),
        "verCodeLogin":
            MessageLookupByLibrary.simpleMessage("Verification code login"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "video": MessageLookupByLibrary.simpleMessage("record"),
        "voiceTipSwitch": MessageLookupByLibrary.simpleMessage("Voice Prompt"),
        "waiting_buffering":
            MessageLookupByLibrary.simpleMessage("Buffering..."),
        "wifi": MessageLookupByLibrary.simpleMessage("add via wifi"),
        "wifiPwdHint": MessageLookupByLibrary.simpleMessage("Wifi Password"),
        "wifiSignalLevel": m16
      };
}
