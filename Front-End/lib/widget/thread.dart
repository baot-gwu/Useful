import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:useful/app.dart';
import 'package:useful/colors.dart';
import 'package:useful/widget/announcement_pill.dart';

String replyToAuthorUsername = '';
int replyToPid = 0;
int replyToPostIndex = 0;
FocusNode _postFocus = FocusNode();
int _textfiledLines = 1;

class PostInfo extends StatefulWidget {
  final int fid;
  final int tid;
  final int pid;
  final String topic;
  final Map<String, dynamic> body;
  final Map<String, dynamic> threadAuthor;
  final Map<String, dynamic> author;
  final int postIndex;
  final DateTime updateTime;
  final List admins;

  const PostInfo({
    Key key,
    @required this.fid,
    @required this.tid,
    @required this.pid,
    @required this.topic,
    @required this.body,
    @required this.threadAuthor,
    @required this.author,
    @required this.postIndex,
    @required this.updateTime,
    @required this.admins,
  })  : assert(fid != null),
        assert(tid != null),
        assert(pid != null),
        assert(topic != null),
        assert(body != null),
        assert(threadAuthor != null),
        assert(author != null),
        assert(postIndex != null),
        assert(updateTime != null),
        assert(admins != null),
        super(key: key);

  @override
  _PostInfoStatus createState() => new _PostInfoStatus();
}

class PostList extends StatefulWidget {
  final int fid;
  final int tid;
  final Map<String, dynamic> threadAuthor;
  final List admins;

  const PostList({
    Key key,
    @required this.fid,
    @required this.tid,
    @required this.threadAuthor,
    @required this.admins,
  })  : assert(tid != null),
        assert(threadAuthor != null),
        assert(admins != null),
        super(key: key);

  @override
  _PostListStatus createState() => new _PostListStatus();
}

class ThreadBody extends StatefulWidget {
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

