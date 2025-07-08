import 'package:covid_tracker/View/statestats.dart';
import 'package:covid_tracker/services/stats_services.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../model/statesModel.dart';

class StatesListScreen extends StatefulWidget {
  const StatesListScreen({Key? key}) : super(key: key);

  @override
  _StatesListScreenState createState() => _StatesListScreenState();
}

class  _StatesListScreenState extends State<StatesListScreen> {

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    StatesModel newsListViewModel = StatesModel();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  hintText: 'Search with state name',
                  suffixIcon: searchController.text.isEmpty ? const Icon(Icons.search) :
                  GestureDetector(
                      onTap: (){
                        searchController.text = "" ;
                        setState(() {
                        });
                      },
                      child: Icon(Icons.clear)),

                ),
                onChanged: (value){
                  setState(() {

                  });
                },
              ),

            ),
    Expanded(
    child: FutureBuilder<List<States>>(
    future: StatesServices().fetchStates(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return ListView.builder(
    itemCount: 4,
    itemBuilder: (_, __) => Shimmer.fromColors(
    baseColor: Colors.grey.shade700,
    highlightColor: Colors.grey.shade100,
    child: const ListTile(
    leading:  CircleAvatar(radius: 25, backgroundColor: Colors.white),
    title:    SizedBox(height: 8, width: 120, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white))),
    subtitle: SizedBox(height: 8, width: double.infinity, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white))),
    ),
    ),
    );
    }

    // -- error ------------------------------------------------------------
    if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}'));
    }

    final states = snapshot.data ?? <States>[];
    final query  = searchController.text.toLowerCase();
    final filteredStates = query.isEmpty
    ? states
        : states.where((s) => (s.state ?? '').toLowerCase().contains(query)).toList();

    if (filteredStates.isEmpty) {
    return const Center(child: Text('No states found.'));
    }


    return ListView.separated(
      itemCount: filteredStates.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final s = filteredStates[index];
        return ListTile(
          title: Text(s.state ?? 'Unknown'),
          subtitle: Text('Cases: ${s.cases ?? 0}'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StatesStats(
                name: s.state ?? '',
                totalCases: s.cases ?? 0,
                totalDeaths: s.deaths ?? 0,
                totalRecovered: s.recovered ?? 0,
                active: s.active ?? 0,
                todayCases: s.todayCases ?? 0,
                todayDeaths: s.todayDeaths ?? 0,
                todayRecovered: s.todayRecovered ?? 0,
                todayActive: s.todayActive ?? 0,
              ),
            ),
          ),
        );
      },
    );
    },
    ),
    ),
          ],
        ),
      ),
    );
  }
}
