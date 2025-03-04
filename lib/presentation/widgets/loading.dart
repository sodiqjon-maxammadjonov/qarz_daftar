import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool isAndroid = true;

  check() async {
    if (Platform.isIOS) {
      if (mounted) {
        setState(() {
          isAndroid = false;
        });
      }
    }
  }

  @override
  void initState() {
    check();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
        child: isAndroid
            ? CircularProgressIndicator(
          color: theme.primaryColor,
        )
            : CupertinoActivityIndicator(
          radius: 15,
          color: theme.primaryColor,
        ));
  }
}
