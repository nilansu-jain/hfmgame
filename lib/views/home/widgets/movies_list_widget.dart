import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/movies/movie_bloc.dart';

class MoviesListWidget extends StatelessWidget {
  const MoviesListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieBloc,MovieState>(builder: (context,state){
      if(state.movieModel.data == null){
        return Center(child: Text("No Data Found"),);
      }
      final movies = state.movieModel.data!;
      return ListView.builder(
          itemCount: movies.tvShow.length ,
          itemBuilder: (context,index){
            var tvshow = movies.tvShow[index];
            return ListTile(
              title:Text( tvshow.name.toString()),
              subtitle: Text(tvshow.network.toString()+" : "+ tvshow.country.toString()),
              trailing: Text(tvshow.status.toString()),
              leading: Image(image: NetworkImage(tvshow.imageThumbnailPath)),
            );
          });
    });
  }
}
