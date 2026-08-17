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

  static String m0(account) => "Are you sure to cancel share to ${account}?";

  static String m1(account) => "Are you sure to share device to ${account}?";

  static String m2(count) => "resend after ${count} seconds";

  static String m3(mail) => "will send verification code to ${mail}";

  static String m4(mail, phone) =>
      "you can choose either ${phone} or ${mail}, verification code will be sent to";

  static String m5(phone) => "will send verification code to ${phone}";

  static String m6(deviceId) => "${deviceId} Record List";

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
    "TR_QR_Code_Has_Been_Used_Generate_Again":
        MessageLookupByLibrary.simpleMessage(
          "QR code has been used, please contact the device owner to regenerate",
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
    "acceptFailed": MessageLookupByLibrary.simpleMessage("Accept share failed"),
    "acceptShare": MessageLookupByLibrary.simpleMessage("Accept"),
    "acceptShareDevice": MessageLookupByLibrary.simpleMessage(
      "Accept device share",
    ),
    "acceptSuccess": MessageLookupByLibrary.simpleMessage(
      "Accept share success",
    ),
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
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelBtn": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelShare": MessageLookupByLibrary.simpleMessage("Cancel Share"),
    "cancelShareContent": m0,
    "cancelShareFailed": MessageLookupByLibrary.simpleMessage(
      "Cancel share failed",
    ),
    "cancelShareSuccess": MessageLookupByLibrary.simpleMessage(
      "Cancel share success",
    ),
    "channel": MessageLookupByLibrary.simpleMessage("Channel"),
    "channelIpLimit": MessageLookupByLibrary.simpleMessage("IP Limited"),
    "channelList": MessageLookupByLibrary.simpleMessage("Channel List"),
    "channelLoginFailed": MessageLookupByLibrary.simpleMessage("Login Failed"),
    "channelNoConfig": MessageLookupByLibrary.simpleMessage("Not Configured"),
    "channelNoConnect": MessageLookupByLibrary.simpleMessage("Not Connected"),
    "channelNoLogin": MessageLookupByLibrary.simpleMessage("Not Logged In"),
    "channelOffline": MessageLookupByLibrary.simpleMessage("Offline"),
    "channelOnline": MessageLookupByLibrary.simpleMessage("Online"),
    "channelSleep": MessageLookupByLibrary.simpleMessage("Sleep"),
    "channelUnknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "check": MessageLookupByLibrary.simpleMessage("confirm"),
    "clickToShare": MessageLookupByLibrary.simpleMessage("Tap to share"),
    "cloudDownload": MessageLookupByLibrary.simpleMessage(
      "Cloud Storage Download",
    ),
    "cloudList": MessageLookupByLibrary.simpleMessage("Cloud Playback"),
    "cloudVideo": MessageLookupByLibrary.simpleMessage("Cloud Short Video"),
    "codeHint": MessageLookupByLibrary.simpleMessage("verification code"),
    "commonConfig": MessageLookupByLibrary.simpleMessage("Common Settings"),
    "confirmBtn": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmShare": MessageLookupByLibrary.simpleMessage("Confirm Share"),
    "confirmShareContent": m1,
    "countDown": m2,
    "customerServiceCenter": MessageLookupByLibrary.simpleMessage(
      "Customer Service Center",
    ),
    "dayNightAuto": MessageLookupByLibrary.simpleMessage("Auto Switch"),
    "dayNightAutoTip": MessageLookupByLibrary.simpleMessage(
      "Auto switch day/night mode by ambient light",
    ),
    "dayNightDay": MessageLookupByLibrary.simpleMessage("Force Day"),
    "dayNightDayTip": MessageLookupByLibrary.simpleMessage(
      "Force switch to day mode",
    ),
    "dayNightMode": MessageLookupByLibrary.simpleMessage("Day/Night Switch"),
    "dayNightNight": MessageLookupByLibrary.simpleMessage("Force Night"),
    "dayNightNightTip": MessageLookupByLibrary.simpleMessage(
      "Force switch to night mode",
    ),
    "dayNightSensitivity": MessageLookupByLibrary.simpleMessage("Sensitivity"),
    "dayNightTiming": MessageLookupByLibrary.simpleMessage("Timing Switch"),
    "dayNightTimingTip": MessageLookupByLibrary.simpleMessage(
      "Switch by scheduled time period",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "dev": MessageLookupByLibrary.simpleMessage("Device"),
    "devInfo": MessageLookupByLibrary.simpleMessage("device info"),
    "devName": MessageLookupByLibrary.simpleMessage("device name"),
    "devSN": MessageLookupByLibrary.simpleMessage("device serial No"),
    "device": MessageLookupByLibrary.simpleMessage("Device"),
    "deviceAbility": MessageLookupByLibrary.simpleMessage("Device Ability"),
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
    "deviceAwakened": MessageLookupByLibrary.simpleMessage("Awakened"),
    "deviceBluetoothCantConnect": MessageLookupByLibrary.simpleMessage(
      "Cannot connect to Bluetooth",
    ),
    "deviceDeepSleep": MessageLookupByLibrary.simpleMessage("Deep Sleep"),
    "deviceDeepSleepCannotWake": MessageLookupByLibrary.simpleMessage(
      "Device is in deep sleep and cannot be woken",
    ),
    "deviceFirmwareUpgrade": MessageLookupByLibrary.simpleMessage(
      "Device Firmware Upgrade",
    ),
    "deviceLanguage": MessageLookupByLibrary.simpleMessage("Device Language"),
    "deviceList": MessageLookupByLibrary.simpleMessage("Device List"),
    "deviceLoginName": MessageLookupByLibrary.simpleMessage(
      "Device Login Name",
    ),
    "deviceLoginNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Device login name format is invalid",
    ),
    "deviceLoginPassword": MessageLookupByLibrary.simpleMessage(
      "Device Login Password",
    ),
    "deviceNoMemoryCard": MessageLookupByLibrary.simpleMessage(
      "The device does not have a storage card",
    ),
    "deviceOffline": MessageLookupByLibrary.simpleMessage(
      "Device is offline, unable to preview",
    ),
    "devicePrepareSleep": MessageLookupByLibrary.simpleMessage(
      "Preparing to Sleep",
    ),
    "devicePwdInvalid": MessageLookupByLibrary.simpleMessage(
      "Device login password format is invalid",
    ),
    "deviceReset": MessageLookupByLibrary.simpleMessage("Device Reset"),
    "deviceResetTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to factory reset the device?",
    ),
    "deviceRestart": MessageLookupByLibrary.simpleMessage("Device Restart"),
    "deviceRestartTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to restart the device?",
    ),
    "deviceShare": MessageLookupByLibrary.simpleMessage("Device Share"),
    "deviceSleeping": MessageLookupByLibrary.simpleMessage("Sleeping"),
    "deviceToken": MessageLookupByLibrary.simpleMessage("Device Token"),
    "deviceWakingUp": MessageLookupByLibrary.simpleMessage("Waking up..."),
    "download": MessageLookupByLibrary.simpleMessage("Download Management"),
    "empty": MessageLookupByLibrary.simpleMessage("(empty)"),
    "endTime": MessageLookupByLibrary.simpleMessage("End Time"),
    "factoryResetAndDeleteDev": MessageLookupByLibrary.simpleMessage(
      "Factory reset and delete device",
    ),
    "firmwareCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Check for Updates",
    ),
    "firmwareChecking": MessageLookupByLibrary.simpleMessage("Checking..."),
    "firmwareCurrentVersion": MessageLookupByLibrary.simpleMessage(
      "Current Version",
    ),
    "firmwareDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Firmware download failed",
    ),
    "firmwareDownloadFile": MessageLookupByLibrary.simpleMessage(
      "Downloading firmware",
    ),
    "firmwareDownloadSuccess": MessageLookupByLibrary.simpleMessage(
      "Firmware download complete",
    ),
    "firmwareDownloadingToFirmware": MessageLookupByLibrary.simpleMessage(
      "Downloading firmware file to local",
    ),
    "firmwareLatest": MessageLookupByLibrary.simpleMessage(
      "Already up to date",
    ),
    "firmwareLocalUpgrade": MessageLookupByLibrary.simpleMessage(
      "Local Upgrade",
    ),
    "firmwareNewVersion": MessageLookupByLibrary.simpleMessage("New Version"),
    "firmwareNoLocalFile": MessageLookupByLibrary.simpleMessage(
      "No local firmware file found",
    ),
    "firmwareOnlineUpgrade": MessageLookupByLibrary.simpleMessage(
      "Online Upgrade",
    ),
    "firmwarePidFail": MessageLookupByLibrary.simpleMessage(
      "Failed to get PID, unable to check for updates",
    ),
    "firmwareSelectLocalFile": MessageLookupByLibrary.simpleMessage(
      "Select Local Firmware File",
    ),
    "firmwareSendFile": MessageLookupByLibrary.simpleMessage(
      "Sending firmware to device",
    ),
    "firmwareUpgradeAvailable": MessageLookupByLibrary.simpleMessage(
      "New version available",
    ),
    "firmwareUpgradeConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure to upgrade the device firmware?",
    ),
    "firmwareUpgradeFailed": MessageLookupByLibrary.simpleMessage(
      "Upgrade failed",
    ),
    "firmwareUpgradeNow": MessageLookupByLibrary.simpleMessage("Upgrade Now"),
    "firmwareUpgradeSuccess": MessageLookupByLibrary.simpleMessage(
      "Upgrade successful, restarting...",
    ),
    "firmwareUpgradeTip": MessageLookupByLibrary.simpleMessage(
      "Do not disconnect device power during upgrade",
    ),
    "firmwareUpgrading": MessageLookupByLibrary.simpleMessage("Upgrading"),
    "firmwareVersionCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Version check failed",
    ),
    "forgotPwd": MessageLookupByLibrary.simpleMessage("Forgot password"),
    "fullDuplexIntercom": MessageLookupByLibrary.simpleMessage(
      "Full-duplex Intercom",
    ),
    "getCode": MessageLookupByLibrary.simpleMessage("GET CODE"),
    "getDeviceToken": MessageLookupByLibrary.simpleMessage(
      "Get Latest Device Token",
    ),
    "getDeviceTokenDesc": MessageLookupByLibrary.simpleMessage(
      "Get latest token from server",
    ),
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
    "imageConfig": MessageLookupByLibrary.simpleMessage("Image Settings"),
    "imageFlipLeftRight": MessageLookupByLibrary.simpleMessage(
      "Flip the image left and right",
    ),
    "imageFlipUpDown": MessageLookupByLibrary.simpleMessage(
      "Flip the image up and down",
    ),
    "info": MessageLookupByLibrary.simpleMessage("User Info"),
    "inputAccountHint": MessageLookupByLibrary.simpleMessage(
      "Enter username/phone/email",
    ),
    "inputDeviceLoginName": MessageLookupByLibrary.simpleMessage(
      "Enter device login name",
    ),
    "inputDeviceLoginPassword": MessageLookupByLibrary.simpleMessage(
      "Enter device login password",
    ),
    "inputDeviceNameHint": MessageLookupByLibrary.simpleMessage(
      "Please enter device name",
    ),
    "invalidShareQR": MessageLookupByLibrary.simpleMessage(
      "Invalid share QR code",
    ),
    "labelDevSN": MessageLookupByLibrary.simpleMessage("Device SN"),
    "labelDeviceName": MessageLookupByLibrary.simpleMessage("Device name"),
    "lanSearch": MessageLookupByLibrary.simpleMessage("add via lan"),
    "loadChannelFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to load channel info",
    ),
    "loadingChannelInfo": MessageLookupByLibrary.simpleMessage(
      "Loading channel info...",
    ),
    "local": MessageLookupByLibrary.simpleMessage("en"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "lowPowerDevice": MessageLookupByLibrary.simpleMessage("Low Power Device"),
    "mailHint": MessageLookupByLibrary.simpleMessage("mail"),
    "mailPhone": MessageLookupByLibrary.simpleMessage("mail/phone"),
    "mailRegister": MessageLookupByLibrary.simpleMessage("Mail Register"),
    "mailTip": m3,
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
    "micVolume": MessageLookupByLibrary.simpleMessage("Microphone Volume"),
    "mine": MessageLookupByLibrary.simpleMessage("Mine"),
    "modifyDeviceInfo": MessageLookupByLibrary.simpleMessage(
      "Modify Device Info",
    ),
    "modifyFailed": MessageLookupByLibrary.simpleMessage("Modification failed"),
    "modifySuccess": MessageLookupByLibrary.simpleMessage(
      "Modified successfully",
    ),
    "myDevice": MessageLookupByLibrary.simpleMessage("Mine"),
    "name": MessageLookupByLibrary.simpleMessage("username"),
    "nameHint": MessageLookupByLibrary.simpleMessage("username/email/phone"),
    "newPwd": MessageLookupByLibrary.simpleMessage("new password"),
    "noAbilityData": MessageLookupByLibrary.simpleMessage("No ability data"),
    "noDevice": MessageLookupByLibrary.simpleMessage("No Device Available"),
    "noFound": MessageLookupByLibrary.simpleMessage("No Device Search"),
    "noPermissionTip": MessageLookupByLibrary.simpleMessage("No permission"),
    "noPhoneMailTip": MessageLookupByLibrary.simpleMessage(
      "Your account is not bound to any email or phone number. Clicking the button will directly cancel the account",
    ),
    "noSDCardTips": MessageLookupByLibrary.simpleMessage(
      "No SD card detected, can\'t record 24 hours recording.",
    ),
    "noSharedAccount": MessageLookupByLibrary.simpleMessage(
      "No shared accounts",
    ),
    "normalAlarm": MessageLookupByLibrary.simpleMessage("Normal Alarm"),
    "nothing": MessageLookupByLibrary.simpleMessage("Nothing!"),
    "on": MessageLookupByLibrary.simpleMessage("open"),
    "onlyFactoryReset": MessageLookupByLibrary.simpleMessage(
      "Factory reset only",
    ),
    "operator_failed": MessageLookupByLibrary.simpleMessage("Operation failed"),
    "other": MessageLookupByLibrary.simpleMessage("other setting"),
    "pendingShareDevices": MessageLookupByLibrary.simpleMessage(
      "Pending Share Devices",
    ),
    "permAlarmPush": MessageLookupByLibrary.simpleMessage("Alarm Push"),
    "permDeviceConfig": MessageLookupByLibrary.simpleMessage("Device Config"),
    "permIntercom": MessageLookupByLibrary.simpleMessage("Intercom"),
    "permSdRecord": MessageLookupByLibrary.simpleMessage("SD Card Record"),
    "phone": MessageLookupByLibrary.simpleMessage("phone no"),
    "phoneMailTip": m4,
    "phoneRegister": MessageLookupByLibrary.simpleMessage("Phone Register"),
    "phoneRule": MessageLookupByLibrary.simpleMessage(
      "Overseas mobile phone numbers need to add area code. eg:+1:80998098979",
    ),
    "phoneTip": m5,
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
    "qrCodeShare": MessageLookupByLibrary.simpleMessage("QR Code Share"),
    "qrScan": MessageLookupByLibrary.simpleMessage("Align The QR Code"),
    "rebootFailed": MessageLookupByLibrary.simpleMessage("Restart failed"),
    "rebootSuccess": MessageLookupByLibrary.simpleMessage(
      "Device restarting...",
    ),
    "recordAudio": MessageLookupByLibrary.simpleMessage("Audio Recording"),
    "recordClip": MessageLookupByLibrary.simpleMessage("Video Segment"),
    "recordList": m6,
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
    "refuseFailed": MessageLookupByLibrary.simpleMessage("Refuse share failed"),
    "refuseShare": MessageLookupByLibrary.simpleMessage("Refuse"),
    "refuseSuccess": MessageLookupByLibrary.simpleMessage(
      "Refuse share success",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetDevPwd": MessageLookupByLibrary.simpleMessage(
      "reset device password",
    ),
    "resetFailed": MessageLookupByLibrary.simpleMessage("Factory reset failed"),
    "resetPwd": MessageLookupByLibrary.simpleMessage("Reset Password"),
    "resetSuccess": MessageLookupByLibrary.simpleMessage(
      "Factory reset successful, restarting...",
    ),
    "restartScan": MessageLookupByLibrary.simpleMessage("restart scan"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "routeSetting": MessageLookupByLibrary.simpleMessage("Route Setting"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveFailed": MessageLookupByLibrary.simpleMessage("Save failed"),
    "saveSuccess": MessageLookupByLibrary.simpleMessage("Saved successfully"),
    "saving": MessageLookupByLibrary.simpleMessage("Saving..."),
    "scanShareDevice": MessageLookupByLibrary.simpleMessage(
      "Scan to add shared device",
    ),
    "sd": MessageLookupByLibrary.simpleMessage("SD"),
    "sdList": MessageLookupByLibrary.simpleMessage("Card Storage Album"),
    "sdkVersion": MessageLookupByLibrary.simpleMessage("Current SDK version"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchFailed": MessageLookupByLibrary.simpleMessage("Search failed"),
    "selectAll": MessageLookupByLibrary.simpleMessage("SelectAll"),
    "setDeviceName": MessageLookupByLibrary.simpleMessage("Set Device Name"),
    "setting": MessageLookupByLibrary.simpleMessage("Setting"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "shareAccepted": MessageLookupByLibrary.simpleMessage("Accepted"),
    "shareDevice": MessageLookupByLibrary.simpleMessage("Share"),
    "shareExpired": MessageLookupByLibrary.simpleMessage("Expired"),
    "shareFailed": MessageLookupByLibrary.simpleMessage("Share failed"),
    "shareFrom": MessageLookupByLibrary.simpleMessage("Shared from"),
    "sharePending": MessageLookupByLibrary.simpleMessage("Pending"),
    "sharePermission": MessageLookupByLibrary.simpleMessage("Share Permission"),
    "shareQRCode": MessageLookupByLibrary.simpleMessage("Share QR Code"),
    "shareQRTips": MessageLookupByLibrary.simpleMessage(
      "Scan QR code to add device share",
    ),
    "shareRejected": MessageLookupByLibrary.simpleMessage("Rejected"),
    "shareSuccess": MessageLookupByLibrary.simpleMessage("Share success"),
    "shareTo": MessageLookupByLibrary.simpleMessage("Share to"),
    "sharedAccounts": MessageLookupByLibrary.simpleMessage("Shared Accounts"),
    "smsLogin": MessageLookupByLibrary.simpleMessage("SmsLogin"),
    "speakerVolume": MessageLookupByLibrary.simpleMessage("Speaker Volume"),
    "startAdd": MessageLookupByLibrary.simpleMessage("start distribute"),
    "startScan": MessageLookupByLibrary.simpleMessage("start scan"),
    "startTime": MessageLookupByLibrary.simpleMessage("Start Time"),
    "statusLightSwitch": MessageLookupByLibrary.simpleMessage("Status Light"),
    "stopScan": MessageLookupByLibrary.simpleMessage("stop scan"),
    "storageManagement": MessageLookupByLibrary.simpleMessage(
      "storage management",
    ),
    "tokenLabel": MessageLookupByLibrary.simpleMessage("Token:"),
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
    "userNotFound": MessageLookupByLibrary.simpleMessage("User not found"),
    "verCodeLogin": MessageLookupByLibrary.simpleMessage(
      "Verification code login",
    ),
    "version": MessageLookupByLibrary.simpleMessage("Version"),
    "video": MessageLookupByLibrary.simpleMessage("record"),
    "viewDeviceAbility": MessageLookupByLibrary.simpleMessage(
      "View Device Ability",
    ),
    "viewDeviceAbilityDesc": MessageLookupByLibrary.simpleMessage(
      "View device supported features",
    ),
    "voiceTipSwitch": MessageLookupByLibrary.simpleMessage("Voice Prompt"),
    "wakeUpFailed": MessageLookupByLibrary.simpleMessage("Wake up failed"),
    "wakeUpTimeout": MessageLookupByLibrary.simpleMessage("Wake up timeout"),
    "wakingUpPleaseWait": MessageLookupByLibrary.simpleMessage(
      "Waking up device, please wait...",
    ),
    "wifi": MessageLookupByLibrary.simpleMessage("add via wifi"),
    "wifiPwdHint": MessageLookupByLibrary.simpleMessage("Wifi Password"),
  };
}
