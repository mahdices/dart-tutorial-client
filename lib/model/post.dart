import 'dart:io';

import 'package:SocialMedia/model/content.dart';

class Post extends Content {
  final String owner;
  final String message;

  Post(super.id, this.owner, this.message);

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(json['id'], json['owner'], json['message']);
  }
}

class Reel extends Content {
  Reel(super.id);
}