  const ThreadBody({
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
  _ThreadBodyStatus createState() => new _ThreadBodyStatus();
}

class ThreadInfo extends StatefulWidget {
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

  const ThreadInfo({
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
  _ThreadInfoStatus createState() => new _ThreadInfoStatus();
}

class ThreadPage extends StatefulWidget {
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

  const ThreadPage({
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
  _ThreadPageState createState() => new _ThreadPageState();
}

class _PostInfoStatus extends State<PostInfo> {
  int fid;
  int tid;
  int pid;
  String topic;
  Map<String, dynamic> body;
  Map<String, dynamic> threadAuthor;
  Map<String, dynamic> author;
  int postIndex;
  DateTime updateTime;
  List admins;
  Widget replyPostTile = Card(
      color: MaterialDesignLightGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Loading'),
          Text('Loading'),
        ],
      ));
  Timer _timer;

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

    return new Card(
      child: InkWell(
        highlightColor: gwuLightBlue.withAlpha(100),
        splashColor: gwuBlue.withAlpha(100),
        onTap: () {
          replyToPid = pid;
          replyToPostIndex = postIndex;
          replyToAuthorUsername = author['username'];
          _postFocus.unfocus();
          FocusScope.of(context).requestFocus(_postFocus);
        },
        onLongPress: () {
          if (globalUserID == author['id'] ||
              globalUserID == threadAuthor['id'] ||
              admins.contains(globalUserID)) {
            _detectOperation() async {
              String result = await _operateThreadDialog();
              if (result == "edit") {
                // TODO: EDIT
                debugPrint("EDIT");
              } else if (result == "delete") {
                bool deleteResult = await _deletePostDialog();
                if (deleteResult) debugPrint("DELETE");
                await _deletePost();
              }
            }

            _detectOperation();
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            (topic == null || topic == '')
                ? (body['reply'] != 0)
                    ? ListTile(
                        subtitle: replyPostTile,
                      )
                    : ListTile()
                : (body['reply'] != 0)
                    ? ListTile(
                        title: Text(topic),
                        subtitle: replyPostTile,
                      )
                    : ListTile(
                        title: Text(topic),
                      ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      body['content'],
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
//                      mainAxisAlignment: MainAxisAlignment.start,
//                      crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: new CircleAvatar(
                                backgroundImage:
                                    (author['avatar'] == 'default.png')
                                        ? new AssetImage('assets/avatar.png')
                                        : new NetworkImage(author['avatar']),
                                radius: 30.0,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(author['username']),
                          ],
                        ),
                        Expanded(
                          child: Text(''),
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.access_time,
                              color: Colors.grey,
                              size: 20,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(formatTime),
                          ],
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.filter_none,
                              color: Colors.grey,
                              size: 20,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(postIndex.toString()),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                )),
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
                  Text('What do you want to do with this post?'),
                ],
              ),
            ),
            actions: <Widget>[
//              FlatButton(
//                child: Text('Edit'),
//                textColor: gwuBlue,
//                onPressed: () {
//                  Navigator.pop(context, "edit");
//                },
//              ),
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
          ),
          onWillPop: () async {
            return false;
          },
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

  Future<bool> _deletePostDialog() async {
    switch (await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Do you want to delete this post?'),
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
          ),
          onWillPop: () async {
            return false;
          },
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

  _deletePost() async {
    await http.delete(
      '$forumApi/$fid$threadApi/$tid$postApi/$pid',
      headers: {'Authorization': 'Bearer $globalUserToken'},
    ).then((response) {
      debugPrint(
          'Info: Thread List Respond: ${response.statusCode} ${response.body.toString()}');
      if (response.statusCode == 200) {
        final snackBar = SnackBar(
          content: Text('Post Deleted'),
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
          content: Text(
              'Your login status is expired or you doesn\'t have the authority'),
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
          content: Text('${data['msg']}'),
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
        content: Text('Please check your network connection'),
        backgroundColor: gwuBlue,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: gwuFlax,
          onPressed: () {},
        ),
      );

      Scaffold.of(context).showSnackBar(snackBar);
    });
    setState(() {});
  }

  void initState() {
    super.initState();
    fid = widget.fid;
    tid = widget.tid;
    pid = widget.pid;
    topic = widget.topic;
    body = widget.body;
    threadAuthor = widget.threadAuthor;
    author = widget.author;
    postIndex = widget.postIndex;
    updateTime = widget.updateTime;
    admins = widget.admins;
    _timer = new Timer.periodic(const Duration(seconds: 0), (timer) {
      if (mounted) {
        _getReplyPostTile(fid, tid, body['reply']);
        _timer.cancel();
      }
    });
  }

  _getReplyPostTile(int fid, int tid, int pid) async {
    int postIndex;
    String content;
    if (pid != 0)
      await http.get(
        '$forumApi/$fid$threadApi/$tid$postApi/$pid',
        headers: {'Authorization': 'Bearer $globalUserToken'},
      ).then((response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          postIndex = data['data']['postIndex'];
          content = data['data']['body']['content'];
        } else if (response.statusCode == 404) {
          postIndex = -1;
          content = 'This post is removed';
        }
      }).catchError((error) {
        debugPrint(error.toString());
      });

    replyPostTile = Card(
        color: MaterialDesignLightGrey,
        child: (postIndex != -1)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Reply to ${postIndex.toString()} floor:'),
                  Text((content == null || content == '')
                      ? 'No content'
                      : content),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text((content == null || content == '')
                      ? 'No content'
                      : content),
                ],
              ));

    setState(() {});
  }
}

class _PostListStatus extends State<PostList> {
  int fid;
  int tid;
  Map<String, dynamic> threadAuthor;
  List admins;
  List<PostInfo> postCardList = [];
  bool isLoading = true;
  ScrollController postListController = new ScrollController();
  Timer _timer;
  bool init = true;

  @override
  Widget build(BuildContext context) {
    return _buildThreadWidgets(postCardList);
  }

