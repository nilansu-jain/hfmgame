
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaanap_admin_new/views/home/widgets/error_widget.dart';
import 'package:gaanap_admin_new/views/home/widgets/movies_list_widget.dart';

import '../../bloc/movies/movie_bloc.dart';
import '../../config/routes/routes_name.dart';
import '../../main.dart';
import '../../services/storage/local_storage.dart';
import '../../utils/enums.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late MovieBloc _movieBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _movieBloc = MovieBloc(moviesRepository: getit());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _movieBloc.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home"),
              actions: [
                IconButton(onPressed: (){
                  LocalStorage localStorage = LocalStorage();
                  localStorage.deleteData('user').then((value){
                    localStorage.deleteData('isLogin').then((value) {
                     Navigator.of(context).pushNamed(RoutesName.loginScreen);
                    });
                  });
                  },
                    icon: Icon(Icons.logout)),
              ],
      ),
             body: BlocProvider(
               create: (_) => _movieBloc..add(MoviesFetch()),
               child: BlocBuilder<MovieBloc,MovieState>(
                 builder: (context,state){
                   switch(state.movieModel.status){
                     case Status.loading:
                       return Center(
                         child: CircularProgressIndicator(),
                       );

                     case Status.error:
                       return HomeErrorWidget();

                     case Status.completed:
                       return MoviesListWidget();

                     default:
                       return SizedBox();
                   }

                 },
               ),
             ),
    );
  }
}
