class UserChat {
  final String id;
  final String nickname;
  final String email;
  final String photoUrl;

  final String createdAt;
  final String updatedAt;

  final String chattingWith;
  final String aboutMe;
  final String phoneNumber;
  final String location;
  final String token;

  UserChat(
      {this.id,
      this.nickname,
      this.email,
      this.photoUrl,
      this.createdAt,
      this.updatedAt,
      this.chattingWith,
      this.aboutMe,
      this.phoneNumber,
      this.location,
      this.token});

  UserChat.fromData(Map<String, dynamic> data)
      : id = data['id'],
        nickname = data['nickname'],
        email = data['email'],
        photoUrl = data['photoUrl'],
        createdAt = data['createdAt'],
        updatedAt = data['updatedAt'],
        chattingWith = data['chattingWith'],
        aboutMe = data['aboutMe'],
        location = data['location'],
        token = data['token'],
        phoneNumber = data['phoneNumber'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'chattingWith': chattingWith,
      'aboutMe': aboutMe,
      'location': location,
      'token': token,
      'phoneNumber': phoneNumber,
    };
  }
}
