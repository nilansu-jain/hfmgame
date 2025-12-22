import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../exception/app_exceptions.dart';
import 'base_api_services.dart';

class Networkapiservices extends BaseApiServices{
  final Dio dio = Dio();

  @override
  Future<dynamic> getApi(String url) async{
    dynamic jsonResponse;
    try{
      var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));

      jsonResponse = returnResponse(response);

      return jsonResponse;
    }on SocketException{
      throw NoInternetException('');
    }on TimeoutException{
      throw RequestTimeOutException("Time Out");
    }
  }

  @override
  Future<dynamic> deleteApi(String url) async{
    dynamic jsonResponse;
    try{
      var response = await http.delete(Uri.parse(url)).timeout(const Duration(seconds: 30));

      jsonResponse = returnResponse(response);
      return jsonResponse;
      // if(response.statusCode == 200){}
    }on SocketException{
      throw NoInternetException('');
    }on TimeoutException{
      throw RequestTimeOutException("Time Out");
    }
  }

  @override
  Future<dynamic> postApi(String url, var data,{var header}) async{
    dynamic jsonResponse;
    try{
      if(kDebugMode) {
        print("URL ::: $url");
        print("Params :: $data");
        print("Header :: $header");
      }
      var response = await http.post(Uri.parse(url),
      body: data,
      headers: header).timeout(const Duration(seconds: 30));

      jsonResponse = returnResponse(response);

      if(kDebugMode){
        print("Response :: ${response.body}");
      }
      return jsonResponse;
      if(response.statusCode == 200){}
    }on SocketException{
      throw NoInternetException('');
    }on TimeoutException{
      throw RequestTimeOutException("Time Out");
    }
  }

  Future<dynamic> postMultipartApi(
      String url,
      FormData formData,
      ) async {
    final response = await dio.post(
      url,
      data: formData,
      options: Options(
        headers: {
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    return response.data;
  }

  dynamic returnResponse(http.Response response){
    switch(response.statusCode){
      case 200:
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse;

      case 400:
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse;

      case 401:
        throw UnauthorisedException("Unauthorised");

      case 500:
        throw FetchDataException("Error while fetching data");

      default:
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse;
    }
  }

}