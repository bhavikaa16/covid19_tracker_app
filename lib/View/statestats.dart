import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatesStats extends StatefulWidget {

  final String name;
  final int totalCases;
  final int totalDeaths;
  final int totalRecovered;
  final int active;
  final int todayCases;
  final int todayDeaths;
  final int todayRecovered;
  final int todayActive;

   const StatesStats
       ({
    required this.name ,
    required this.totalCases,
    required this.totalDeaths,
    required this.totalRecovered,
    required this.active,
     required this.todayCases,
     required this.todayDeaths,
     required this.todayRecovered,
     required this.todayActive,


   }) ;

  @override
  _StatesStatsState createState() => _StatesStatsState ();
}

class _StatesStatsState  extends State<StatesStats>{
  final formatter = NumberFormat.decimalPattern();


  @override
  Widget build(BuildContext context) {
    Widget row(String title, int value) {
      return ReusableRow(title: title, value: formatter.format(value));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [


              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      row('Total Cases', widget.totalCases),
                      row('Active', widget.active),
                      row('Recovered', widget.totalRecovered),
                      row('Deaths', widget.totalDeaths),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      row("Today's Cases", widget.todayCases),
                      row("Today's Active", widget.todayActive),
                      row("Today's Recovered", widget.todayRecovered),
                      row("Today's Deaths", widget.todayDeaths),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReusableRow extends StatelessWidget {
  final String title, value;

  const ReusableRow({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(value),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(height: 1),
        ],
      ),
    );
  }
}