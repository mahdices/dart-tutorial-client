import 'dart:async';
import 'dart:convert';

import 'package:SocialMedia/config.dart';
import 'package:SocialMedia/model/post.dart';
import 'package:SocialMedia/model/user.dart';
import 'package:SocialMedia/requests.dart';
import 'package:chalkdart/chalk.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:io';
import 'package:web_socket_channel/status.dart' as status;

import 'package:web_socket_channel/web_socket_channel.dart';

enum Pages { home, chatroom }

var currentPage = Pages.home;
User? currentUser;

void main() async {
  StreamSubscription<String>? inputListener;
  StreamSubscription<dynamic>? chatListener;
  final wsUrl = Uri.parse(
      'ws://127.0.0.1:8080/ws?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3Q0IiwiaWQiOjksImlhdCI6MTY3NzM1Njg0NH0.ivn2fApagFwzi0dXxlF8RCKDLniEtLjeXves_R11I-k');
  var channel = await WebSocketChannel.connect(wsUrl);
  print(chalk.bgBlueBright(
      '1:Login, 2:Signup, 3:Posts, 4:Add Post, 5:Chatroom, for exit press other keys'));

  chatListener = channel.stream.listen(
    (message) {
      if (currentPage == Pages.chatroom) {
        print(chalk.magenta('🟠: ${message}'));
      }
    },
  );
  inputListener = readLine().listen((message) async {
    switch (currentPage) {
      case Pages.chatroom:
        if (message == '-') {
          currentPage = Pages.home;
          print(chalk.bgBlueBright(
              '1:Login, 2:Signup, 3:Posts, 4:Add Post, 5:Chatroom, for exit press other keys'));
          return;
        }
        channel.sink.add(message);
        break;
      case Pages.home:
        print(chalk.bgBlueBright(
            '1:Login, 2:Signup, 3:Posts, 4:Add Post, 5:Chatroom, for exit press other keys'));
        switch (message) {
          case '1':
            currentUser = await login();
            print(currentUser);
            break;
          case '2':
            await signup();
            break;
          case '3':
            await getPosts();
            break;
          case '4':
            await addPost(currentUser);
            break;

          case '5':
            gotoChatroom();
            return;

          default:
            print("Please wait...");
            await channel.sink.close(status.goingAway);
            await chatListener?.cancel();
            await inputListener?.cancel();

            return;
        }
        print(chalk.bgBlueBright(
            '1:Login, 2:Signup, 3:Posts, 4:Add Post, 5:Chatroom, for exit press other keys'));
        break;
    }
  });

  // chatListener = readLine().listen((message) async {
  //   if (currentPage == Pages.chatroom) {
  //     if (message == '-') {
  //       currentPage = Pages.home;
  //       await gotoHomePage();
  //       return;
  //     }
  //     channel.sink.add(message);
  //   }
  // });
}

Future<User?> login() async {
  print(chalk.bold.green("Username:"));
  final username = stdin.readLineSync();
  print(chalk.bold.green("Password:"));
  final password = stdin.readLineSync();
  if (username == null || password == null) {
    print("Please add your username and password");
    return null;
  }
  return await Requests.login(username, password);
}

Future<void> signup() async {
  print("Username:");
  var username = stdin.readLineSync();
  print("Password:");
  var password = stdin.readLineSync();

  var signupResult = await Requests.signup(username!, password!);
  print(signupResult);
}

Future<void> getPosts() async {
  List<Post> posts = await Requests.getPosts();
  for (var post in posts) {
    print(chalk.magenta.onBlack("👨: ${post.owner}\n💬: ${post.message}"));
    print('_______________________________');
  }
}

Future<void> addPost(User? user) async {
  if (user == null) {
    print("Please login first");
    return;
  }
  print("Post message:");
  var message = stdin.readLineSync();
  if (message == null) {
    print("Please add message for post");
    return;
  }
  final response = await Requests.addPost(user.token, message);
  print(response);
}

void gotoChatroom() {
  print('You are in chat room for exit press -');
  currentPage = Pages.chatroom;
}

Stream<String> readLine() =>
    stdin.transform(utf8.decoder).transform(LineSplitter());
