import 'package:flutter/material.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:weather_app/screens/weekly_weather_screen.dart';

import '../models/weekly_weather_model.dart';
import '../widgets/weekly_weather.dart';

class TriHourWeather extends StatefulWidget {
  final List<WeeklyWeatherModel> weeklyWeatherModel;

  const TriHourWeather({Key? key, required this.weeklyWeatherModel}) : super(key: key);

  @override
  State<TriHourWeather> createState() => _TriHourWeatherState();
}

class _TriHourWeatherState extends State<TriHourWeather> {
  late final List<WeeklyWeatherModel> _weeklyWeatherModel = widget.weeklyWeatherModel;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return ScaffoldGradientBackground(
      resizeToAvoidBottomInset: false,
      gradient: const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFF8EC5FC),
          Color(0xFFE0C3FC),
        ],
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCB9FC),
        title: const Text("Weather companion"),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        children: [
          ..._weeklyWeatherModel.map(
            (model) => WeeklyWeather(weeklyWeatherModel: model),
          )
        ],
      ),
    );
  }
}

// // child: NotificationListener<ScrollNotification>(
// //   onNotification: (notification) {
// //     if (notification
// //             is ScrollUpdateNotification &&
// //         _listScrollController.position.pixels ==
// //             -1) {
// //       _pageController.previousPage(
// //           duration:
// //               const Duration(milliseconds: 300),
// //           curve: Curves.ease);
// //     }
// //     return false;
// //   },
//   child: ListView.builder(
//     controller: _listScrollController,
//     physics: const BouncingScrollPhysics(),
//     // itemCount: _weeklyWeatherModel?.length,
//     itemCount: _combinedWeatherModel
//         ?.weeklyWeatherModel?.length,
//     itemBuilder: (context, index) {
//       String date = DateFormat("d.M").format(
//           // _weeklyWeatherModel![index].dt!);
//           _combinedWeatherModel!
//               .weeklyWeatherModel![index].dt!);
//       String time = DateFormat("HH:mm").format(
//           // _weeklyWeatherModel![index].dt!);
//           _combinedWeatherModel!
//               .weeklyWeatherModel![index].dt!);
//       String day = DateFormat("EEEE").format(
//           // _weeklyWeatherModel![index].dt!);
//           _combinedWeatherModel!
//               .weeklyWeatherModel![index].dt!);
//
//       return Card(
//         child: ListTile(
//           title: Text("$date, $time"),
//           subtitle: Text(day),
//           // "${_weeklyWeatherModel?[index].dt_txt}"),
//         ),
//       );
//     },
//   ),
// ),
