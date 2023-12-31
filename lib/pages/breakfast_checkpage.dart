import 'package:breakfast_check/models/input_form.dart';
import 'package:breakfast_check/models/mode_state.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BreakfastCheckPage extends StatefulWidget {
  const BreakfastCheckPage({super.key});

  @override
  BreakfastCheckPageState createState() => BreakfastCheckPageState();
}

class BreakfastCheckPageState extends State<BreakfastCheckPage> {
  late final Box<InputForm> box;
  final List<InputForm> users = [
    InputForm(name: '유현명', enName: 'Hyun', isCheck: false),
    InputForm(name: '김민채', enName: 'David', isCheck: false),
    InputForm(name: 'adbr', enName: 'bora', isCheck: false),
  ];

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  _openBox() async {
    box = await Hive.openBox<InputForm>('checks');
    _loadChecks();
  }

  _loadChecks() {
    if (box.isNotEmpty) {
      users.clear();
      users.addAll(box.values);
    } else {
      for (var user in users) {
        box.add(user);
      }
    }
    setState(() {});
  }

  _saveCheck(int index, bool value) {
    var user = box.getAt(index);
    if (user != null) {
      user.isCheck = value;
      if (value) {
        user.checkedTime = DateTime.now();
      } else {
        user.checkedTime = null;
      }
      box.putAt(index, user);
    }
  }

  void clickCheckBox(int index, bool? value) {
    if (value != null) {
      setState(() {});
      users[index].isCheck = value;
      _saveCheck(index, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => ModeState()))
      ],
      child: Consumer<ModeState>(
        builder: (BuildContext context, ModeState modeState, Widget? child) { 
          return MaterialApp(
            title: '조식 체크 앱',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            darkTheme: ThemeData.dark(),
            themeMode: context.watch<ModeState>().isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: Scaffold(
              appBar: AppBar(
                title: const Text(
                  '조식 체크 앱',
                  style: TextStyle(fontFamily: 'Jalnan2'),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.dark_mode),
                    onPressed: () {
                      setState(() {
                        context.read<ModeState>().changeLight();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.language),
                    onPressed: () {
                      setState(() {
                        context.read<ModeState>().changeLanguage();
                      });
                    },
                  ),
                ],
              ),
              body: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      context.read<ModeState>().isEnglishMode ? users[index].enName : users[index].name,
                      style: const TextStyle(fontFamily: 'Jalnan2'),
                    ),
                    leading: Checkbox(
                      value: users[index].isCheck,
                      onChanged: (value) => clickCheckBox(index, value),
                    ),
                    trailing: users[index].isCheck && users[index].checkedTime != null
                        ? Text(DateFormat(
                            context.watch<ModeState>().isEnglishMode ? 'EEE dd MM\n yyyy h:mm:ss a' : 'yyyy년 MM월 dd일 (E)\n a HH시 mm분 ss초',
                            context.watch<ModeState>().isEnglishMode ? 'en_US' : 'ko_KR').format(users[index].checkedTime!))
                        : null,
                  );
                },
              ),
            ),
          );
        }
      ),
    );
  }
}