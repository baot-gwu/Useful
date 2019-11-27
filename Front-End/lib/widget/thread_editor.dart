import 'package:flutter/material.dart';
import 'package:useful/colors.dart';
import 'package:useful/app.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

class CreateThreadEditorPage extends StatefulWidget {
  final int fid;
  final Map<String, dynamic> widgets;

  const CreateThreadEditorPage({
    Key key,
    @required this.fid,
    @required this.widgets,
  })  : assert(fid != null),
        assert(widgets != null),
        super(key: key);

  @override
  _CreateThreadEditorPageState createState() =>
      new _CreateThreadEditorPageState();
}

class _CreateThreadEditorPageState extends State<CreateThreadEditorPage> {
  int fid;
  Map<String, dynamic> widgets;

  void initState() {
    super.initState();
    fid = widget.fid;
    widgets = widget.widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a new Thread'),
      ),
      body: Hero(
        tag: 'newThread-${fid.toString()}',
        child: new ThreadEditorBody(
            fid: fid,
            tid: 0,
            topic: '',
            abstract: {'announcement': {}, 'shortMessage': ''},
            body: {'content': ''},
            widgets: widgets),
      ),
    );
  }
}

class EditThreadEditorPage extends StatefulWidget {
  final int fid;
  final int tid;
  final Map<String, dynamic> widgets;

  const EditThreadEditorPage({
    Key key,
    @required this.fid,
    @required this.tid,
    @required this.widgets,
  })  : assert(fid != null),
        assert(tid != null),
        assert(widgets != null),
        super(key: key);

  @override
  _EditThreadEditorPageState createState() => new _EditThreadEditorPageState();
}

class _EditThreadEditorPageState extends State<EditThreadEditorPage> {
  int fid;
  int tid;
  String topic;
  Map<String, dynamic> abstract;
  Map<String, dynamic> body;
  Map<String, dynamic> widgets;

//  Widget _defaultEditor;
  Widget _newEditor;

  void initState() {
    super.initState();
    fid = widget.fid;
    tid = widget.tid;
    widgets = widget.widgets;
//    _defaultEditor = ThreadEditorBody(
//        fid: fid,
//        tid: tid,
//        topic: '',
//        abstract: {'announcement': {}, 'shortMessage': ''},
//        body: {'content': ''},
//        widgets: widgets);
//    _newEditor = _defaultEditor;
    _fetchData();
  }

  _fetchData() async {
    await http.get(
      '$forumApi/$fid$threadApi/$tid',
      headers: {'Authorization': 'Bearer $globalUserToken'},
    ).then((response) {
      debugPrint(
          'Info: Thread Info Card ${fid.toString()} Respond: ${response.statusCode} ${response.body.toString()}');
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        topic = data['data']['topic'];
        abstract = data['data']['abstract'];
        body = data['data']['body'];
      } else if (response.statusCode == 201) {
        debugPrint('[Thread Info Card]: Your login status is expired');
      } else if (!httpCodes.contains(response.statusCode)) {
        debugPrint(
            '[Thread Info Card]: Please check your network connection and try again later');
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        debugPrint('[Thread Info Card]: ${data['msg']}');
      }
    }).catchError((error) {
      debugPrint('[Thread Info Card]: $error');
    });
    _newEditor = new ThreadEditorBody(
        fid: fid,
        tid: tid,
        topic: topic,
        abstract: abstract,
        body: body,
        widgets: widgets);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Thread - tid:${tid.toString()}'),
      ),
      body: Hero(
        tag: 'editThread-${fid.toString()}',
        child: (_newEditor == null)
            ? Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 10.0),
                      Text("Loading..."),
                    ],
                  ),
                ),
              )
            : _newEditor,
      ),
    );
  }
}

class ThreadEditorBody extends StatefulWidget {
  final int fid;
  final int tid;
  final String topic;
  final Map<String, dynamic> abstract;
  final Map<String, dynamic> body;
  final Map<String, dynamic> widgets;

  const ThreadEditorBody({
    Key key,
    @required this.fid,
    @required this.tid,
    @required this.topic,
    @required this.abstract,
    @required this.body,
    @required this.widgets,
  })  : assert(fid != null),
        assert(tid != null),
        assert(topic != null),
        assert(abstract != null),
        assert(body != null),
        assert(widgets != null),
        super(key: key);

