import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:uno/uno.dart';
import 'api_key.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'MaiTai'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController textController = TextEditingController();

  var url = 'https://words.bighugelabs.com/api/2/';
  var secretKey = MY_KEY;
  var myText = '';
  var url2 = '/json';
  var lastSearch = "";

  final uno = Uno();

  List<String> adjList = [];
  List<String> nList = [];
  List<String> advList = [];
  List<String> vList = [];
  List nounList = [];
  List adjectiveList = [];
  List adverbList = [];
  List verbList = [];

  String filter = 'adj';
  String type = 'enter a word and search';

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future getWords() async {
    myText = textController.text;
    var mySnack =
        const SnackBar(content: Text("Enter a word before searching"));

    if (myText.isNotEmpty) {
      if(lastSearch != myText){
        clearAllLists();
        lastSearch = myText;
        uno.get(url + secretKey + myText + url2).then((response) {
          checkResponseKeys(response);
          checkLongestList();

          setState(() {
            adjList;
            nList;
            advList;
            vList;
            type;
          });
        }).catchError((error) {
          print('uno error $error'); // It's a UnoError.
          lastSearch = "";
          showConnectionDialog(context);

        });
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(mySnack);
    }
  }

  //*****UI Section*****
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              showAlertDialog(context);
            },
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'App Info',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: textController,
                  onSubmitted: (String value) async {
                    myText.toString();
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Search',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Visibility(
                      visible: adjectiveList.isNotEmpty ? true : false,
                      child: OutlinedButton(
                          onPressed: () {
                            filter = 'adj';
                            type = 'Adjectives';
                            setState(() {});
                          },

                          child: const Text(
                            'Adjective',
                            style: TextStyle(color: Colors.deepPurple),

                          )),
                    ),
                    SizedBox(
                      width: 110,
                      child: Visibility(
                        visible: nounList.isNotEmpty ? true : false,
                        child: OutlinedButton(
                            onPressed: () {
                              filter = 'noun';
                              type = 'Nouns';
                              setState(() {});
                            },
                            child: const Text(
                              'Noun',
                              style: TextStyle(color: Colors.deepPurple),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Visibility(
                        visible: verbList.isNotEmpty ? true : false,
                        child: OutlinedButton(
                            onPressed: () {
                              filter = 'verb';
                              type = 'Verbs';
                              setState(() {});
                            },
                            child: const Text(
                              'Verb',
                              style: TextStyle(color: Colors.deepPurple),
                            )),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: Visibility(
                        visible: adverbList.isNotEmpty ? true : false,
                        child: OutlinedButton(
                          onPressed: () {
                            filter = 'adv';
                            type = 'Adverbs';
                            setState(() {});
                          },
                          child: const Text(
                            'Adverb',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  type,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                  child: ListView.separated(
                shrinkWrap: true,
                itemCount: getWordListLength(type),
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, int index) {
                  return ListTile(
                    title: SelectableText(
                      getWordList(type)[index],
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                },
              ))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          setState(() {
            getWords();
          });
        },
        tooltip: 'Search',
        child: const Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //*****Utility Functions*******

  void clearText() {
    textController.clear();
  }

  int getWordListLength(type) {
    int myLength;

    if (type == 'Nouns') {
      myLength = nList.length;
    } else if (type == 'Verbs') {
      myLength = vList.length;
    } else if (type == 'Adverbs') {
      myLength = advList.length;
    } else {
      myLength = adjList.length;
    }

    return myLength;
  }

  List getWordList(type) {
    List myListType;

    if (type == 'Nouns') {
      myListType = nList;
    } else if (type == 'Verbs') {
      myListType = vList;
    } else if (type == 'Adverbs') {
      myListType = advList;
    } else {
      myListType = adjList;
    }

    return myListType;
  }

  void checkLongestList() {
    if (adjList.length >= advList.length &&
        adjList.length >= nList.length &&
        adjList.length >= vList.length) {
      filter = 'adj';
      type = 'Adjectives';
    }

    if (advList.length >= adjList.length &&
        advList.length >= nList.length &&
        advList.length >= vList.length) {
      filter = 'adv';
      type = 'Adverbs';
    }

    if (nList.length >= advList.length &&
        nList.length >= adjList.length &&
        nList.length >= vList.length) {
      filter = 'noun';
      type = 'Nouns';
    }

    if (vList.length >= advList.length &&
        vList.length >= adjList.length &&
        vList.length >= nList.length) {
      filter = 'verb';
      type = 'Verbs';
    }
  }

  void checkResponseKeys(response) {
    if (response.data.containsKey('noun')) {
      nounList = response.data['noun']['syn'] as List;
      for (var word in nounList) {
        nList.add(word);
      }
    } else {
      nList.add('No Nouns');
    }

    if (response.data.containsKey('adjective')) {
      adjectiveList = response.data['adjective']['syn'] as List;
      for (var word in adjectiveList) {
        adjList.add(word);
      }
    } else {
      adjList.add('No Adjectives');
    }

    if (response.data.containsKey('adverb')) {
      adverbList = response.data['adverb']['syn'] as List;
      for (var word in adverbList) {
        advList.add(word);
      }
    } else {
      advList.add('No Adverbs');
    }

    if (response.data.containsKey('verb')) {
      verbList = response.data['verb']['syn'] as List;
      for (var word in verbList) {
        vList.add(word);
      }
    } else {
      vList.add('No Verbs');
    }
  }

  void clearAllLists() {
    adjList.clear();
    nList.clear();
    advList.clear();
    vList.clear();
    nounList.clear();
    adjectiveList.clear();
    verbList.clear();
    adverbList.clear();
  }

  void showAlertDialog(context) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: const Text('MaiTai v.3.0.0'),
              content: const Text('Ilocode 2024'),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'))
              ],
            ));
  }

  void showConnectionDialog(context) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Cannot Connect'),
          content: const Text('Please check your internet connection'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'))
          ],
        ));
  }
}
