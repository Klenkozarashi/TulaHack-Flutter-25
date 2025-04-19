import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_flut/presentation/tasks_list.dart';

class Beginning extends StatefulWidget {
  const Beginning({Key? key}) : super(key: key);

  @override
  State<Beginning> createState() => _BeginningState();
}

class _BeginningState extends State<Beginning> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Масштаб для volna зависит напрямую от ширины экрана
    final double volnaScale = screenWidth / screenWidth;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(39, 41, 39, 1),
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Transform.scale(
                scale: volnaScale,
                child: SvgPicture.asset(
                  "assets/svg/volna2-01.svg",
                  width: screenWidth * 1.2,
                  height: screenHeight * 0.5,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/SQL2-01.svg',
                        width: screenWidth * 0.7,
                        height: screenHeight * 0.2,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Ваше интерактивное обучение начинается здесь!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontFamily: "Jost",
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Учитесь работать с базами данных интересно. Присоединяйтесь!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontFamily: "Jost",
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.1),
                      MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TaskListPage()),
                          );
                        },
                        color: const Color.fromRGBO(253, 253, 253, 1),
                        minWidth: screenWidth * 0.7,
                        height: 70,
                        shape: const StadiumBorder(),
                        child: Text(
                          "Начать обучение",
                          style: TextStyle(
                            color: const Color.fromRGBO(183, 88, 255, 1),
                            fontSize: screenWidth * 0.055,
                            fontFamily: "Jost",
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