  @override
  _ThreadEditorBodyState createState() => new _ThreadEditorBodyState();
}

class _ThreadEditorBodyState extends State<ThreadEditorBody> {
  int fid;
  int tid;
  String topic;
  Map<String, dynamic> abstract;
  Map<String, dynamic> body;
  Map<String, dynamic> widgets;
  final _threadTitleController = new TextEditingController();
  final _threadBodyController = new TextEditingController();
  final Map<String, TextEditingController> _threadWidgetsController = {};

  void initState() {
    super.initState();
    fid = widget.fid;
    tid = widget.tid;
    topic = widget.topic;
    abstract = widget.abstract;
    body = widget.body;
    widgets = widget.widgets;
    _threadTitleController.text = topic;
    _threadBodyController.text = body['content'];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetsList = [];
    widgets.forEach((widgetName, widgetType) {
      if (widgetType.toString() == 'text' || widgetType.toString() == 'time') {
        _threadWidgetsController[widgetName] = new TextEditingController();
        _threadWidgetsController[widgetName].text =
            (abstract['announcement'][widgetName] == null)
                ? ''
                : abstract['announcement'][widgetName];
        _widgetsList.add(
          AccentColorOverride(
            color: gwuBlue,
            child: TextField(
              controller: _threadWidgetsController[widgetName],
              maxLength: 50,
              decoration: InputDecoration(
                labelText: widgetName,
              ),
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            AccentColorOverride(
              color: gwuBlue,
              child: TextField(
                controller: _threadTitleController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Thread Title',
                ),
              ),
            ),
            AccentColorOverride(
              color: gwuBlue,
              child: TextField(
                controller: _threadBodyController,
                keyboardType: TextInputType.multiline,
                maxLines: 15,
                decoration: InputDecoration(
                  labelText: 'Body',
                ),
              ),
            ),
            Divider(),
            Text('Tags:'),
            SizedBox(
              height: 10.0,
            ),
            Column(
              children: _widgetsList,
            ),
            SizedBox(
              width: double.infinity, // match_parent
              child: RaisedButton(
                child: (tid == 0) ? Text('Submit') : Text('Update'),
                onPressed: () {
                  if (tid == 0)
                    _submit();
                  else
                    _update();
                  //Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _submit() async {
    Text _tip;
    String checkWidgetsControllerResult;
    _threadWidgetsController.forEach((widgetName, widgetContentController) {
      if (widgetContentController.text == '') {
        checkWidgetsControllerResult = widgetName;
      }
    });
    if (_threadTitleController.text == '') {
      _tip = Text('Please input the Title');
    } else if (checkWidgetsControllerResult != null) {
      _tip = Text(checkWidgetsControllerResult);
    }

    final snackBar = SnackBar(
      content: (_tip == null) ? Text('Posting the Thread') : _tip,
      backgroundColor: gwuBlue,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: gwuFlax,
        onPressed: () {},
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);

    debugPrint(_tip.toString());

    if (_tip.toString() == 'null') {
      Map<String, dynamic> _widgetsData = Map();
      _threadWidgetsController.forEach((widgetName, widgetContentController) {
        _widgetsData[widgetName] = widgetContentController.text;
      });
      await http
          .post('$forumApi/$fid$threadApi',
              headers: {
                'Authorization': 'Bearer $globalUserToken',
                'Content-Type': 'application/json'
              },
              body: json.encode({
                'topic': _threadTitleController.text,
                'abstract': {
                  'announcement': _widgetsData,
                  'shortMessage': _threadBodyController.text.substring(
                      0,
                      (_threadBodyController.text.length >= 30)
                          ? 30
                          : _threadBodyController.text.length)
                },
                'body': {'content': _threadBodyController.text}
              }))
          .then((response) {
        debugPrint("Response: \n ${response.statusCode}\n${response.body}");
        if (response.statusCode == 200) {
          forumBus.fire(fid.toString());
          final snackBar = SnackBar(
              content: Text('Success!'),
              backgroundColor: gwuBlue,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: gwuFlax,
                onPressed: () {},
              ));

          Scaffold.of(context)
              .showSnackBar(snackBar)
              .closed
              .then((SnackBarClosedReason reason) {
            Navigator.pop(context);
          });
        } else {
          if (response.statusCode == 201) {
            final snackBar = SnackBar(
                content: Text('Your login status is expired'),
                backgroundColor: gwuBlue,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: gwuFlax,
                  onPressed: () {},
                ));

            Scaffold.of(context).showSnackBar(snackBar);
          } else if (!httpCodes.contains(response.statusCode)) {
            final snackBar = SnackBar(
              content: Text(
                  'Please check your network connection and try again later'),
              backgroundColor: gwuBlue,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: gwuFlax,
                onPressed: () {},
              ),
            );

            Scaffold.of(context).showSnackBar(snackBar);
          } else {
            final Map<String, dynamic> data = json.decode(response.body);
            final snackBar = SnackBar(
                content: Text('${data['msg']}'),
                backgroundColor: gwuBlue,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: gwuFlax,
                  onPressed: () {},
                ));

            Scaffold.of(context).showSnackBar(snackBar);
          }
        }
      }).catchError((error) {
        debugPrint(error.toString());
        final snackBar = SnackBar(
          content:
              Text('Please check your network connection and try again later'),
          backgroundColor: gwuBlue,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: gwuFlax,
            onPressed: () {},
          ),
        );

        Scaffold.of(context).showSnackBar(snackBar);
      });
    }
  }

  _update() async {
    Text _tip;
    String checkWidgetsControllerResult;
    _threadWidgetsController.forEach((widgetName, widgetContentController) {
      if (widgetContentController.text == '') {
        checkWidgetsControllerResult = widgetName;
      }
    });
    if (_threadTitleController.text == '') {
      _tip = Text('Please input the Title');
    } else if (checkWidgetsControllerResult != null) {
      _tip = Text(checkWidgetsControllerResult);
    }

    final snackBar = SnackBar(
      content: (_tip == null) ? Text('Updating the Thread') : _tip,
      backgroundColor: gwuBlue,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: gwuFlax,
        onPressed: () {},
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);

    debugPrint(_tip.toString());

    if (_tip.toString() == 'null') {
      Map<String, dynamic> _widgetsData = Map();
      _threadWidgetsController.forEach((widgetName, widgetContentController) {
        _widgetsData[widgetName] = widgetContentController.text;
      });
      await http
          .put('$forumApi/$fid$threadApi/$tid',
          headers: {
            'Authorization': 'Bearer $globalUserToken',
            'Content-Type': 'application/json'
          },
          body: json.encode({
            'topic': _threadTitleController.text,
            'abstract': {
              'announcement': _widgetsData,
              'shortMessage': _threadBodyController.text.substring(
                  0,
                  (_threadBodyController.text.length >= 30)
                      ? 30
                      : _threadBodyController.text.length)
            },
            'body': {'content': _threadBodyController.text}
          }))
          .then((response) {
        debugPrint("Response: \n ${response.statusCode}\n${response.body}");
        if (response.statusCode == 200) {
          forumBus.fire(fid.toString());
          final snackBar = SnackBar(
              content: Text('Success!'),
              backgroundColor: gwuBlue,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: gwuFlax,
                onPressed: () {},
              ));

          Scaffold.of(context)
              .showSnackBar(snackBar)
              .closed
              .then((SnackBarClosedReason reason) {
            Navigator.pop(context);
          });
        } else {
          if (response.statusCode == 201) {
            final snackBar = SnackBar(
                content: Text('Your login status is expired'),
                backgroundColor: gwuBlue,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: gwuFlax,
                  onPressed: () {},
                ));

            Scaffold.of(context).showSnackBar(snackBar);
          } else if (!httpCodes.contains(response.statusCode)) {
            final snackBar = SnackBar(
              content: Text(
                  'Please check your network connection and try again later'),
              backgroundColor: gwuBlue,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: gwuFlax,
                onPressed: () {},
              ),
            );

            Scaffold.of(context).showSnackBar(snackBar);
          } else {
            final Map<String, dynamic> data = json.decode(response.body);
            final snackBar = SnackBar(
                content: Text('${data['msg']}'),
                backgroundColor: gwuBlue,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: gwuFlax,
                  onPressed: () {},
                ));

            Scaffold.of(context).showSnackBar(snackBar);
          }
        }
      }).catchError((error) {
        debugPrint(error.toString());
        final snackBar = SnackBar(
          content:
          Text('Please check your network connection and try again later'),
          backgroundColor: gwuBlue,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: gwuFlax,
            onPressed: () {},
          ),
        );

        Scaffold.of(context).showSnackBar(snackBar);
      });
    }
  }
}
