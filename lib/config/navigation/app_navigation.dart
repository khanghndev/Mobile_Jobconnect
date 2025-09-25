import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage buildPageWithSlideTransition( Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey, // khoá duy nhất để Flutter nhận diện mỗi page.
    child: child, // page cần chuyển
    // Tạo một animation chuyển từ ngoài màn hình (phải) vào giữa màn hình với hiệu ứng mượt.
    transitionsBuilder: (context, animation, secondaryAnimation, child){
      const begin = Offset(1.0, 0.0); // bắt đầu bên phải màn hình
      const end = Offset.zero; // Kết thúc tại vị trí trung tâm
      const curve = Curves.ease; // mượt mà

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      // Áp dụng animation di chuyển cho widget con (màn hình mới).
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    }
  );
}