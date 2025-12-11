
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaanap_admin_new/res/images/images.dart';

import '../../services/splash/splash_services.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  SplashServices _services = SplashServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _services.isLogin(context);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SvgPicture.asset(AppImages.splash,fit: BoxFit.fill,)
        ),

      ),
    );
  }
}
