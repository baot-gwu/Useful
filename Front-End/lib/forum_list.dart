import 'package:flutter/material.dart';
import 'package:useful/colors.dart';
import 'package:useful/useful_drawer.dart';
import 'package:useful/app.dart';
import 'package:useful/widget/thread_card.dart';
import 'package:useful/widget/thread_editor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'dart:async';

Timer _timer;
TabController forumListsListTabController;
Map<String, ScrollController> _scrollControllerForums = new Map();
bool isLoading = true;

class ForumListPage extends StatefulWidget {
  @override
  _ForumListState createState() => new _ForumListState();
}

class _ForumListState extends State<ForumListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getForumList();
    _timer = new Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
//      bool flag = true;
      _scrollControllerForums.forEach((forum, client) {
//        if (!client.hasClients) flag = false;
      });
//      if (!flag) _timer.cancel();
    });
  }

  _getForumList() async {
    isLoading = true;
    Map<String, dynamic> data;
    await http.get(forumApi,
        headers: {'Authorization': 'Bearer $globalUserToken'}).then((response) {
      if (response.statusCode == 200) {
        data = json.decode(response.body);
        for (int i = 0; i < (data['data']).length; i++) {
//          debugPrint('[ForumList Init]: $i : ${(data['data'])[i].toString()}');
          forumDataName[(data['data'])[i]['name']] = (data['data'])[i];

          if (((data['data'])[i])['name'] != 'Bulletin')
            _scrollControllerForums[((data['data'])[i])['name']] =
                new ScrollController();
        }
      } else if (response.statusCode == 201) {
        debugPrint('[ForumList Init]: Your login status is expired');
      } else if (!httpCodes.contains(response.statusCode)) {
        debugPrint(
            '[ForumList Init]: Please check your network connection and try again later');
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        debugPrint('[ForumList Init]: ${data['msg']}');
      }
    }).catchError((error) {
      debugPrint('[ForumList Init]: $error');
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: forumListsTabList.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Forum'),
          bottom: TabBar(
            controller: forumListsListTabController,
            tabs: forumListsTabList,
            isScrollable: true,
          ),
        ),
        drawer: UsefulDrawer(),
        body: TabBarView(
          children: forumListsTabList.map((Tab tab) {
            _scrollControllerForums['Bulletin'] = new ScrollController();
            if (tab.text == 'Bulletin') {
              return Scaffold(
                body: ForumListBody(
                  api: forumApi,
                  tag: 'Bulletin',
                  fid: 1,
                  bulletin: (forumDataName[tab.text] == null)
                      ? "Loading..."
                      : forumDataName[tab.text]['bulletin'],
                  admins: (forumDataName[tab.text] == null)
                      ? [1]
                      : forumDataName[tab.text]['admins']['admins'],
                  widgets: (forumDataName[tab.text] == null)
                      ? {}
                      : forumDataName[tab.text]['widgets'],
                ),
                floatingActionButton:
                    new Builder(builder: (BuildContext context) {
                  return new FloatingActionButton(
                    child: (_scrollControllerForums['Bulletin'].hasClients)
                        ? Icon(Icons.vertical_align_top)
                        : Icon(Icons.sync),
                    tooltip: "Back to top",
                    foregroundColor: gwuFlax,
                    backgroundColor: gwuBlue,
                    heroTag: null,
                    elevation: 7.0,
                    highlightElevation: 14.0,
                    onPressed: () {
                      if (_scrollControllerForums['Bulletin'].hasClients) {
                        _scrollControllerForums['Bulletin'].animateTo(
                            -1 *
                                _scrollControllerForums['Bulletin']
                                    .position
                                    .pixels,
                            duration: Duration(seconds: 2),
                            curve: Curves.ease);
                      }
                    },
                    mini: false,
                    shape: new CircleBorder(),
                    isExtended: false,
                  );
                }),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
              );
            } else {
              return Scaffold(
                body: ForumListBody(
                  api: forumApi,
                  tag: tab.text,
                  fid: (forumDataName[tab.text] == null)
                      ? 0
                      : (forumDataName[tab.text])['fid'],
                  bulletin: (forumDataName[tab.text] == null)
                      ? "Loading..."
                      : (forumDataName[tab.text])['bulletin'],
                  admins: (forumDataName[tab.text] == null)
                      ? [1]
                      : (forumDataName[tab.text])['admins']['admins'],
                  widgets: (forumDataName[tab.text] == null)
                      ? {}
                      : (forumDataName[tab.text])['widgets'],
                ),
                floatingActionButton:
                    new Builder(builder: (BuildContext context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new FloatingActionButton(
                        child: Icon(Icons.sync),
                        tooltip: "Update Thread",
                        foregroundColor: gwuFlax,
                        backgroundColor: gwuBlue,
                        heroTag: null,
                        elevation: 7.0,
                        highlightElevation: 14.0,

                        onPressed: () {
                          if (_scrollControllerForums[tab.text].hasClients) {
                            forumBus.fire(tab.text);
                          }
                        },
                        mini: false,
                        shape: new CircleBorder(),
                        isExtended: false,
                      ),
                      SizedBox(height: 15.0,),
                      new FloatingActionButton(
                        child: (_scrollControllerForums[tab.text].hasClients)
                            ? Icon(Icons.add)
                            : Icon(Icons.sync),
                        tooltip: "Create new Thread",
                        foregroundColor: gwuFlax,
                        backgroundColor: gwuBlue,
                        heroTag: 'newThread-${forumDataName[tab.text]['fid'].toString()}',
                        elevation: 7.0,
                        highlightElevation: 14.0,

                        onPressed: () {
                          if (_scrollControllerForums[tab.text].hasClients) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                            CreateThreadEditorPage(
                              fid: forumDataName[tab.text]['fid'],
                              widgets: forumDataName[tab.text]['widgets'],
                            )));
                          }
                        },
                        mini: false,
                        shape: new CircleBorder(),
                        isExtended: false,
                      ),
                  ],);
                }),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
              );
//                debugPrint(tab.text);
            }
