import 'package:flutter/material.dart';
import 'package:gaanap_admin_new/config/routes/routes_name.dart';
import 'package:gaanap_admin_new/views/events/events.dart';
import 'package:gaanap_admin_new/views/finalscorecard/finalScorecard.dart';
import 'package:gaanap_admin_new/views/gamebegain/gameLoading.dart';
import 'package:gaanap_admin_new/views/gaveover/gameOver.dart';

import '../../views/eventdetail/eventDetail.dart';
import '../../views/gamebegain/gameScreen.dart';
import '../../views/views.dart';

class Routes{

    static Route<dynamic> generateRoute(RouteSettings settings){

      switch(settings.name){
        case RoutesName.splashScreen:
          return MaterialPageRoute(builder: (context) => const Splash());

        case RoutesName.loginScreen:
          return MaterialPageRoute(builder: (context) => const Login());

        case RoutesName.homeScreen:
          return MaterialPageRoute(builder: (context) => const Home());

        case RoutesName.eventsScreen:
          return MaterialPageRoute(builder: (context) => const GameEvents());

        case RoutesName.eventDetailScreen:
          return MaterialPageRoute(builder: (context) => const EventDetails());

        case RoutesName.gameLoading:
          final args = settings.arguments as Map<String, dynamic>?;

          return MaterialPageRoute(builder: (context) =>  GameLoading(
            gameid: args?["game_id"],
            hostid: args?["host_id"],
          ));

        case RoutesName.gameScreen:
          final args = settings.arguments as Map<String, dynamic>?;

          return MaterialPageRoute(builder: (context) =>  GameScreen(
            gameid: args?["game_id"],
            hostid: args?["host_id"],
          ));

        case RoutesName.gameOver:
          return MaterialPageRoute(builder: (context) => const GameOver());

        case RoutesName.finalScorecard:
          final args = settings.arguments as Map<String, dynamic>?;

          return MaterialPageRoute(builder: (context) =>  FinalScorecard(
            gameid: args?["game_id"],
          ));

        default:
          return MaterialPageRoute(builder: (context) {
            return const Scaffold(
              body: Center(
                child: Text("No Route Found"),
              ),
            );
          });
      }
    }
}