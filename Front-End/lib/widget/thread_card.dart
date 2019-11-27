import 'package:flutter/material.dart';
//import 'package:universal_html/html.dart';
import 'package:useful/app.dart';
import 'package:useful/colors.dart';
import 'package:useful/widget/announcement_pill.dart';
import 'package:useful/widget/thread.dart';
import 'package:useful/widget/thread_editor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

class ThreadCard extends StatefulWidget {
  final int fid;
  final int tid;
  final String topic;
  final Map<String, dynamic> abstract;
  final Map<String, dynamic> body;
  final Map<String, dynamic> author;
  final int view;
  final int reply;
  final DateTime updateTime;
  final List admins;
  final Map<String, dynamic> widgets;

  const ThreadCard({
    Key key,
    @required this.fid,
    @required this.tid,
    @required this.topic,
    @required this.abstract,
    @required this.body,
    @required this.author,
    @required this.view,
    @required this.reply,
    @required this.updateTime,
    @required this.admins,
    @required this.widgets,
  })  : assert(tid != null),
        assert(topic != null),
        assert(abstract != null),
        assert(body != null),
        assert(author != null),
        assert(view != null),
        assert(reply != null),
        assert(updateTime != null),
        assert(admins != null),
        assert(widgets != null),
        super(key: key);

  @override
  _ThreadCardStatus createState() => new _ThreadCardStatus();
}

class _ThreadCardStatus extends State<ThreadCard> {
  int fid;
  int tid;
  String topic;
  Map<String, dynamic> abstract;
  Map<String, dynamic> body;
  Map<String, dynamic> author;
  int view;
  int reply;
  DateTime updateTime;
  List admins;
  Map<String, dynamic> widgets;

  void initState() {
    super.initState();
    fid = widget.fid;
    tid = widget.tid;
    topic = widget.topic;
    abstract = widget.abstract;
    body = widget.body;
    author = widget.author;
    view = widget.view;
    reply = widget.reply;
    updateTime = widget.updateTime;
    admins = widget.admins;
    widgets = widget.widgets;
//    debugPrint(tid.toString());
  }