//              }
          }).toList(),
        ),
      ),
    );
  }
}

class ForumListBody extends StatefulWidget {
  ForumListBody(
      {Key key,
      this.api,
      this.tag,
      this.fid,
      this.bulletin,
      this.admins,
      this.widgets})
      : super(key: key);
  final String api;
  final String tag;
  final int fid;
  final String bulletin;
  final List admins;
  final Map<String, dynamic> widgets;

  _ForumListBodyState createState() => _ForumListBodyState();
}

class _ForumListBodyState extends State<ForumListBody>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = false;
  String api, tag;
  int fid;
  String bulletin;
  List admins;
  Map<String, dynamic> widgets;
  var threadList = <ThreadCard>[];

  @override
  bool get wantKeepAlive => true;

  void initState() {
    super.initState();
    api = widget.api;
    tag = widget.tag;
    fid = widget.fid;
    bulletin = widget.bulletin;
    admins = widget.admins;
    widgets = widget.widgets;
    _freshThreadList();
    forumBus.on().listen((forumName) {
      if (forumName.toString() == tag || forumName.toString() == fid.toString())
        _freshThreadList();
    });
  }

  _freshThreadList() async {
    threadList.clear();
    await _fetchData();
  }

  void _rebuildThreadList() {
    if (mounted)
      setState(() {
        isLoading = false;
      });
  }

  _fetchData() async {
    await http.get(
      '$forumApi/$fid$threadApi',
      headers: {'Authorization': 'Bearer $globalUserToken'},
    ).then((response) {
      debugPrint(
          'Info: Thread List ${fid.toString()} Respond: ${response.statusCode} ${response.body.toString()}');
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        _processThreadInfo(data);
      } else if (response.statusCode == 201) {
        debugPrint(
            '[ForumList Fetch Each Forum]: Your login status is expired');
      } else if (!httpCodes.contains(response.statusCode)) {
        debugPrint(
            '[ForumList Fetch Each Forum]: Please check your network connection and try again later');
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        debugPrint('[ForumList Fetch Each Forum]: ${data['msg']}');
      }
    }).catchError((error) {
      debugPrint('[ForumList Fetch Each Forum]: $error');
    });
    if (mounted) {
      setState(() {});
    }
  }

  _processThreadInfo(Map data) async {
    threadList.add(ThreadCard(
      fid: fid,
      tid: 0,
      topic: bulletin,
      abstract: {"announcement": {}, "shortMessage": ""},
      body: {"content": ""},
      author: {"id": 0, "username": "Forum Bulletin", "avatar": "default.png"},
      view: 0,
      reply: 0,
      updateTime: DateTime.now(),
      admins: admins,
      widgets: widget.widgets,
    ));
    for (var i = 0; i < data['data'].length; i++) {
      threadList.add(ThreadCard(
        fid: fid,
        tid: data['data'][i]['tid'],
        topic: data['data'][i]['topic'],
        abstract: data['data'][i]['abstract'],
        body: data['data'][i]['body'],
        view: data['data'][i]['view'],
        reply: data['data'][i]['reply'],
        updateTime: DateTime.parse(data['data'][i]['updateTime']),
        admins: admins,
        widgets: widget.widgets,
        author: await _getUserInfo(data['data'][i]['author']),
      ));
    }
    if (threadList.length == 1)
      threadList.add(ThreadCard(
        fid: fid,
        tid: 0,
        topic: "Post the first thread now!",
        abstract: {"announcement": {}, "shortMessage": ""},
        body: {"content": ""},
        author: {"id": 0, "username": "Useful Team", "avatar": "default.png"},
        view: 0,
        reply: 0,
        updateTime: DateTime.now(),
        admins: admins,
        widgets: widget.widgets,
      ));
    _rebuildThreadList();
    isLoading = false;
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

  Widget _buildThreadWidgets(List<ThreadCard> newThreadListCards) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        itemBuilder: (BuildContext context, int index) {
          if (index < newThreadListCards.length) {
            return newThreadListCards[index];
          } else {
            return _getMoreWidget();
          }
        },
        itemCount: newThreadListCards.length + 1,
        controller: _scrollControllerForums[tag],
      ),
    );
  }

  Future<Null> _onRefresh() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      final snackBarUpdate = SnackBar(
          content: Text('Refresh thread list...'),
          backgroundColor: gwuBlue,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: gwuFlax,
            onPressed: () {},
          ));

      Scaffold.of(context).showSnackBar(snackBarUpdate);

      await Future.delayed(Duration(seconds: 0), () {
        _freshThreadList();
      });
    }
  }

  Widget _getMoreWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          'More threads are coming...',
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return (threadList.isEmpty)
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
        : Column(
      children: <Widget>[
        SizedBox(height: 10.0,),
        _buildThreadWidgets(threadList)
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
