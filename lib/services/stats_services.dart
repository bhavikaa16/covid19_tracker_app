
import 'dart:convert';

import 'package:covid_tracker/services/app_url.dart';
import 'package:http/http.dart' as http;

import '../model/statesModel.dart';

class StatesServices{
  Future<StatesModel> fetchrecords() async{
    final response = await http.get(Uri.parse(Appurl.IndianStatsApi));
    if(response.statusCode==200){
      var data = jsonDecode(response.body);
      return StatesModel.fromJson(data);
    }
    else{
      throw Exception('Error');
    }


  }

}