  @override
  Widget build(BuildContext context) {
    String formatTime = "Now";
    var timeDifference = DateTime.now().difference(updateTime);
    if (timeDifference.inDays ~/ 365 > 1) {
      formatTime = '${timeDifference.inDays ~/ 365} years ago';
    } else if (timeDifference.inDays ~/ 365 == 1) {
      formatTime = '1 year ago';
    } else if (timeDifference.inDays ~/ 30 > 1) {
      formatTime = '${timeDifference.inDays / 30} months ago';
    } else if (timeDifference.inDays ~/ 30 == 1) {
      formatTime = '1 month ago';
    } else if (timeDifference.inDays.toInt() > 1) {
      formatTime = '${timeDifference.inDays} days ago';
    } else if (timeDifference.inDays.toInt() == 1) {
      formatTime = '1 day ago';
    } else if (timeDifference.inHours.toInt() > 1) {
      formatTime = '${timeDifference.inHours.toInt()} hours ago';
    } else if (timeDifference.inHours.toInt() == 1) {
      formatTime = '1 hour ago';
    } else if (timeDifference.inMinutes.toInt() > 1) {
      formatTime = '${timeDifference.inMinutes.toInt()} minutes ago';
    } else if (timeDifference.inMinutes.toInt() == 1) {
      formatTime = '1 minute ago';
    } else if (timeDifference.inSeconds.toInt() > 1) {
      formatTime = '${timeDifference.inSeconds.toInt()} seconds ago';
    } else if (timeDifference.inSeconds.toInt() == 1) {
      formatTime = '1 second ago';
    }
//    debugPrint('Tid: ${tid.toString()}\nTopic: $topic\nAbstract: ${abstract.toString()}\nBody: ${body.toString()}\nAuthor: ${author.toString()}\nView: ${view.toString()}\nReply: ${reply.toString()}\nTime: $formatTime\n');

    return (tid != 0) ? Hero(
        tag: 'threadDetail-tid:${tid.toString()}',
        child:
        Card(
          child: InkWell(
            highlightColor: gwuLightBlue.withAlpha(100),
            splashColor: gwuBlue.withAlpha(100),
            onTap: () {
              if (tid != 0) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ThreadPage(
                                fid: fid,
                                tid: tid,
                                topic: topic,
                                abstract: abstract,
                                body: body,
                                author: author,
                                view: view,
                                reply: reply,
                                updateTime: updateTime,
                                admins: admins,
                                widgets: widgets
                            )));
              }
            },
            onLongPress: () {
              if (tid != 0)
                if (author['id'] == globalUserID || admins.contains(globalUserID) || globalUserID == 1) {
                  _detectOperation() async{
                    String result = await _operateThreadDialog();
                    if (result == "edit") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditThreadEditorPage(
                                    fid: fid,
                                    tid: tid,
                                    widgets: widgets,
                                  )));
                      debugPrint("EDIT");
                    } else if (result == "delete") {
                      bool deleteResult = await _deleteThreadDialog();
                      if (deleteResult)
                        debugPrint("DELETE");
                      await _deleteThread();
                    }
                  }
                  _detectOperation();
                }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: (abstract['announcement'] == null || abstract['announcement'] == {})
                      ? new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 8.0,),
                        Text(topic)
                      ])
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new AnnouncementPill(
                          announcement: abstract['announcement'],
                          widgets: widgets),
                      Text(topic),
                    ],
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(abstract['shortMessage']),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
//                                      mainAxisAlignment: MainAxisAlignment.start,
//                                      crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: new CircleAvatar(
                                  backgroundImage: (author['avatar'] ==
                                      'default.png')
                                      ? new AssetImage(
                                      'assets/avatar.png')
                                      : new NetworkImage(
                                      author['avatar']),
                                  radius: 30.0,
                                ),
                              ),
                              SizedBox(width: 10,),
                              Text(author['username']),
                            ],
                          ),
                          Expanded(
                            child: Text(''),
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.remove_red_eye, color: Colors.grey, size: 20,),
                              SizedBox(width: 4.0,),
                              Text(view.toString()),
                            ],
                          ),
                          SizedBox(width: 8.0,),
                          Row(
                            children: <Widget>[
                              Icon(Icons.reply, color: Colors.grey, size: 20,),
                              SizedBox(width: 4.0,),
                              Text(reply.toString()),
                            ],
                          ),
                          SizedBox(width: 8.0,),
                          Row(
                            children: <Widget>[
                              Icon(Icons.access_time, color: Colors.grey, size: 20,),
                              SizedBox(width: 4.0,),
                              Text(formatTime),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 10.0, height: 4.0,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    )
    : Card(
      child: InkWell(
        highlightColor: gwuLightBlue.withAlpha(100),
        splashColor: gwuBlue.withAlpha(100),
        onTap: () {
          debugPrint((tid != 0).toString());
          if (tid != 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ThreadCard(
                            fid: fid,
                            tid: tid,
                            topic: topic,
                            abstract: abstract,
                            body: body,
                            author: author,
                            view: view,
                            reply: reply,
                            updateTime: updateTime,
                            admins: admins,
                            widgets: widgets
                        )));
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: (abstract['announcement'] == null)
                  ? new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[Text(topic)])
                  : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new AnnouncementPill(
                      announcement: {"announcement": abstract['announcement']},
                      widgets: widgets),
                  Text(topic),
                ],
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(abstract['shortMessage']),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
//                                      mainAxisAlignment: MainAxisAlignment.start,
//                                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: new CircleAvatar(
                              backgroundImage: (author['avatar'] ==
                                  'default.png')
                                  ? new AssetImage(
                                  'assets/avatar.png')
                                  : new NetworkImage(
                                  author['avatar']),
                              radius: 30.0,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text(author['username']),
                        ],
                      ),
                      Expanded(
                        child: Text(''),
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.remove_red_eye, color: Colors.grey, size: 20,),
                          SizedBox(width: 4.0,),
                          Text(view.toString()),
                        ],
                      ),
                      SizedBox(width: 8.0,),
                      Row(
                        children: <Widget>[
                          Icon(Icons.reply, color: Colors.grey, size: 20,),
                          SizedBox(width: 4.0,),
                          Text(reply.toString()),
                        ],
                      ),
                      SizedBox(width: 8.0,),
                      Row(
                        children: <Widget>[
                          Icon(Icons.access_time, color: Colors.grey, size: 20,),
                          SizedBox(width: 4.0,),
                          Text(formatTime),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _operateThreadDialog() async {
    switch (await showDialog<String>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            //title: Text('Confirm'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'What do you want to do with this thread?'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Edit'),
                textColor: gwuBlue,
                onPressed: () {
                  Navigator.pop(context, "edit");
                },
              ),
              FlatButton(
                child: Text('Delete'),
                textColor: gwuBlue,
                onPressed: () {
                  Navigator.pop(context, "delete");
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                textColor: gwuLightBlue,
                onPressed: () {
                  Navigator.pop(context, 'null');
                },
              ),
            ],
          ), onWillPop: () async {return false;},
        );
      },
    )) {
      case "edit":
        return "edit";
        break;
      case "delete":
        return "delete";
        break;
      default:
        return "null";
        break;
    }
  }

  Future<bool> _deleteThreadDialog() async {
    switch (await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            //title: Text('Delete Friend Confirm'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Do you want to delete this thread?'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Confirm'),
                textColor: gwuFlax,
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                textColor: gwuLightBlue,
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          ), onWillPop: () async {return false;},
        );
      },
    )) {
      case true:
        return true;
        break;
      default:
        return false;
        break;
    }
  }
  _deleteThread() async {
    await http.delete(
      '$forumApi/$fid$threadApi/$tid',
      headers: {'Authorization': 'Bearer $globalUserToken'},
    ).then((response) {
      debugPrint(
          'Info: Thread List Respond: ${response.statusCode} ${response.body.toString()}');
      if (response.statusCode == 200) {
        final snackBar = SnackBar(
          content:
          Text('Thread Deleted'),
          backgroundColor: gwuBlue,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: gwuFlax,
            onPressed: () {},
          ),
        );

        Scaffold.of(context).showSnackBar(snackBar);
      } else if (response.statusCode == 201) {
        final snackBar = SnackBar(
          content:
          Text('Your login status is expired or you doesn\'t have the authority'),
          backgroundColor: gwuBlue,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: gwuFlax,
            onPressed: () {},
          ),
        );

        Scaffold.of(context).showSnackBar(snackBar);
      } else if (!httpCodes.contains(response.statusCode)) {
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
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        final snackBar = SnackBar(
          content:
          Text('${data['msg']}'),
          backgroundColor: gwuBlue,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: gwuFlax,
            onPressed: () {},
          ),
        );

        Scaffold.of(context).showSnackBar(snackBar);
      }
    }).catchError((error) {
      final snackBar = SnackBar(
        content:
        Text('Please check your network connection'),
        backgroundColor: gwuBlue,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: gwuFlax,
          onPressed: () {},
        ),
      );

      Scaffold.of(context).showSnackBar(snackBar);
    });
    setState(() {

    });
  }
}
