
import 'package:flutter/material.dart';
import 'package:gaanap_admin_new/bloc/event/event_bloc.dart';
import 'package:gaanap_admin_new/repository/auth/login_http_repository.dart';
import 'package:gaanap_admin_new/repository/auth/login_mock_repository.dart';
import 'package:gaanap_admin_new/repository/auth/login_repository.dart';
import 'package:gaanap_admin_new/repository/event/event_http_repository.dart';
import 'package:gaanap_admin_new/repository/event/event_repository.dart';
import 'package:gaanap_admin_new/repository/movie_repo/movies_http_repository.dart';
import 'package:gaanap_admin_new/repository/movie_repo/movies_repository.dart';
import 'package:get_it/get_it.dart';

import 'bloc/login/login_bloc.dart';
import 'config/routes/routes.dart';
import 'config/routes/routes_name.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

GetIt getit =  GetIt.instance;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:DefaultFirebaseOptions.currentPlatform,
  );

  serviceLocator();
  runApp( MultiProvider(
    providers: [
      Provider<LoginBloc>(create: (_) => LoginBloc(loginRepository: getit<LoginRepository>())),
      Provider<EventBloc>(create: (_) => EventBloc(eventRepository: getit<EventRepository>())),

      // Add more providers here
    ],
    child: const MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HFMGame',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: RoutesName.splashScreen,
      onGenerateRoute: Routes.generateRoute,

    );
  }


}

void serviceLocator(){
  getit.registerLazySingleton<LoginRepository>(() => LoginHttpRepository());
  getit.registerLazySingleton<MoviesRepository>(() => MoviesHttpRepository());
  getit.registerLazySingleton<EventRepository>(() => EventHttpRepository());

}