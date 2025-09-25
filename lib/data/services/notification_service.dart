// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotifications() async {
//     // 1. Xin quyền trên iOS
//     await _firebaseMessaging.requestPermission();

//     // 2. Lấy FCM Token
//     final fcmToken = await _firebaseMessaging.getToken();
//     print("FCM Token: $fcmToken");
//     // Bạn nên gửi token này về server của mình để lưu lại

//     // 3. Cấu hình cho local notifications (để hiển thị khi app đang mở)
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings(
//           '@mipmap/ic_launcher',
//         ); // Dùng icon mặc định của app
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     // 4. Lắng nghe và xử lý notification
//     initPushNotifications();
//   }

//   void initPushNotifications() {
//     // Xử lý khi app đang ở trạng thái foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("Got a message whilst in the foreground!");
//       print('Message data: ${message.data}');

//       if (message.notification != null) {
//         print('Message also contained a notification: ${message.notification}');
//         // Hiển thị thông báo bằng flutter_local_notifications
//         _showLocalNotification(message);
//       }
//     });

//     // Xử lý khi người dùng nhấn vào thông báo (app từ background -> foreground)
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('A new onMessageOpenedApp event was published!');
//       // Điều hướng đến màn hình cụ thể nếu cần
//     });
//   }

//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//           'high_importance_channel', // id
//           'High Importance Notifications', // title
//           channelDescription:
//               'This channel is used for important notifications.',
//           importance: Importance.max,
//           priority: Priority.high,
//           showWhen: false,
//         );
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );
//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       message.notification?.title,
//       message.notification?.body,
//       platformChannelSpecifics,
//       payload: 'item x',
//     );
//   }
// }
