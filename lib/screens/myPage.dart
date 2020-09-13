import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        home: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/img/background.png"),
                  fit: BoxFit.cover)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text('마이페이지'),
              centerTitle: true,
              leading: new IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

            ),
            body:Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(

                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text("총 복습률",style: TextStyle(fontSize: 14,color:Colors.white)),
                            Text("90%",style: TextStyle(fontSize: 30,color:Colors.white))
                          ],
                        ),

                        Image.asset('assets/img/badge5.png')
                      ],
                    ),
                  )
                ],
              ),
            )
          ),
        ));
    //body:
  }
}