  void initState() {
    super.initState();
    fid = widget.fid;
    tid = widget.tid;
    threadAuthor = widget.threadAuthor;
    admins = widget.admins;
    _timer = new Timer.periodic(const Duration(seconds: 0), (timer) {
      if (mounted) {
        debugPrint("Ready!");
        _freshPosts();
        _timer.cancel();
      }
    });
    threadBus.on().listen((event) {
      debugPrint(
          '_PostListStatus ${event.toString()} ${event.toString() == 'edited'}');
      if (event.toString() == 'posted' ||
          event.toString() == 'edited' ||
          event.toString() == 'deleted') _freshPosts();
      if (event.toString() == 'update') _freshPosts();
    });
  }

  Widget _buildThreadWidgets(List<PostInfo> newPostCardList) {
    return (postCardList.isEmpty)
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
        : new RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              itemBuilder: (BuildContext context, int index) {
                if (index < newPostCardList.length) {
                  return newPostCardList[index];
                } else {
                  return _getMoreWidget();
                }
              },
              itemCount: newPostCardList.length + 1,
              controller: postListController,
            ),
          );
  }

  _freshPosts() async {
    postCardList.clear();
    await http.get(
      '$forumApi/$fid$threadApi/$tid$postApi',
      headers: {'Authorization': 'Bearer $globalUserToken'},
    ).then((response) {
//      debugPrint(
//          'Info: Post List ${tid.toString()} Respond: ${response.statusCode} ${response.body.toString()}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
//        debugPrint(data.toString());
        _processPostInfo(data);
      } else if (response.statusCode == 201) {
        final snackBar = SnackBar(
          content: Text('Your login status is expired'),
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
          content: Text('${data['msg']}'),
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
        content: Text('Please check your network connection'),
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

  Widget _getMoreWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          'More posts are coming...',
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  _getUserInfo(int uid) async {
    Map<String, dynamic> result = new Map();
    result['id'] = uid;
    result['username'] = 'Unknown';
    result['avatar'] = 'default.png';
    await http.get(
      '$userApi/$uid',
      headers: {'Authorization': "Bearer $globalUserToken"},
    ).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        result['username'] = data['data']['username'];
        result['avatar'] = data['data']['avatarurl'];
      } else if (response.statusCode == 404) {
        result['username'] = 'Unknown';
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
    return result;
  }

  Future<Null> _onRefresh() async {
    final snackBarUpdate = SnackBar(
        content: Text('Updating posts...'),
        backgroundColor: gwuBlue,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: gwuFlax,
          onPressed: () {},
        ));

    Scaffold.of(context).showSnackBar(snackBarUpdate);
    await Future.delayed(Duration(seconds: 0), () {
      _freshPosts();
    });
  }

  _processPostInfo(Map data) async {
    for (int i = 0; i < data['data'].length; i++) {
      postCardList.add(PostInfo(
          fid: fid,
          tid: tid,
          pid: data['data'][i]['pid'],
          topic: (data['data'][i]['topic'] == null)
              ? ''
              : data['data'][i]['topic'],
          body: data['data'][i]['body'],
          threadAuthor: threadAuthor,
          author: await _getUserInfo(data['data'][i]['author']),
          postIndex: data['data'][i]['postIndex'],
          updateTime: DateTime.parse(data['data'][i]['updateTime']),
          admins: admins));
    }
    if (postCardList.length == 0)
      postCardList.add(PostInfo(
          fid: fid,
          tid: tid,
          pid: 0,
          topic: "Post your reply!",
          body: {"reply": 0, "content": ""},
          threadAuthor: threadAuthor,
          author: {"id": 0, "username": "Useful Team", "avatar": "default.png"},
          postIndex: 1,
          updateTime: DateTime.now(),
          admins: admins));
    _rebuildPostList();
  }

  void _rebuildPostList() {
//    debugPrint(mounted.toString());
    if (mounted) {
      setState(() {
        debugPrint('PostList Built!');
        isLoading = false;
      });
    }
  }
}

class _ThreadBodyStatus extends State<ThreadBody> {
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
  final _messageController = new TextEditingController();
  final _messageTitleController = new TextEditingController();
  FocusNode _postTitleFocus = FocusNode();
  bool _onEditing;

  Future<void> _onRefresh() async {
    threadBus.fire('update');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView(shrinkWrap: true, children: <Widget>[
                    new ThreadInfo(
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
                        widgets: widgets),
                    new PostList(
                      fid: fid,
                      tid: tid,
                      threadAuthor: author,
                      admins: admins,
                    ),
                  ]),
                ),
              ),
              Container(
                color: Colors.white,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              (_onEditing)
                                  ? AccentColorOverride(
                                      color: gwuBlue,
                                      child: TextField(
                                        controller: _messageTitleController,
                                        focusNode: _postTitleFocus,
                                        maxLength: 50,
                                        decoration: InputDecoration(
                                          labelText: 'Title (Optional)',
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 0,
                                      width: 0,
                                    ),
                              AccentColorOverride(
                                color: gwuBlue,
                                child: TextField(
                                  controller: _messageController,
                                  keyboardType: TextInputType.multiline,
                                  focusNode: _postFocus,
                                  maxLines: _textfiledLines,
                                  decoration: InputDecoration(
                                    labelText: (replyToPostIndex == 0)
                                        ? 'Reply to @$replyToAuthorUsername'
                                        : 'Reply to #${replyToPostIndex.toString()} @$replyToAuthorUsername',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Column(
                          children: <Widget>[
                            RaisedButton(
                              child: (fid == 1)? Icon(Icons.cancel) : Text('Send'),
                              onPressed: () {
                                if (fid != 1) {_postPost(
                                    _messageTitleController.text.toString(),
                                    _messageController.text.toString(),
                                    replyToPid);
                                setState(() {
                                  _onEditing = false;
                                  _textfiledLines = 1;
                                  _postTitleFocus.unfocus();
                                  _postFocus.unfocus();
                                  _messageTitleController.clear();
                                  _messageController.clear();
                                });
                                } else {
                                  _messageTitleController.clear();
                                  _messageController.clear();
                                }
                              },
                            ),
                            (_onEditing)
                                ? RaisedButton(
                                    child: Icon(Icons.keyboard_hide),
                                    onPressed: () {
                                      setState(() {
                                        threadBus.fire('edited');
                                        _onEditing = false;
                                        _textfiledLines = 1;
                                        _postTitleFocus.unfocus();
                                        _postFocus.unfocus();
                                      });
                                    },
                                  )
                                : Container(
                                    height: 0,
                                    width: 0,
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
    _postFocus.addListener(_onFocusChange);
    _postTitleFocus.addListener(_onFocusChange);
    _onEditing = false;
//    threadBus.on().listen((event) {
//      debugPrint('ThreadBodyState ${event.toString()}');
//      debugPrint(updateTime.toString());
//      if ((event == 'posted' || event == 'edited' || event == 'deleted'))
//        debugPrint('ThreadBodyState Update');
//        setState(() {
//
//        });
//    });
  }

  void _onFocusChange() {
    if (mounted) {
      if (_postFocus.hasFocus)
        setState(() {
          _onEditing = true;
          _textfiledLines = 4;
        });
      if (_postTitleFocus.hasFocus) {
        setState(() {
          _onEditing = true;
          _textfiledLines = 1;
        });
        _postFocus.unfocus();
      }
    }
  }

  _postPost(String topic, String content, int pid) async {
    if (content != '') {
      final snackBarLoginIn = SnackBar(
        content: Text('Posting...'),
        backgroundColor: gwuBlue,
      );
      Scaffold.of(context).showSnackBar(snackBarLoginIn);
      await http
          .post('$forumApi/$fid$threadApi/$tid$postApi',
              headers: {
                'Authorization': 'Bearer $globalUserToken',
                'Content-Type': 'application/json'
              },
              body: json.encode((topic == '')
                  ? {
                      'body': {'reply': pid, 'content': content}
                    }
                  : {
                      'topic': topic,
                      'body': {'reply': pid, 'content': content}
                    }))
          .then((response) {
        debugPrint("Response: \n ${response.statusCode}\n${response.body}");
        if (response.statusCode == 200) {
          threadBus.fire('posted');
          final snackBar = SnackBar(
              content: Text('Success!'),
              backgroundColor: gwuBlue,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: gwuFlax,
                onPressed: () {},
              ));

          Scaffold.of(context).showSnackBar(snackBar);
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

class _ThreadInfoStatus extends State<ThreadInfo> {
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
  Widget defaultCard = new Card(
    child: InkWell(
      highlightColor: gwuLightBlue.withAlpha(100),
      splashColor: gwuBlue.withAlpha(100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[Text("Loading...")]),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Loading...'),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Loading...",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
//                      mainAxisAlignment: MainAxisAlignment.start,
//                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: new CircleAvatar(
                              backgroundImage:
                              new AssetImage('assets/avatar.png'),
                              radius: 30.0,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Loading...'),
                        ],
                      ),
                      Expanded(
                        child: Text(''),
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.remove_red_eye,
                            color: Colors.grey,
                            size: 20,
                          ),
                          Text('...'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.reply,
                            color: Colors.grey,
                            size: 20,
                          ),
                          Text('...'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.access_time,
                            color: Colors.grey,
                            size: 20,
                          ),
                          Text('...'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              )),
        ],
      ),
    ),
  );
  Widget resultCard;

  @override
  Widget build(BuildContext context) {
    return resultCard;
  }

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
    resultCard = _buildNewCard();
    _freshThreadInfo();
    threadBus.on().listen((event) {
      if (event.toString() == 'update')
        _freshThreadInfo();
    });
  }

  Widget _buildNewCard() {
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

    return Card(
      child: InkWell(
        onTap: () {
          replyToPid = 0;
          replyToPostIndex = 0;
          replyToAuthorUsername = author['username'];
        },
        highlightColor: gwuLightBlue.withAlpha(100),
        splashColor: gwuBlue.withAlpha(100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      body['content'],
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
//                      mainAxisAlignment: MainAxisAlignment.start,
//                      crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: new CircleAvatar(
                                backgroundImage:
                                    (author['avatar'] == 'default.png')
                                        ? new AssetImage('assets/avatar.png')
                                        : new NetworkImage(author['avatar']),
                                radius: 30.0,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(author['username']),
                          ],
                        ),
                        Expanded(
                          child: Text(''),
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.remove_red_eye,
                              color: Colors.grey,
                              size: 20,
                            ),
                            Text(view.toString()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.reply,
                              color: Colors.grey,
                              size: 20,
                            ),
                            Text(reply.toString()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.access_time,
                              color: Colors.grey,
                              size: 20,
                            ),
                            Text(formatTime),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  _freshThreadInfo() async {
    resultCard = defaultCard;
    await _fetchData();
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
        view = data['data']['view'];
        reply = data['data']['reply'];
        updateTime = DateTime.parse(data['data']['updateTime']);
      } else if (response.statusCode == 201) {
        debugPrint(
            '[Thread Info Card]: Your login status is expired');
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
    resultCard = _buildNewCard();
    if (mounted) {
      setState(() {});
    }
  }
}

class _ThreadPageState extends State<ThreadPage> {
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
  bool flag = true;

//  Timer _timer;
  int lastReplyToPid = replyToPid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$topic - tid:${tid.toString()}'),
      ),
      body: Hero(
        tag: 'threadDetail-tid:${tid.toString()}',
        child: new ThreadBody(
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
            widgets: widgets),
      ),
    );
  }

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
    replyToPid = 0;
    replyToAuthorUsername = author['username'];
    threadBus.on().listen((event) {
//      if (event.toString() == 'update')
    });
//    _timer = new Timer.periodic(const Duration(milliseconds: 200), (timer) {
//      if (mounted) {
//        if (lastReplyToPid != replyToPid)
//          setState(() {
//            lastReplyToPid = replyToPid;
//          });
//      }
//    });
  }
}
