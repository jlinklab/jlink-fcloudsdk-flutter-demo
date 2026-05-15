class User {
  String? id;
  String? userId;
  String? username;
  String? mail;
  String? phone;
  Authorizes? authorizes;

  int? passUpdateTime;

  String? nickname;

  User(
      {this.id,
      this.userId,
      this.username,
      this.mail,
      this.phone,
      this.authorizes,
      this.passUpdateTime,
      this.nickname});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    username = json['username'];
    mail = json['mail'];
    phone = json['phone'];
    authorizes = json['authorizes'] != null
        ? Authorizes.fromJson(json['authorizes'])
        : null;
    passUpdateTime = json['passUpdateTime'];
    nickname = json['nickname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['username'] = username;
    data['mail'] = mail;
    data['phone'] = phone;
    if (authorizes != null) {
      data['authorizes'] = authorizes!.toJson();
    }
    data['passUpdateTime'] = passUpdateTime;
    data['nickname'] = nickname;
    return data;
  }
}

class Authorizes {
  bool? wxpms;
  bool? wxbind;
  int? member;

  Authorizes({this.wxpms, this.wxbind, this.member});

  Authorizes.fromJson(Map<String, dynamic> json) {
    wxpms = json['wxpms'];
    wxbind = json['wxbind'];
    member = json['member'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wxpms'] = wxpms;
    data['wxbind'] = wxbind;
    data['member'] = member;
    return data;
  }
}
