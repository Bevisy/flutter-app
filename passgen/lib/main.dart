import 'package:flutter/material.dart';
import 'dart:math';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'passgen',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RandomPasswordGenerator(title: 'Password Generator'),
    );
  }
}

class RandomPasswordGenerator extends StatefulWidget {
  const RandomPasswordGenerator({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<RandomPasswordGenerator> createState() =>
      _RandomPasswordGeneratorState();
}

class _RandomPasswordGeneratorState extends State<RandomPasswordGenerator> {
  String _password = '';
  int _length = 12;
  bool _includeSpecialChars = false;
  String _specialChars = '!@#\$%^&*()_+';
  bool _copied = false;

  String generateRandomString(
      int length, bool includeSpecialChars, String specialChars) {
    final rand = Random();
    final codeUnits = List.generate(length, (index) {
      final n =
          rand.nextInt(62 + (includeSpecialChars ? specialChars.length : 0));
      if (n < 10) {
        return n + 48;
      } else if (n < 36) {
        return n + 55;
      } else if (n < 62) {
        return n + 61;
      } else {
        return specialChars.codeUnitAt(n - 62);
      }
    });

    return String.fromCharCodes(codeUnits);
  }

  void _copyToClipboard() {
    FlutterClipboard.copy(_password).then((value) {
      setState(() {
        _copied = true;
      });
      Future.delayed(Duration(milliseconds: 1200), () {
        setState(() {
          _copied = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the RandomPasswordGenerator object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Include Special Characters: '),
                SizedBox(
                  width: 16,
                ),
                Switch(
                  value: _includeSpecialChars,
                  onChanged: (value) {
                    setState(() {
                      _includeSpecialChars = value;
                    });
                  },
                ),
              ],
            ),
            if (_includeSpecialChars)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  Text('Special Characters: '),
                  SizedBox(
                    width: 16,
                  ),
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      initialValue: _specialChars,
                      onChanged: (value) {
                        setState(() {
                          _specialChars = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Password Length: '),
                SizedBox(
                  width: 16,
                ),
                SizedBox(
                  width: 50,
                  child: TextFormField(
                    initialValue: _length.toString(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      int length = int.tryParse(value) ?? 12;
                      setState(() {
                        _length = length;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_length < 4 || _length > 32) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Password length must be between 4 and 32.'),
                          ),
                        );
                        _password = '';
                      } else {
                        _password = generateRandomString(
                            _length, _includeSpecialChars, _specialChars);
                      }
                    });
                  },
                  icon: Icon(Icons.casino_outlined),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Wrap(
                    children: [
                      Text(
                        _password,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                if (_password != '')
                  IconButton(
                    onPressed: _copyToClipboard,
                    icon: Icon(
                      Icons.copy,
                    ),
                    color:
                        _copied ? Theme.of(context).colorScheme.primary : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
