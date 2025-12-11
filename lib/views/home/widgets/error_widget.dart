import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/movies/movie_bloc.dart';
import '../../../res/components/internet_Excepton.dart';

class HomeErrorWidget extends StatelessWidget {
  const HomeErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieBloc,MovieState>
      (builder: (context,state){
      if(state.movieModel.message!.contains('No Internet Connection')){
        return Center(
          child: InternetExcepton(onPress:(){
            context.read<MovieBloc>().add(MoviesFetch());
          }),
        );
      }

      return Center(
        child: Text(state.movieModel.message.toString()),
      );
    });
  }
}
