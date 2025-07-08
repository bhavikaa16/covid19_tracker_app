import 'package:covid_tracker/View/stateslist.dart';
import 'package:covid_tracker/model/statesModel.dart';
import 'package:covid_tracker/services/stats_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pie_chart/pie_chart.dart';

class WorldStatsScreen extends StatefulWidget {
  const WorldStatsScreen({Key? key}): super(key:key);

  @override
  State<WorldStatsScreen> createState() => _WorldStatsScreenState();
}

class _WorldStatsScreenState extends State<WorldStatsScreen>with TickerProviderStateMixin {
 late final AnimationController _controller=AnimationController(
   duration: const Duration(seconds: 3),
     vsync: this)..repeat();
 final colorList=<Color>[
   const Color(0xff4285F4),
   const Color(0xff1aa260),
   const Color(0xffde5246),

 ];

  @override
  Widget build(BuildContext context) {
    StatesServices statesServices= StatesServices();
    return Scaffold(
      body: SafeArea(child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*.01,),
          Expanded(
            child: FutureBuilder(future: statesServices.fetchrecords(), builder: (context,AsyncSnapshot<StatesModel>snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: SpinKitFadingCircle(
                    color: Colors.white,
                    size: 50.0,
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Text('Error loading data\n${snapshot.error ?? 'No data'}'),
                );
              }else{
                return SingleChildScrollView(
                  child: Column
                  (children: [
                  PieChart(dataMap: {
                    "Total": double.parse(snapshot.data!.total!.cases.toString()),
                    "Recovered": double.parse(snapshot.data!.total!.recovered.toString()),
                    "Deaths": double.parse(snapshot.data!.total!.deaths.toString()),
                  },
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValuesInPercentage: true
                    ),
                    chartRadius: MediaQuery.of(context).size.width/3.2,
                    legendOptions: const LegendOptions(
                        legendPosition: LegendPosition.left
                    ),
                    animationDuration: const Duration(milliseconds: 1200),
                    chartType: ChartType.ring,
                    colorList: colorList,
                  
                  ),
                  Padding(
                    padding:  EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*.06),
                    child: Card(
                      child: Column(
                        children: [
                          ReusableRow(title:'Total' , value: snapshot.data!.total!.cases.toString()),
                                ReusableRow(title:'Deaths' , value: snapshot.data!.total!.deaths.toString()),
                                ReusableRow(title:'Recovered' , value: snapshot.data!.total!.recovered.toString()),
                  
                                ReusableRow(title:'active' , value: snapshot.data!.total!.active.toString()),
                          ReusableRow(title:'Today Active' , value: snapshot.data!.total!.todayActive.toString()),
                  
                          ReusableRow(title:'Today Recovered' , value: snapshot.data!.total!.todayRecovered.toString()),
                                ReusableRow(title:'Today Deaths' , value: snapshot.data!.total!.todayDeaths.toString()),
                  
                                ],
                      ),
                    ),
                  ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StatesListScreen()),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xff1aa260),
                        ),
                        child: const Center(
                          child: Text(
                            'Track States',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],),
                );

              }



            }),
          ),

        ],
      )),
    );
  }
}

class ReusableRow extends StatelessWidget {
  String title,value;
ReusableRow({Key?key, required this.title,required this.value}): super(key:key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left:10,right: 10,top:5,bottom: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title),Text(value),],
          ),
          SizedBox(height: 5,),
          Divider(),
        ],
      ),
    );
  }
}
