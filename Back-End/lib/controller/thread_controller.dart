import 'package:useful/model/forum.dart';
import 'package:useful/model/thread.dart';
import 'package:useful/useful.dart';

class ThreadController extends ResourceController {
  ThreadController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.get("fid")
  Future<Response> getAll() async {
    final fid = int.parse(request.path.variables['fid']);
    final queryThread = Query<Thread>(context)..where((o) => o.fid).equalTo(fid)..sortBy((o) => o.updateTime, QuerySortOrder.descending);
    final List resultThread = await queryThread.fetch();
    List resultThreadasMap = [];
    for (int i = 0; i < resultThread.length; i++){
      resultThreadasMap.add(resultThread[i].asMap());
    }
    return Response.ok({"msg": "Thread List Fetched", "data": resultThreadasMap});
  }

  @Operation.get("fid", "tid")
  Future<Response> getThread() async {
    final fid = int.parse(request.path.variables['fid']);
    final tid = int.parse(request.path.variables['tid']);
    var queryThread = Query<Thread>(context)
      ..where((o) => o.tid).equalTo(tid);
    var resultThread = await queryThread.fetchOne();
    if (resultThread == null || resultThread.fid != fid) {
      return Response.notFound();
    }

    queryThread = Query<Thread>(context)
      ..values.view = ++resultThread.view
      ..where((o) => o.tid).equalTo(tid);

    resultThread = await queryThread.updateOne();

    if (resultThread == null)
      return Response.serverError();

    return Response.ok({"msg": "Thread Fetched", "data": resultThread.asMap()});
  }

  @Operation.post("fid")
  Future<Response> createThread(@Bind.body() Thread thread) async {
    final fid = int.parse(request.path.variables['fid']);
    thread.author = request.authorization.ownerID;
    thread.fid = fid;
    final Map<String, dynamic> announcement = (thread.abstract)["announcement"] as Map<String, dynamic>;
    String shortMessage = (thread.body)["content"] as String;
    shortMessage = shortMessage.substring(0, (shortMessage.length >= 30) ?
    30 : shortMessage.length);
    thread.abstract =
        Document({"announcement": announcement, "shortMessage": shortMessage});

    final queryThread = Query<Thread>(context)
      ..values = thread
    ;

    final resultThread = await queryThread.insert();
    if (resultThread == null) {
      return Response.serverError();
    }
    return Response.ok({"msg": "Thread Created", "data": resultThread.asMap()});
  }

  @Operation.put("fid", "tid")
  Future<Response> updateThread(@Bind.body() Thread thread) async {
    final fid = int.parse(request.path.variables['fid']);
    final tid = int.parse(request.path.variables['tid']);

    var queryThread = Query<Thread>(context)
      ..where((o) => o.tid).equalTo(tid);
    var resultThread = await queryThread.fetchOne();
    if (resultThread == null || resultThread.fid != fid) {
      return Response.notFound();
    }

    final queryForum = Query<Forum>(context)
      ..where((o) => o.fid).equalTo(fid);
    final resultForum = await queryForum.fetchOne();
    if (resultForum == null) {
      return Response.notFound();
    }

    final List adminsList = (resultForum.admins)["admins"] as List;

    if (request.authorization.ownerID != resultThread.author
        && !adminsList.contains(request.authorization.ownerID)
        && request.authorization.ownerID != 1){
      return Response.badRequest(
          body: {"msg": "Unauthorized", "data": []}
      );
    }

    if (thread.topic != "Untitled Topic") {
      resultThread.topic = thread.topic;
    }

    if (thread.body["content"] != null) {
      String shortMessage = (thread.body)["content"] as String;
      shortMessage = shortMessage.substring(0, (shortMessage.length >= 30) ?
      30 : shortMessage.length);
      (resultThread.body)["content"] = (thread.body)["content"];
      (resultThread.abstract)["shortMessage"] = shortMessage;
    }
    if (thread.abstract["announcement"] != null) {
      (resultThread.abstract)["announcement"] = (thread.abstract)["announcement"];
    }

    queryThread = Query<Thread>(context)
      ..values.topic = resultThread.topic
      ..values.abstract = resultThread.abstract
      ..values.body = resultThread.body
      ..values.updateTime = DateTime.now()
      ..where((o) => o.tid).equalTo(tid);
    resultThread = await queryThread.updateOne();

    if (resultThread == null) {
      return Response.notFound();
    }
    return Response.ok({"msg": "Thread Edited", "data": resultThread.asMap()});
  }

  @Operation.delete("fid", "tid")
  Future<Response> deleteThread() async {
    final fid = int.parse(request.path.variables['fid']);
    final tid = int.parse(request.path.variables['tid']);
    final queryThread = Query<Thread>(context)
      ..where((o) => o.tid).equalTo(tid);
    final resultThread = await queryThread.fetchOne();
    if (resultThread == null || resultThread.fid != fid) {
      return Response.notFound();
    }

    final queryForum = Query<Forum>(context)
      ..where((o) => o.fid).equalTo(fid);
    final resultForum = await queryForum.fetchOne();
    if (resultForum == null) {
      return Response.notFound();
    }

    final List adminsList = (resultForum.admins)["admins"] as List;
    if (request.authorization.ownerID != resultThread.author
        && !adminsList.contains(request.authorization.ownerID)
        && request.authorization.ownerID != 1) {
      return Response.unauthorized();
    }

    await queryThread.delete();

    return Response.ok({"msg": "Thread Deleted", "data": []});
  }
}