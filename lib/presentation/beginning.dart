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
    return Scaffold(
      backgroundColor: Color.fromRGBO(39, 41, 39, 1),
      body: Stack(children: [
        Transform.translate(
            offset: Offset(-9, 400),
            child: Transform.rotate(
                angle: 0,
                child: Transform.scale(
                  scale: 1.65,
                  child: SvgPicture.asset(
                    "assets/svg/volna-01.svg",
                    width: 684,
                    height: 585,
                  ),
                ))),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/SQL2-01.svg',
              width: 469,
              height: 186,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, bottom: 30),
              child: Flexible(
                  child: Text(
                "Ваше интерактивное обучение начинается здесь!",
                style: TextStyle(
                    fontSize: 36,
                    fontFamily: "Jost",
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              )),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, bottom: 100),
              child: Flexible(
                  child: Text(
                "Учитесь работать с базами данных интересно. Присоединяйтесь!",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Jost",
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              )),
            ),
            SizedBox(height: 130),
            MaterialButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TaskListPage()));
              },
              color: Color.fromRGBO(253, 253, 253, 1),
              minWidth: 280,
              height: 80,
              shape: StadiumBorder(),
              child: Text(
                "Начать обучение",
                style: TextStyle(
                    color: Color.fromRGBO(183, 88, 255, 1),
                    fontSize: 23,
                    fontFamily: "Jost",
                    fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
