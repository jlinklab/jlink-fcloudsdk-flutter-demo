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

  static String m11(path) =>
      "No local firmware found, please put the .bin/.img firmware file into: ${path}";

  static String m12(mail) => "will send verification code to ${mail}";

  static String m13(mail, phone) =>
      "you can choose either ${phone} or ${mail}, verification code will be sent to";

  static String m14(phone) => "will send verification code to ${phone}";

  static String m15(deviceId) => "${deviceId} Record List";

  static String m16(level) => "4G signal level [${level}]";

  static String m17(level) => "WiFi signal level [${level}]";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "Bright": MessageLookupByLibrary.simpleMessage("Brightness"),
        "Done": MessageLookupByLibrary.simpleMessage("Done"),
        "Double_Light_Vision":
            MessageLookupByLibrary.simpleMessage("Dual Light Alert"),
        "Full_Color_Vision":
            MessageLookupByLibrary.simpleMessage("Starlight Full Color"),
        "General_Night_Vision":
            MessageLookupByLibrary.simpleMessage("IR Night Vision"),
        "Intelligent_sensitivity":
            MessageLookupByLibrary.simpleMessage("Smart Sensitivity"),
        "Recording_Times_Not_DURATION": MessageLookupByLibrary.simpleMessage(
            "Recording duration must be at least 1 second"),
        "Save_Success":
            MessageLookupByLibrary.simpleMessage("Saved successfully"),
        "Show_traces": MessageLookupByLibrary.simpleMessage("Show smart trace"),
        "Start_And_End_Time_Unable_Equal": MessageLookupByLibrary.simpleMessage(
            "Start and end time cannot be the same"),
        "TR_AOV_Alarm_interval":
            MessageLookupByLibrary.simpleMessage("AOV Alarm Interval"),
        "TR_AOV_Fps": MessageLookupByLibrary.simpleMessage("AOV frame rate"),
        "TR_Alert_Set_Alert_Line_Tip": MessageLookupByLibrary.simpleMessage(
            "Please set the alert line, drag both ends to adjust"),
        "TR_Audition": MessageLookupByLibrary.simpleMessage("Audition"),
        "TR_AutoLight": MessageLookupByLibrary.simpleMessage("Auto Light"),
        "TR_AutoLightDetail": MessageLookupByLibrary.simpleMessage(
            "Automatically turn lights on and off based on environment"),
        "TR_Capture_Failed":
            MessageLookupByLibrary.simpleMessage("Capture failed"),
        "TR_Capture_Success":
            MessageLookupByLibrary.simpleMessage("Capture successful"),
        "TR_File_Size_Exceed_Max_Size": MessageLookupByLibrary.simpleMessage(
            "The File size exceeds the maximum limit"),
        "TR_Intelligent_Warning_Switch":
            MessageLookupByLibrary.simpleMessage("Smart Alert Switch"),
        "TR_Keep_On": MessageLookupByLibrary.simpleMessage("Always On"),
        "TR_LightSensitivitySubTitle": MessageLookupByLibrary.simpleMessage(""),
        "TR_Light_Settings":
            MessageLookupByLibrary.simpleMessage("Light Settings"),
        "TR_Low_Light_Control":
            MessageLookupByLibrary.simpleMessage("Low light control"),
        "TR_Low_Light_Control_Tip": MessageLookupByLibrary.simpleMessage(
            "When the low-light switch is turned on, the night scene will undergo low-light supplementation in AOV mode"),
        "TR_Modify_S":
            MessageLookupByLibrary.simpleMessage("Modified successfully"),
        "TR_Night_VisionLight":
            MessageLookupByLibrary.simpleMessage("IR Night Vision Light"),
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
        "TR_TimingLightDetail": MessageLookupByLibrary.simpleMessage(
            "Customize your light-on time"),
        "TR_Today": MessageLookupByLibrary.simpleMessage("Today"),
        "TR_Unknow": MessageLookupByLibrary.simpleMessage("Unknown"),
        "TR_Upload_Prompt_Voice":
            MessageLookupByLibrary.simpleMessage("Upload prompt tone"),
        "TR_Wakeup_Failed":
            MessageLookupByLibrary.simpleMessage("Wake-up failed"),
        "TR_Wakeup_In_Progress":
            MessageLookupByLibrary.simpleMessage("Waking up..."),
        "TR_Wakeup_Success":
            MessageLookupByLibrary.simpleMessage("Wake-up successful"),
        "TR_White_Light_Switch":
            MessageLookupByLibrary.simpleMessage("White Light Switch"),
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
        "addDeviceExisted":
            MessageLookupByLibrary.simpleMessage("Device already exists"),
        "advanced_set":
            MessageLookupByLibrary.simpleMessage("Advanced Settings"),
        "aeSensitivity": MessageLookupByLibrary.simpleMessage("AE Sensitivity"),
        "alarm": MessageLookupByLibrary.simpleMessage("alarm"),
        "alarmRecording":
            MessageLookupByLibrary.simpleMessage("Alarm recording"),
        "alarmScreenshot":
            MessageLookupByLibrary.simpleMessage("Alarm screenshot"),
        "alarmSubscription":
            MessageLookupByLibrary.simpleMessage("Alarm subscription"),
        "album": MessageLookupByLibrary.simpleMessage("Album"),
        "allDayRecording":
            MessageLookupByLibrary.simpleMessage("All-day Recording"),
        "alreadyOpen": MessageLookupByLibrary.simpleMessage("Opened"),
        "areaCode": MessageLookupByLibrary.simpleMessage("Choose Area Code"),
        "audio_ability_unsupport": MessageLookupByLibrary.simpleMessage(
            "Microphone permission is not enabled"),
        "auto": MessageLookupByLibrary.simpleMessage("Auto"),
        "autoInfrared": MessageLookupByLibrary.simpleMessage("Auto Infrared"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "backlightCompensation":
            MessageLookupByLibrary.simpleMessage("Backlight Compensation"),
        "baseStationHumanDetectionSwitch":
            MessageLookupByLibrary.simpleMessage("Humanoid detection switch"),
        "basicSetting": MessageLookupByLibrary.simpleMessage("Basic Settings"),
        "batteryInfo": m7,
        "blackWhiteMode": MessageLookupByLibrary.simpleMessage("Black & White"),
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
        "close": MessageLookupByLibrary.simpleMessage("Close"),
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
        "enterErrorCode":
            MessageLookupByLibrary.simpleMessage("Enter Error Code"),
        "errorCode": MessageLookupByLibrary.simpleMessage("Error Code"),
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
        "firmwareEmptyTip":
            MessageLookupByLibrary.simpleMessage("No firmware file"),
        "firmwareFirmwareDirTip": m11,
        "firmwareLatest":
            MessageLookupByLibrary.simpleMessage("Already up to date"),
        "firmwareLocalUpgrade":
            MessageLookupByLibrary.simpleMessage("Local Upgrade"),
        "firmwareMainModule":
            MessageLookupByLibrary.simpleMessage("Main Module"),
        "firmwareManageTitle":
            MessageLookupByLibrary.simpleMessage("Firmware Management"),
        "firmwareNewVersion":
            MessageLookupByLibrary.simpleMessage("New Version"),
        "firmwareNewVersionUpgradable": MessageLookupByLibrary.simpleMessage(
            "The new version can be upgraded"),
        "firmwareNoLocalFile": MessageLookupByLibrary.simpleMessage(
            "No local firmware file found"),
        "firmwareOnlineUpgrade":
            MessageLookupByLibrary.simpleMessage("Online Upgrade"),
        "firmwareP2PNotSupportTip": MessageLookupByLibrary.simpleMessage(
            "Local firmware upgrade is not supported in forward/penetration connection mode"),
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
        "firmwareUpgradeWaitReboot": MessageLookupByLibrary.simpleMessage(
            "Upgrade completed, waiting for device reboot"),
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
        "imageSetting": MessageLookupByLibrary.simpleMessage("Image Settings"),
        "info": MessageLookupByLibrary.simpleMessage("User Info"),
        "inputAccountHint":
            MessageLookupByLibrary.simpleMessage("Enter username/phone/email"),
        "inputDeviceNameHint":
            MessageLookupByLibrary.simpleMessage("Please enter device name"),
        "inputRightErrorCode": MessageLookupByLibrary.simpleMessage(
            "Please enter the correct error code"),
        "invalidShareQR":
            MessageLookupByLibrary.simpleMessage("Invalid share QR code"),
        "labelDevSN": MessageLookupByLibrary.simpleMessage("Device SN"),
        "labelDeviceName": MessageLookupByLibrary.simpleMessage("Device name"),
        "lanSearch": MessageLookupByLibrary.simpleMessage("add via lan"),
        "level_middle": MessageLookupByLibrary.simpleMessage("Medium"),
        "lightModeAutoIR": MessageLookupByLibrary.simpleMessage("Auto IR"),
        "lightModeSmartIR": MessageLookupByLibrary.simpleMessage("Smart IR"),
        "lightModeSmartWarmLight":
            MessageLookupByLibrary.simpleMessage("Smart Warm Light"),
        "lightModeWhiteLightFullColor":
            MessageLookupByLibrary.simpleMessage("White Light Full Color"),
        "local": MessageLookupByLibrary.simpleMessage("en"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "mailHint": MessageLookupByLibrary.simpleMessage("mail"),
        "mailPhone": MessageLookupByLibrary.simpleMessage("mail/phone"),
        "mailRegister": MessageLookupByLibrary.simpleMessage("Mail Register"),
        "mailTip": m12,
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
        "notOpen": MessageLookupByLibrary.simpleMessage("Not Opened"),
        "nothing": MessageLookupByLibrary.simpleMessage("Nothing!"),
        "on": MessageLookupByLibrary.simpleMessage("open"),
        "onlyFactoryReset":
            MessageLookupByLibrary.simpleMessage("Factory reset only"),
        "openLinkFailed":
            MessageLookupByLibrary.simpleMessage("Failed to open link"),
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
        "phoneMailTip": m13,
        "phoneRegister": MessageLookupByLibrary.simpleMessage("Phone Register"),
        "phoneRule": MessageLookupByLibrary.simpleMessage(
            "Overseas mobile phone numbers need to add area code. eg:+1:80998098979"),
        "phoneTip": m14,
        "pleaseCheckErrorCode": MessageLookupByLibrary.simpleMessage(
            "Please check the error code below or visit the Open Platform Documentation Center"),
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
        "receiveFileFailedTip": MessageLookupByLibrary.simpleMessage(
            "Firmware file receive failed, please share again"),
        "receiveFileNoPermissionTip": MessageLookupByLibrary.simpleMessage(
            "No file read permission, unable to receive firmware file"),
        "receiveFileNotSupportTip": MessageLookupByLibrary.simpleMessage(
            "File type not supported, only .bin/.img firmware files are allowed"),
        "receiveFileSuccessTip": MessageLookupByLibrary.simpleMessage(
            "Firmware file received successfully"),
        "recordAudio": MessageLookupByLibrary.simpleMessage("Audio Recording"),
        "recordClip": MessageLookupByLibrary.simpleMessage("Video Segment"),
        "recordList": m15,
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
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveFailed": MessageLookupByLibrary.simpleMessage("Save failed"),
        "saveSuccess":
            MessageLookupByLibrary.simpleMessage("Saved successfully"),
        "saving": MessageLookupByLibrary.simpleMessage("Saving..."),
        "scanShareDevice":
            MessageLookupByLibrary.simpleMessage("Scan to add shared device"),
        "sceneAddDevice": MessageLookupByLibrary.simpleMessage("Smart device"),
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
        "set_finish": MessageLookupByLibrary.simpleMessage("End Time"),
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
        "sharpness": MessageLookupByLibrary.simpleMessage("Sharpness"),
        "signal4GLevel": m16,
        "smartInfrared": MessageLookupByLibrary.simpleMessage("Smart Infrared"),
        "smartWarmLight":
            MessageLookupByLibrary.simpleMessage("Smart Warm Light"),
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
        "start_time": MessageLookupByLibrary.simpleMessage("Start Time"),
        "statusLightSwitch":
            MessageLookupByLibrary.simpleMessage("Status Light"),
        "stopScan": MessageLookupByLibrary.simpleMessage("stop scan"),
        "storageManagement":
            MessageLookupByLibrary.simpleMessage("storage management"),
        "toolsFeedbackLog":
            MessageLookupByLibrary.simpleMessage("Feedback Log"),
        "tr_common_download_management":
            MessageLookupByLibrary.simpleMessage("Download management"),
        "tr_error_code_1000":
            MessageLookupByLibrary.simpleMessage("Network error"),
        "tr_error_code_100000": MessageLookupByLibrary.simpleMessage("Error"),
        "tr_error_code_1001":
            MessageLookupByLibrary.simpleMessage("The send buffer is full"),
        "tr_error_code_1002":
            MessageLookupByLibrary.simpleMessage("Network sending error"),
        "tr_error_code_1003":
            MessageLookupByLibrary.simpleMessage("Network reception error"),
        "tr_error_code_1004":
            MessageLookupByLibrary.simpleMessage("Network timeout"),
        "tr_error_code_1005":
            MessageLookupByLibrary.simpleMessage("No network object"),
        "tr_error_code_1006":
            MessageLookupByLibrary.simpleMessage("Creation failed"),
        "tr_error_code_1007":
            MessageLookupByLibrary.simpleMessage("Connection failed"),
        "tr_error_code_1008": MessageLookupByLibrary.simpleMessage("Timeout"),
        "tr_error_code_1009":
            MessageLookupByLibrary.simpleMessage("No connection"),
        "tr_error_code_101":
            MessageLookupByLibrary.simpleMessage("Device password error"),
        "tr_error_code_1010":
            MessageLookupByLibrary.simpleMessage("socket error"),
        "tr_error_code_1011":
            MessageLookupByLibrary.simpleMessage("socket close error"),
        "tr_error_code_1012":
            MessageLookupByLibrary.simpleMessage("New buffer error"),
        "tr_error_code_1013":
            MessageLookupByLibrary.simpleMessage("Network busy"),
        "tr_error_code_1014":
            MessageLookupByLibrary.simpleMessage("Listening error"),
        "tr_error_code_1015":
            MessageLookupByLibrary.simpleMessage("Receive error"),
        "tr_error_code_1016": MessageLookupByLibrary.simpleMessage("No buffer"),
        "tr_error_code_1017": MessageLookupByLibrary.simpleMessage(
            "Network error or DNS configuration error"),
        "tr_error_code_1018": MessageLookupByLibrary.simpleMessage(
            "Developer account has no permission"),
        "tr_error_code_1019":
            MessageLookupByLibrary.simpleMessage("Uninitialized"),
        "tr_error_code_102":
            MessageLookupByLibrary.simpleMessage("Device account no exist"),
        "tr_error_code_1020": MessageLookupByLibrary.simpleMessage(
            "The device is in deep sleep mode"),
        "tr_error_code_1021":
            MessageLookupByLibrary.simpleMessage("Server error occurred"),
        "tr_error_code_1022":
            MessageLookupByLibrary.simpleMessage("HTTPS communication error"),
        "tr_error_code_1023": MessageLookupByLibrary.simpleMessage(
            "The system is busy, please try again later"),
        "tr_error_code_1024": MessageLookupByLibrary.simpleMessage(
            "Network busy, please try again later"),
        "tr_error_code_1025": MessageLookupByLibrary.simpleMessage(
            "CPU busy, please try again later"),
        "tr_error_code_1026": MessageLookupByLibrary.simpleMessage(
            "Storage usage is too high, please try again later"),
        "tr_error_code_1027": MessageLookupByLibrary.simpleMessage(
            "Too many concurrent tasks, please try again later"),
        "tr_error_code_103":
            MessageLookupByLibrary.simpleMessage("Device net unreachable"),
        "tr_error_code_104":
            MessageLookupByLibrary.simpleMessage("Device account logined"),
        "tr_error_code_105":
            MessageLookupByLibrary.simpleMessage("Device account locked"),
        "tr_error_code_106":
            MessageLookupByLibrary.simpleMessage("Device account in blacklist"),
        "tr_error_code_107":
            MessageLookupByLibrary.simpleMessage("Device device busy"),
        "tr_error_code_109":
            MessageLookupByLibrary.simpleMessage("Device net host no found"),
        "tr_error_code_120":
            MessageLookupByLibrary.simpleMessage("Device device no exist"),
        "tr_error_code_1239510":
            MessageLookupByLibrary.simpleMessage("Object does not exist"),
        "tr_error_code_1239511":
            MessageLookupByLibrary.simpleMessage("Value does not exist"),
        "tr_error_code_137":
            MessageLookupByLibrary.simpleMessage("Device token error"),
        "tr_error_code_2046401":
            MessageLookupByLibrary.simpleMessage("No i frame"),
        "tr_error_code_2046402":
            MessageLookupByLibrary.simpleMessage("Device stream break"),
        "tr_error_code_2046403":
            MessageLookupByLibrary.simpleMessage("Device stream timeout"),
        "tr_error_code_2046404":
            MessageLookupByLibrary.simpleMessage("Get datasource error"),
        "tr_error_code_2046405":
            MessageLookupByLibrary.simpleMessage("Url limited"),
        "tr_error_code_2046406":
            MessageLookupByLibrary.simpleMessage("Check url timeout"),
        "tr_error_code_2046407":
            MessageLookupByLibrary.simpleMessage("Http parse error"),
        "tr_error_code_2046408": MessageLookupByLibrary.simpleMessage(
            "Client not support please use chrome"),
        "tr_error_code_2046409":
            MessageLookupByLibrary.simpleMessage("Key frame no sps"),
        "tr_error_code_2046410":
            MessageLookupByLibrary.simpleMessage("Protocol parse error"),
        "tr_error_code_2046411":
            MessageLookupByLibrary.simpleMessage("No recv dev frame"),
        "tr_error_code_2046412":
            MessageLookupByLibrary.simpleMessage("No recv dev frame pre 2s"),
        "tr_error_code_2046413": MessageLookupByLibrary.simpleMessage(
            "No recv dev video frame pre 2s"),
        "tr_error_code_2046414":
            MessageLookupByLibrary.simpleMessage("Fps too low"),
        "tr_error_code_2046415":
            MessageLookupByLibrary.simpleMessage("Bad seektime"),
        "tr_error_code_2051000": MessageLookupByLibrary.simpleMessage(
            "Account owe fees, access to traffic service failed"),
        "tr_error_code_2051001": MessageLookupByLibrary.simpleMessage(
            "Service exception during service verification"),
        "tr_error_code_2051002": MessageLookupByLibrary.simpleMessage(
            "The service timed out during server verification"),
        "tr_error_code_2051003": MessageLookupByLibrary.simpleMessage(
            "There was an abnormality in the local network during service verification"),
        "tr_error_code_221201": MessageLookupByLibrary.simpleMessage(
            "Authorization failure for alarm related functions"),
        "tr_error_code_225000":
            MessageLookupByLibrary.simpleMessage("Server parsing failed"),
        "tr_error_code_225400": MessageLookupByLibrary.simpleMessage(
            "Authentication information not filled in"),
        "tr_error_code_225401": MessageLookupByLibrary.simpleMessage(
            "Authcode verification failed"),
        "tr_error_code_225402":
            MessageLookupByLibrary.simpleMessage("The message type is illegal"),
        "tr_error_code_225501": MessageLookupByLibrary.simpleMessage(
            "Incorrect username or password"),
        "tr_error_code_225502": MessageLookupByLibrary.simpleMessage(
            "Failed to obtain Redis IP and port"),
        "tr_error_code_225503": MessageLookupByLibrary.simpleMessage(
            "Redis connection establishment failed"),
        "tr_error_code_225504":
            MessageLookupByLibrary.simpleMessage("Redis operation failed"),
        "tr_error_code_225505": MessageLookupByLibrary.simpleMessage(
            "Failed to obtain MySQL address"),
        "tr_error_code_225506": MessageLookupByLibrary.simpleMessage(
            "Alarm Server parameter error"),
        "tr_error_code_225507":
            MessageLookupByLibrary.simpleMessage("SQL operation failed"),
        "tr_error_code_225508": MessageLookupByLibrary.simpleMessage(
            "Thumbnail URL retrieval failed"),
        "tr_error_code_225509": MessageLookupByLibrary.simpleMessage(
            "Time format verification failed"),
        "tr_error_code_225510": MessageLookupByLibrary.simpleMessage(
            "Abnormal cloud storage package information"),
        "tr_error_code_225511":
            MessageLookupByLibrary.simpleMessage("Invalid query type"),
        "tr_error_code_225512": MessageLookupByLibrary.simpleMessage(
            "The start time and end time of the query are not on the same day"),
        "tr_error_code_225513":
            MessageLookupByLibrary.simpleMessage("The SN format is illegal"),
        "tr_error_code_225514":
            MessageLookupByLibrary.simpleMessage("Clearing type is illegal"),
        "tr_error_code_225515": MessageLookupByLibrary.simpleMessage(
            "Unknown subscription query protocol format"),
        "tr_error_code_225516":
            MessageLookupByLibrary.simpleMessage("Non whitelist IP requests"),
        "tr_error_code_225517": MessageLookupByLibrary.simpleMessage(
            "This user does not have query permission"),
        "tr_error_code_225518":
            MessageLookupByLibrary.simpleMessage("Unknown unsubscribe method"),
        "tr_error_code_225519": MessageLookupByLibrary.simpleMessage(
            "Parameter format parsing error"),
        "tr_error_code_225520":
            MessageLookupByLibrary.simpleMessage("MongoDB operation error"),
        "tr_error_code_225521": MessageLookupByLibrary.simpleMessage(
            "Simultaneous operation of MongoDB and MySQL failed"),
        "tr_error_code_225522": MessageLookupByLibrary.simpleMessage(
            "The setting result of the query is invalid and cannot be resolved"),
        "tr_error_code_225523": MessageLookupByLibrary.simpleMessage(
            "Unknown message, unable to parse"),
        "tr_error_code_225524": MessageLookupByLibrary.simpleMessage(
            "Unable to obtain event at level Important"),
        "tr_error_code_225525":
            MessageLookupByLibrary.simpleMessage("Unknown state"),
        "tr_error_code_225526": MessageLookupByLibrary.simpleMessage(
            "The device has been unbound by this account and subscription is not allowed"),
        "tr_error_code_225527":
            MessageLookupByLibrary.simpleMessage("All video IDs are illegal"),
        "tr_error_code_500000": MessageLookupByLibrary.simpleMessage(
            "The parameter encoding format is not UTF8"),
        "tr_error_code_500001": MessageLookupByLibrary.simpleMessage(
            "The parameter is not in JSON format"),
        "tr_error_code_514053": MessageLookupByLibrary.simpleMessage(
            "The playback channel is already occupied"),
        "tr_error_code_514100": MessageLookupByLibrary.simpleMessage(
            "The intercom channel is occupied"),
        "tr_error_code_515000":
            MessageLookupByLibrary.simpleMessage("Device offline"),
        "tr_error_code_515001":
            MessageLookupByLibrary.simpleMessage("Device not registered"),
        "tr_error_code_515002":
            MessageLookupByLibrary.simpleMessage("The channel does not exist"),
        "tr_error_code_515003":
            MessageLookupByLibrary.simpleMessage("Channel not online"),
        "tr_error_code_515004":
            MessageLookupByLibrary.simpleMessage("Account error"),
        "tr_error_code_515005":
            MessageLookupByLibrary.simpleMessage("Password error"),
        "tr_error_code_515006": MessageLookupByLibrary.simpleMessage(
            "National standard or ONVIF login exception"),
        "tr_error_code_515104": MessageLookupByLibrary.simpleMessage(
            "Failed to obtain device information"),
        "tr_error_code_515200": MessageLookupByLibrary.simpleMessage(
            "National standard equipment overloaded or under maintenance"),
        "tr_error_code_515201": MessageLookupByLibrary.simpleMessage(
            "The device has no video recording"),
        "tr_error_code_515202": MessageLookupByLibrary.simpleMessage(
            "Play failed, please try again"),
        "tr_error_code_515203": MessageLookupByLibrary.simpleMessage(
            "The device is not responding"),
        "tr_error_code_515204": MessageLookupByLibrary.simpleMessage(
            "Device protocol incompatibility"),
        "tr_error_code_515205":
            MessageLookupByLibrary.simpleMessage("Device unauthorized"),
        "tr_error_code_516101":
            MessageLookupByLibrary.simpleMessage("URL format error"),
        "tr_error_code_516102":
            MessageLookupByLibrary.simpleMessage("No video recording"),
        "tr_error_code_516103":
            MessageLookupByLibrary.simpleMessage("URL expired"),
        "tr_error_code_516104":
            MessageLookupByLibrary.simpleMessage("URL authentication failed"),
        "tr_error_code_516105": MessageLookupByLibrary.simpleMessage(
            "Account has no data usage (please contact the service provider)"),
        "tr_error_code_516106": MessageLookupByLibrary.simpleMessage(
            "URL verification timeout, please try again"),
        "tr_error_code_516107": MessageLookupByLibrary.simpleMessage(
            "Open playback failed, please try again"),
        "tr_error_code_516108": MessageLookupByLibrary.simpleMessage(
            "Video recording query failed"),
        "tr_error_code_516109": MessageLookupByLibrary.simpleMessage(
            "Time parameter exceeds the range"),
        "tr_error_code_516110":
            MessageLookupByLibrary.simpleMessage("Illegal URL"),
        "tr_error_code_516116":
            MessageLookupByLibrary.simpleMessage("Request too frequently"),
        "tr_error_code_604000": MessageLookupByLibrary.simpleMessage(
            "The username or password is incorrect"),
        "tr_error_code_604010": MessageLookupByLibrary.simpleMessage(
            "The verification code is incorrect"),
        "tr_error_code_604011": MessageLookupByLibrary.simpleMessage(
            "The password is inconsistent"),
        "tr_error_code_604012": MessageLookupByLibrary.simpleMessage(
            "The username has been registered"),
        "tr_error_code_604013":
            MessageLookupByLibrary.simpleMessage("The user name is empty"),
        "tr_error_code_604014":
            MessageLookupByLibrary.simpleMessage("The password is empty"),
        "tr_error_code_604015": MessageLookupByLibrary.simpleMessage(
            "The confirm password is empty"),
        "tr_error_code_604016": MessageLookupByLibrary.simpleMessage(
            "The mobile phone number is empty"),
        "tr_error_code_604017": MessageLookupByLibrary.simpleMessage(
            "The username format is incorrect"),
        "tr_error_code_604018": MessageLookupByLibrary.simpleMessage(
            "The password format is incorrect"),
        "tr_error_code_604019": MessageLookupByLibrary.simpleMessage(
            "The confirm password format is incorrect"),
        "tr_error_code_604020": MessageLookupByLibrary.simpleMessage(
            "The format of the mobile phone number is incorrect"),
        "tr_error_code_604021": MessageLookupByLibrary.simpleMessage(
            "The phone number already exists"),
        "tr_error_code_604022": MessageLookupByLibrary.simpleMessage(
            "The phone number does not exist"),
        "tr_error_code_604023":
            MessageLookupByLibrary.simpleMessage("The mailbox already exists"),
        "tr_error_code_604024":
            MessageLookupByLibrary.simpleMessage("The mailbox does not exists"),
        "tr_error_code_604026":
            MessageLookupByLibrary.simpleMessage("The old password is wrong"),
        "tr_error_code_604027": MessageLookupByLibrary.simpleMessage(
            "Failed to change the password"),
        "tr_error_code_604028": MessageLookupByLibrary.simpleMessage(
            "The link for resetting the user\'s password has expired"),
        "tr_error_code_604029":
            MessageLookupByLibrary.simpleMessage("The user ID is empty"),
        "tr_error_code_604030": MessageLookupByLibrary.simpleMessage(
            "The verification code is empty"),
        "tr_error_code_604031":
            MessageLookupByLibrary.simpleMessage("The mailbox is empty"),
        "tr_error_code_604032": MessageLookupByLibrary.simpleMessage(
            "The mailbox format is incorrect"),
        "tr_error_code_604033":
            MessageLookupByLibrary.simpleMessage("No permission for this user"),
        "tr_error_code_604034":
            MessageLookupByLibrary.simpleMessage("The user is not bound"),
        "tr_error_code_604035":
            MessageLookupByLibrary.simpleMessage("Failed to bind user"),
        "tr_error_code_604036":
            MessageLookupByLibrary.simpleMessage("Failed to bind phone number"),
        "tr_error_code_604037":
            MessageLookupByLibrary.simpleMessage("Failed to bind mailbox"),
        "tr_error_code_604038": MessageLookupByLibrary.simpleMessage(
            "Send the verification code more than the maximum number of times"),
        "tr_error_code_604039":
            MessageLookupByLibrary.simpleMessage("Registration failed"),
        "tr_error_code_604040": MessageLookupByLibrary.simpleMessage(
            "Wechat has been bound to users"),
        "tr_error_code_604041": MessageLookupByLibrary.simpleMessage(
            "No permission to modify the user name (only for the generated anonymous user)"),
        "tr_error_code_604042": MessageLookupByLibrary.simpleMessage(
            "The user is not binding on facebook"),
        "tr_error_code_604043": MessageLookupByLibrary.simpleMessage(
            "The user failed to bind facebook"),
        "tr_error_code_604044": MessageLookupByLibrary.simpleMessage(
            "The user is not binding on google"),
        "tr_error_code_604045": MessageLookupByLibrary.simpleMessage(
            "The user failed to bind google"),
        "tr_error_code_604046": MessageLookupByLibrary.simpleMessage(
            "The Line account is not bound"),
        "tr_error_code_604047": MessageLookupByLibrary.simpleMessage(
            "Failed to bind the Line account"),
        "tr_error_code_604048": MessageLookupByLibrary.simpleMessage(
            "Too many errors in user verification code, resulting in invalid verification code"),
        "tr_error_code_604049": MessageLookupByLibrary.simpleMessage(
            "Too many user login errors, locked account for ten minutes"),
        "tr_error_code_604050": MessageLookupByLibrary.simpleMessage(
            "Request too frequent, please try again later"),
        "tr_error_code_604056":
            MessageLookupByLibrary.simpleMessage("User not activated"),
        "tr_error_code_604065": MessageLookupByLibrary.simpleMessage(
            "The user did not retrieve the password, and the app should continue to listen"),
        "tr_error_code_604100": MessageLookupByLibrary.simpleMessage(
            "Cannot be added due to the device is invalid"),
        "tr_error_code_604101":
            MessageLookupByLibrary.simpleMessage("The device already exists"),
        "tr_error_code_604102":
            MessageLookupByLibrary.simpleMessage("Failed to delete device"),
        "tr_error_code_604103":
            MessageLookupByLibrary.simpleMessage("Failed to modify"),
        "tr_error_code_604104": MessageLookupByLibrary.simpleMessage(
            "The device uuid parameter is abnormal"),
        "tr_error_code_604105": MessageLookupByLibrary.simpleMessage(
            "The device user name parameter is abnormal"),
        "tr_error_code_604106": MessageLookupByLibrary.simpleMessage(
            "The device password parameter is abnormal"),
        "tr_error_code_604107": MessageLookupByLibrary.simpleMessage(
            "Abnormal device port parameters"),
        "tr_error_code_604108": MessageLookupByLibrary.simpleMessage(
            "Device extension field parameter exception"),
        "tr_error_code_604110": MessageLookupByLibrary.simpleMessage(
            "New password verification failed"),
        "tr_error_code_604111": MessageLookupByLibrary.simpleMessage(
            "Confirm password verification failed"),
        "tr_error_code_604112": MessageLookupByLibrary.simpleMessage(
            "Device alias verification failed"),
        "tr_error_code_604114":
            MessageLookupByLibrary.simpleMessage("Cloud storage support"),
        "tr_error_code_604115":
            MessageLookupByLibrary.simpleMessage("Cloud storage not support"),
        "tr_error_code_604116": MessageLookupByLibrary.simpleMessage(
            "Failed to transfer the master account of the device to another user. Check whether the user owns the device and has the master account rights"),
        "tr_error_code_604117":
            MessageLookupByLibrary.simpleMessage("Not the main account"),
        "tr_error_code_604118": MessageLookupByLibrary.simpleMessage(
            "The device no longer exists and has been removed"),
        "tr_error_code_604119": MessageLookupByLibrary.simpleMessage(
            "Adding devices is not unique. Other accounts have been added"),
        "tr_error_code_604120": MessageLookupByLibrary.simpleMessage(
            "Maximum number of added devices"),
        "tr_error_code_604126": MessageLookupByLibrary.simpleMessage(
            "The device support token is added by only one account"),
        "tr_error_code_604127":
            MessageLookupByLibrary.simpleMessage("Device token is missing"),
        "tr_error_code_604200":
            MessageLookupByLibrary.simpleMessage("Add authorization failed"),
        "tr_error_code_604201": MessageLookupByLibrary.simpleMessage(
            "Failed to modify authorization"),
        "tr_error_code_604202":
            MessageLookupByLibrary.simpleMessage("Delete authorization failed"),
        "tr_error_code_604203": MessageLookupByLibrary.simpleMessage(
            "Single authorization synchronization failed"),
        "tr_error_code_604300":
            MessageLookupByLibrary.simpleMessage("Send failure"),
        "tr_error_code_604301":
            MessageLookupByLibrary.simpleMessage("Email signature failed"),
        "tr_error_code_604302": MessageLookupByLibrary.simpleMessage(
            "Account cancellation requires verification code"),
        "tr_error_code_604303": MessageLookupByLibrary.simpleMessage(
            "Registration email sent too many times, each email can only be sent five times a day"),
        "tr_error_code_604304": MessageLookupByLibrary.simpleMessage(
            "The password recovery email has been sent too many times, and each email can only be sent five times a day"),
        "tr_error_code_604400": MessageLookupByLibrary.simpleMessage(
            "SMS interface verification failed. Please contact us"),
        "tr_error_code_604401": MessageLookupByLibrary.simpleMessage(
            "The parameters of the SMS interface are incorrect. Please contact us"),
        "tr_error_code_604402": MessageLookupByLibrary.simpleMessage(
            "Text messages can only be sent three times a day per phone number"),
        "tr_error_code_604403": MessageLookupByLibrary.simpleMessage(
            "Sending failed, please try again later"),
        "tr_error_code_604404": MessageLookupByLibrary.simpleMessage(
            "Sent too frequently, please wait 120 seconds"),
        "tr_error_code_604405":
            MessageLookupByLibrary.simpleMessage("Send failure"),
        "tr_error_code_604500": MessageLookupByLibrary.simpleMessage(
            "No user list found or user list is empty"),
        "tr_error_code_604502": MessageLookupByLibrary.simpleMessage(
            "No device list found or the device list is empty"),
        "tr_error_code_604503":
            MessageLookupByLibrary.simpleMessage("Failed to reset app secret"),
        "tr_error_code_604600":
            MessageLookupByLibrary.simpleMessage("WeChat alarm failed to open"),
        "tr_error_code_604601": MessageLookupByLibrary.simpleMessage(
            "WeChat alarm failed to close"),
        "tr_error_code_605000":
            MessageLookupByLibrary.simpleMessage("Server error"),
        "tr_error_code_605001":
            MessageLookupByLibrary.simpleMessage("Certificate does not exist"),
        "tr_error_code_605002": MessageLookupByLibrary.simpleMessage(
            "The request header information is incorrect"),
        "tr_error_code_605003":
            MessageLookupByLibrary.simpleMessage("Certificate invalid"),
        "tr_error_code_605004":
            MessageLookupByLibrary.simpleMessage("Key validation error"),
        "tr_error_code_605005":
            MessageLookupByLibrary.simpleMessage("Parameter Exception"),
        "tr_error_code_605006":
            MessageLookupByLibrary.simpleMessage("Connection failed"),
        "tr_error_code_605007":
            MessageLookupByLibrary.simpleMessage("Unknown error"),
        "tr_error_code_605008": MessageLookupByLibrary.simpleMessage(
            "IP address not allowed for access"),
        "tr_error_code_605009": MessageLookupByLibrary.simpleMessage(
            "Wechat code error, AES encryption and decryption error"),
        "tr_error_code_605010":
            MessageLookupByLibrary.simpleMessage("Token Expired"),
        "tr_error_code_605011":
            MessageLookupByLibrary.simpleMessage("Token error"),
        "tr_error_code_605012":
            MessageLookupByLibrary.simpleMessage("Token No permission"),
        "tr_error_code_605013":
            MessageLookupByLibrary.simpleMessage("Not supported"),
        "tr_error_code_605014":
            MessageLookupByLibrary.simpleMessage("Frequent operations"),
        "tr_error_code_606000":
            MessageLookupByLibrary.simpleMessage("Invalid login method"),
        "tr_error_code_69999":
            MessageLookupByLibrary.simpleMessage("Json parsing failed"),
        "tr_error_code_70001": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Out of memory"),
        "tr_error_code_70002": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---File format error"),
        "tr_error_code_70003": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---A partition upgrade failed"),
        "tr_error_code_70004": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Hardware model mismatch"),
        "tr_error_code_70005": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Customer information mismatch"),
        "tr_error_code_70006": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---The version to be upgraded is lower than the current version of the device and cannot be upgraded"),
        "tr_error_code_70007": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Illegal version"),
        "tr_error_code_70008": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---The WiFi driver in the upgrade program does not match the WiFi network card currently in use by the device"),
        "tr_error_code_70009": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Network error"),
        "tr_error_code_70010": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---The upgrade program does not support Flash used by the device"),
        "tr_error_code_70011": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---The upgrade file has been modified and cannot be upgraded through an external network"),
        "tr_error_code_70012": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Upgrading this firmware requires special capability support"),
        "tr_error_code_70101":
            MessageLookupByLibrary.simpleMessage("Unknown mistake"),
        "tr_error_code_70102":
            MessageLookupByLibrary.simpleMessage("Version not supported"),
        "tr_error_code_70103":
            MessageLookupByLibrary.simpleMessage("Illegal request"),
        "tr_error_code_70104": MessageLookupByLibrary.simpleMessage(
            "The user is already logged in"),
        "tr_error_code_70105":
            MessageLookupByLibrary.simpleMessage("The user is not logged in"),
        "tr_error_code_70106": MessageLookupByLibrary.simpleMessage(
            "Username or password is incorrect"),
        "tr_error_code_70107": MessageLookupByLibrary.simpleMessage(
            "No device function permission"),
        "tr_error_code_70108": MessageLookupByLibrary.simpleMessage("Timeout"),
        "tr_error_code_70109": MessageLookupByLibrary.simpleMessage(
            "Search failed, no corresponding file found"),
        "tr_error_code_70110": MessageLookupByLibrary.simpleMessage(
            "Find success, return all files"),
        "tr_error_code_70111": MessageLookupByLibrary.simpleMessage(
            "Find success, return some files"),
        "tr_error_code_70112":
            MessageLookupByLibrary.simpleMessage("The user already exists"),
        "tr_error_code_70113":
            MessageLookupByLibrary.simpleMessage("The user does not exist"),
        "tr_error_code_70114": MessageLookupByLibrary.simpleMessage(
            "The user group already exists"),
        "tr_error_code_70115": MessageLookupByLibrary.simpleMessage(
            "The user group does not exist"),
        "tr_error_code_70116":
            MessageLookupByLibrary.simpleMessage("Pirated software"),
        "tr_error_code_70117":
            MessageLookupByLibrary.simpleMessage("Malformed message"),
        "tr_error_code_70118":
            MessageLookupByLibrary.simpleMessage("PTZ protocol not set"),
        "tr_error_code_70119":
            MessageLookupByLibrary.simpleMessage("Record file not found"),
        "tr_error_code_70120":
            MessageLookupByLibrary.simpleMessage("Configuration not enabled"),
        "tr_error_code_70121": MessageLookupByLibrary.simpleMessage(
            "Digital channel not connected"),
        "tr_error_code_70122": MessageLookupByLibrary.simpleMessage(
            "NAT video links maxed out, no new NAT video links allowed"),
        "tr_error_code_70123": MessageLookupByLibrary.simpleMessage(
            "TCP video link reaches maximum, no new TCP video link is allowed"),
        "tr_error_code_70124": MessageLookupByLibrary.simpleMessage(
            "Incorrect encryption algorithm for username and password"),
        "tr_error_code_70125": MessageLookupByLibrary.simpleMessage(
            "Created other users, can no longer log in with admin"),
        "tr_error_code_70126": MessageLookupByLibrary.simpleMessage(
            "AES encrypted data format error"),
        "tr_error_code_70127": MessageLookupByLibrary.simpleMessage(
            "The user has disabled video recording and preview functions through one click masking and other functions"),
        "tr_error_code_70128": MessageLookupByLibrary.simpleMessage(
            "Prohibit 4G remote video watching"),
        "tr_error_code_70129": MessageLookupByLibrary.simpleMessage(
            "Prohibit remote login using admin username"),
        "tr_error_code_70130":
            MessageLookupByLibrary.simpleMessage("NAS address already exists"),
        "tr_error_code_70131": MessageLookupByLibrary.simpleMessage(
            "The path is in use and cannot be operated"),
        "tr_error_code_70132": MessageLookupByLibrary.simpleMessage(
            "The NAS has reached the maximum supported value, and further additions are not allowed"),
        "tr_error_code_70136":
            MessageLookupByLibrary.simpleMessage("CGI format error"),
        "tr_error_code_70137":
            MessageLookupByLibrary.simpleMessage("Device login token error"),
        "tr_error_code_70140": MessageLookupByLibrary.simpleMessage(
            "Consumer product remote control is bound to the wrong key"),
        "tr_error_code_70150": MessageLookupByLibrary.simpleMessage(
            "Success, the device needs to be restarted"),
        "tr_error_code_70151": MessageLookupByLibrary.simpleMessage(
            "The file was not successfully deleted"),
        "tr_error_code_70152":
            MessageLookupByLibrary.simpleMessage("Lack of capacity"),
        "tr_error_code_70153":
            MessageLookupByLibrary.simpleMessage("No SD card or hard drive"),
        "tr_error_code_70160":
            MessageLookupByLibrary.simpleMessage("Video backup failed"),
        "tr_error_code_70161": MessageLookupByLibrary.simpleMessage(
            "There is no recording device or the device is not recording"),
        "tr_error_code_70162":
            MessageLookupByLibrary.simpleMessage("Device is being added"),
        "tr_error_code_70163": MessageLookupByLibrary.simpleMessage(
            "The device returned the wrong password"),
        "tr_error_code_70164": MessageLookupByLibrary.simpleMessage(
            "Not enough space on the device"),
        "tr_error_code_70165": MessageLookupByLibrary.simpleMessage(
            "Device is busy and currently not in service"),
        "tr_error_code_70170":
            MessageLookupByLibrary.simpleMessage("Function not enabled"),
        "tr_error_code_70173":
            MessageLookupByLibrary.simpleMessage("Connection to server failed"),
        "tr_error_code_70174":
            MessageLookupByLibrary.simpleMessage("Unable to detect memory"),
        "tr_error_code_70180": MessageLookupByLibrary.simpleMessage(
            "The function has been activated"),
        "tr_error_code_70181": MessageLookupByLibrary.simpleMessage(
            "Network initialization failed"),
        "tr_error_code_70182":
            MessageLookupByLibrary.simpleMessage("System error"),
        "tr_error_code_70183":
            MessageLookupByLibrary.simpleMessage("Operation failed"),
        "tr_error_code_70184": MessageLookupByLibrary.simpleMessage(
            "Switching from low-power mode to constant power mode failed"),
        "tr_error_code_70202":
            MessageLookupByLibrary.simpleMessage("Do not login"),
        "tr_error_code_70203":
            MessageLookupByLibrary.simpleMessage("The password is invalid"),
        "tr_error_code_70205":
            MessageLookupByLibrary.simpleMessage("The user is invalid"),
        "tr_error_code_70206": MessageLookupByLibrary.simpleMessage(
            "Account is locked with wrong login"),
        "tr_error_code_70207":
            MessageLookupByLibrary.simpleMessage("Account is blacklisted"),
        "tr_error_code_70208":
            MessageLookupByLibrary.simpleMessage("User has used"),
        "tr_error_code_70209":
            MessageLookupByLibrary.simpleMessage("Invalid input"),
        "tr_error_code_70210": MessageLookupByLibrary.simpleMessage(
            "The index is duplicated if the user to be added already exists"),
        "tr_error_code_70211": MessageLookupByLibrary.simpleMessage(
            "Object does not exist when used for query"),
        "tr_error_code_70212":
            MessageLookupByLibrary.simpleMessage("Object does not exist"),
        "tr_error_code_70213": MessageLookupByLibrary.simpleMessage(
            "The target is in use, if the group is used, it cannot be deleted"),
        "tr_error_code_70214":
            MessageLookupByLibrary.simpleMessage("Subset out of scope"),
        "tr_error_code_70215":
            MessageLookupByLibrary.simpleMessage("The password is incorrect"),
        "tr_error_code_70216":
            MessageLookupByLibrary.simpleMessage("The password do not match"),
        "tr_error_code_70217":
            MessageLookupByLibrary.simpleMessage("Keep account"),
        "tr_error_code_70218": MessageLookupByLibrary.simpleMessage(
            "Unable to log in during system maintenance"),
        "tr_error_code_70219": MessageLookupByLibrary.simpleMessage(
            "The trial period has ended and the unlock password is incorrect"),
        "tr_error_code_70220": MessageLookupByLibrary.simpleMessage(
            "Incorrect answer to security question"),
        "tr_error_code_70221": MessageLookupByLibrary.simpleMessage(
            "Reset password function, too many attempts to restore default verification code"),
        "tr_error_code_70222": MessageLookupByLibrary.simpleMessage(
            "Restore default verification code error"),
        "tr_error_code_70223":
            MessageLookupByLibrary.simpleMessage("Username not available"),
        "tr_error_code_70224": MessageLookupByLibrary.simpleMessage(
            "Storage has reached its limit, no more new users can be added"),
        "tr_error_code_70502":
            MessageLookupByLibrary.simpleMessage("Command is illegal"),
        "tr_error_code_70503": MessageLookupByLibrary.simpleMessage(
            "Voice intercom has been enabled"),
        "tr_error_code_70504":
            MessageLookupByLibrary.simpleMessage("Intercom not enabled"),
        "tr_error_code_70511": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Upgrade has started"),
        "tr_error_code_70512": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Upgrade not started"),
        "tr_error_code_70513": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Upgrade data error"),
        "tr_error_code_70514": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Upgrade failed"),
        "tr_error_code_70516": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Device busy or cloud upgrade server busy"),
        "tr_error_code_70517": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---This upgrade was initiated by another connection and cannot be stopped"),
        "tr_error_code_70518": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---It is the latest version currently"),
        "tr_error_code_70519": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Upgrade file mismatch"),
        "tr_error_code_70520": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Front end device not online"),
        "tr_error_code_70521": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Restore default failed"),
        "tr_error_code_70522": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Device needs to be restarted"),
        "tr_error_code_70523": MessageLookupByLibrary.simpleMessage(
            "Device upgrade---Illegal default configuration"),
        "tr_error_code_70524": MessageLookupByLibrary.simpleMessage(
            "Bluetooth pairing has started"),
        "tr_error_code_70525": MessageLookupByLibrary.simpleMessage(
            "Bluetooth pairing has reached the upper limit"),
        "tr_error_code_70526": MessageLookupByLibrary.simpleMessage(
            "Low battery does not support controlling the PTZ"),
        "tr_error_code_70527": MessageLookupByLibrary.simpleMessage(
            "Message sent to the main control failed"),
        "tr_error_code_70528": MessageLookupByLibrary.simpleMessage(
            "Failed to obtain upgrade file information"),
        "tr_error_code_70529": MessageLookupByLibrary.simpleMessage(
            "Online upgrade not initiated"),
        "tr_error_code_70530": MessageLookupByLibrary.simpleMessage(
            "Ignoring version information prompts"),
        "tr_error_code_70531": MessageLookupByLibrary.simpleMessage(
            "Remote facial recognition function not enabled"),
        "tr_error_code_70602": MessageLookupByLibrary.simpleMessage(
            "Need to restart the application"),
        "tr_error_code_70603":
            MessageLookupByLibrary.simpleMessage("Need to restart the device"),
        "tr_error_code_70604":
            MessageLookupByLibrary.simpleMessage("Failed to write file"),
        "tr_error_code_70605":
            MessageLookupByLibrary.simpleMessage("Feature not supported"),
        "tr_error_code_70606":
            MessageLookupByLibrary.simpleMessage("Verification failed"),
        "tr_error_code_70607":
            MessageLookupByLibrary.simpleMessage("Configuration parsing error"),
        "tr_error_code_70609": MessageLookupByLibrary.simpleMessage(
            "Configuration does not exist"),
        "tr_error_code_79998":
            MessageLookupByLibrary.simpleMessage("Opening audio failed"),
        "tr_error_code_79999":
            MessageLookupByLibrary.simpleMessage("YUV data abnormality"),
        "tr_error_code_90000":
            MessageLookupByLibrary.simpleMessage("User cancellation"),
        "tr_error_code_90001":
            MessageLookupByLibrary.simpleMessage("Illegal files"),
        "tr_error_code_90002":
            MessageLookupByLibrary.simpleMessage("Account not enabled"),
        "tr_error_code_90003":
            MessageLookupByLibrary.simpleMessage("Function overdue"),
        "tr_error_code_90004": MessageLookupByLibrary.simpleMessage(
            "Reached maximum number of connections"),
        "tr_error_code_90005":
            MessageLookupByLibrary.simpleMessage("Function not initialized"),
        "tr_error_code_99967":
            MessageLookupByLibrary.simpleMessage("Wake up device failed"),
        "tr_error_code_99968":
            MessageLookupByLibrary.simpleMessage("Device deep sleep"),
        "tr_error_code_99969": MessageLookupByLibrary.simpleMessage(
            "The device is preparing to sleep"),
        "tr_error_code_99970":
            MessageLookupByLibrary.simpleMessage("File read failure"),
        "tr_error_code_99971":
            MessageLookupByLibrary.simpleMessage("File download failed"),
        "tr_error_code_99972":
            MessageLookupByLibrary.simpleMessage("File does not exist"),
        "tr_error_code_99973":
            MessageLookupByLibrary.simpleMessage("Directory does not exist"),
        "tr_error_code_99974": MessageLookupByLibrary.simpleMessage(
            "Temporary file directory not set during initialization"),
        "tr_error_code_99975":
            MessageLookupByLibrary.simpleMessage("Device offline"),
        "tr_error_code_99976":
            MessageLookupByLibrary.simpleMessage("User on blacklist"),
        "tr_error_code_99977":
            MessageLookupByLibrary.simpleMessage("User locked"),
        "tr_error_code_99978": MessageLookupByLibrary.simpleMessage(
            "The user has logged in from another location"),
        "tr_error_code_99979": MessageLookupByLibrary.simpleMessage(
            "Incorrect username or password"),
        "tr_error_code_99980":
            MessageLookupByLibrary.simpleMessage("Protocol parsing error"),
        "tr_error_code_99981": MessageLookupByLibrary.simpleMessage(
            "Insufficient or full buffer size"),
        "tr_error_code_99982":
            MessageLookupByLibrary.simpleMessage("Send buffer full"),
        "tr_error_code_99983": MessageLookupByLibrary.simpleMessage(
            "Failed to start listening server"),
        "tr_error_code_99984": MessageLookupByLibrary.simpleMessage(
            "Failed to bind listening port (port occupied)"),
        "tr_error_code_99985":
            MessageLookupByLibrary.simpleMessage("Internal server error"),
        "tr_error_code_99986":
            MessageLookupByLibrary.simpleMessage("Object is busy"),
        "tr_error_code_99987":
            MessageLookupByLibrary.simpleMessage("Network sending error"),
        "tr_error_code_99988":
            MessageLookupByLibrary.simpleMessage("Network acceptance error"),
        "tr_error_code_99989":
            MessageLookupByLibrary.simpleMessage("Failed to create buffer"),
        "tr_error_code_99990":
            MessageLookupByLibrary.simpleMessage("Not found"),
        "tr_error_code_99991": MessageLookupByLibrary.simpleMessage("Timeout"),
        "tr_error_code_99992":
            MessageLookupByLibrary.simpleMessage("Object already exists"),
        "tr_error_code_99993":
            MessageLookupByLibrary.simpleMessage("Network error"),
        "tr_error_code_99994":
            MessageLookupByLibrary.simpleMessage("Not supported"),
        "tr_error_code_99995":
            MessageLookupByLibrary.simpleMessage("Fail to read file"),
        "tr_error_code_99996":
            MessageLookupByLibrary.simpleMessage("Fail to write file"),
        "tr_error_code_99997":
            MessageLookupByLibrary.simpleMessage("Fail to open file"),
        "tr_error_code_99998":
            MessageLookupByLibrary.simpleMessage("Fail to create file"),
        "tr_error_code_99999":
            MessageLookupByLibrary.simpleMessage("Parameter error"),
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
        "visitOpenPlatformDocumentationCenter":
            MessageLookupByLibrary.simpleMessage(
                "visit the Open Platform Documentation Center"),
        "voiceTipSwitch": MessageLookupByLibrary.simpleMessage("Voice Prompt"),
        "waiting_buffering":
            MessageLookupByLibrary.simpleMessage("Buffering..."),
        "waterMark": MessageLookupByLibrary.simpleMessage("Watermark"),
        "waterMarkConfig":
            MessageLookupByLibrary.simpleMessage("Watermark Config"),
        "waterMarkTips": MessageLookupByLibrary.simpleMessage(
            "Editing the device name will update the channel title watermark. Live preview effect:"),
        "wdrConfig": MessageLookupByLibrary.simpleMessage("WDR Config"),
        "wdrConfigTips": MessageLookupByLibrary.simpleMessage(
            "This function can help the device take high-quality images in high-contrast light conditions. The image effect is as follows:"),
        "wdrSwitch": MessageLookupByLibrary.simpleMessage("WDR Switch"),
        "whiteLightColor":
            MessageLookupByLibrary.simpleMessage("White Light Color"),
        "wifi": MessageLookupByLibrary.simpleMessage("add via wifi"),
        "wifiPwdHint": MessageLookupByLibrary.simpleMessage("Wifi Password"),
        "wifiSignalLevel": m17
      };
}
