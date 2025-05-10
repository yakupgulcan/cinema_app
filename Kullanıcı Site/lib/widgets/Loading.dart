import 'package:flutter/material.dart';

class Loadingscreen extends StatefulWidget {
  final Future<void> Function() task;
  final Widget child;
  const Loadingscreen({super.key, required this.task, required this.child});

  @override
  State<Loadingscreen> createState() => _LoadingscreenState();
}

class _LoadingscreenState extends State<Loadingscreen> {

  bool completed = false;

  void islem() async{
    await widget.task();
    setState(() {
      completed=true;
    });
  }

  @override
  void initState() {
    super.initState();
    islem();
  }

  @override
  Widget build(BuildContext context) {
    if(completed){
      return widget.child;
    }
    return Center(child: CircularProgressIndicator(),);
  }
}
