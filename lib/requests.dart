import 'dart:convert';

import 'package:SocialMedia/config.dart';
import 'package:SocialMedia/model/post.dart';
import 'package:SocialMedia/model/user.dart';
import 'package:http/http.dart' as http;

class Requests {
  static Future<List<Post>> getPosts() async {
    try {
      var response = await http.get(Uri.parse("${Config.baseUrl}/post"));
      List<dynamic> jsonList = jsonDecode(response.body);
      List<Post> posts = [];
      for (var object in jsonList) {
        // {"message": 'something' , 'owner' : 'mahdi'}
        final post = Post.fromJson(object);
        posts.add(post);
      }
      return posts;
    } catch (e) {
      print("Error!");
      return [];
    }
  }

  static Future<String> signup(String username, String password) async {
    try {
      var response = await http.post(Uri.parse('${Config.baseUrl}/signup'),
          body: jsonEncode({
            "username": username,
            "password": password,
          }));
      return response.body;
    } catch (e) {
      return "Error";
    }
  }

  static Future<User?> login(String username, String password) async {
    try {
      var response = await http.post(Uri.parse('${Config.baseUrl}/login'),
          body: jsonEncode({
            "username": username,
            "password": password,
          }));

      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      print("Error");
      return null;
    }
  }

  static Future<String> addPost(String token, String message) async {
    try {
      var response = await http.post(Uri.parse('${Config.baseUrl}/post'),
          body: jsonEncode({
            "message": message,
          }),
          headers: {
            'Authorization': 'Bearer $token',
          });

      return response.body;
    } catch (e) {
      return "Error";
    }
  }
}
