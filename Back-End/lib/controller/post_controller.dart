import 'package:useful/model/forum.dart';
import 'package:useful/model/post.dart';
import 'package:useful/model/thread.dart';
import 'package:useful/useful.dart';

class PostController extends ResourceController {
  PostController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.get("fid", "tid")
  Future<Response> getAll() async {
    final fid = int.parse(request.path.variables['fid']);
    final tid = int.parse(request.path.variables['tid']);

    final queryThread = Query<Thread>(context)
      ..where((o) => o.tid).equalTo(tid);
    final resultThread = await queryThread.fetchOne();
    if (resultThread == null || resultThread.fid != fid) {
      return Response.notFound();
    }

    final queryPost = Query<Post>(context)..where((o) => o.tid).equalTo(tid)..sortBy((o) => o.pid, QuerySortOrder.ascending);
    final List resultPost = await queryPost.fetch();
    List resultPostasMap = [];
    for (int i = 0; i < resultPost.length; i++){
        resultPostasMap.add(resultPost[i].asMap());
    }
    return Response.ok({"msg": "Post List Fetched", "data": resultPostasMap});
  }

  @Operation.get("fid", "tid", "pid")
  Future<Response> getPost() async {
    final fid = int.parse(request.path.variables['fid']);
    final tid = int.parse(request.path.variables['tid']);
    final pid = int.parse(request.path.variables['pid']);
    final queryPost = Query<Post>(context)..where((o) => o.pid).equalTo(pid);
    final resultPost = await queryPost.fetchOne();
    final queryThread = Query<Thread>(context)..where((o) => o.tid).equalTo(tid);
    final resultThread = await queryThread.fetchOne();
    if (resultPost == null || resultPost.tid != tid || resultThread == null || resultThread.fid != fid) {
      return Response.notFound();
    }
    return Response.ok({"msg": "Post Fetched", "data": resultPost.asMap()});
  }

  @Operation.post("fid", "tid")
  Future<Response> createPost(@Bind.body() Post post) async {
    final fid = int.parse(request.path.variables['fid']);
    final tid = int.parse(request.path.variables['tid']);

    var queryThread = Query<Thread>(context)..where((o) => o.tid).equalTo(tid);
    var resultThread = await queryThread.fetchOne();
    if (resultThread == null || resultThread.fid != fid) {
      return Response.notFound();
    }

    final reply = (post.body)["reply"];
    final content = (post.body)["content"];

    post.tid = tid;
    post.body = Document({"reply": reply, "content": content});
    post.postIndex = resultThread.nextFloor;
    post.author = request.authorization.ownerID;

    final queryPost = Query<Post>(context)
      ..values = post
    ;

    final resultPost = await queryPost.insert();
    if (resultPost == null) {
      return Response.serverError();
    } else {
      queryThread = Query<Thread>(context)
        ..values.nextFloor = ++resultThread.nextFloor
        ..values.reply = ++resultThread.reply
        ..where((o) => o.tid).equalTo(tid);

      resultThread = await queryThread.updateOne();

      if (resultThread == null) {
        return Response.serverError();
      } else
        return Response.ok({"msg": "Post Created", "data": resultPost.asMap()});
    }
  }

  @Operation.put("fid", "tid", "pid")
  Future<Response> updatePost(@Bind.body() Post post) async {
    final fid = int.parse(request.path.variables['fid']);
    final tid = int.parse(request.path.variables['tid']);
    final pid = int.parse(request.path.variables['pid']);

    var queryPost = Query<Post>(context)..where((o) => o.pid).equalTo(pid);
    var resultPost = await queryPost.fetchOne();
    final queryThread = Query<Thread>(context)..where((o) => o.tid).equalTo(tid);
    final resultThread = await queryThread.fetchOne();
    final queryForum = Query<Forum>(context)..where((o) => o.fid).equalTo(fid);
    final resultForum = await queryForum.fetchOne();
    if (resultPost == null || resultPost.tid != tid || resultThread == null || resultThread.fid != fid || resultForum == null) {
      return Response.notFound();
    }

    final List adminsList = (resultForum.admins)["admins"] as List;

    if (request.authorization.ownerID != resultPost.author
        && !adminsList.contains(request.authorization.ownerID)
        && request.authorization.ownerID != 1) {
      return Response.badRequest(
          body: {"msg": "Unauthorized", "data": []}
          );
    }

    queryPost = Query<Post>(context)
        ..values.topic = post.topic ?? resultPost.topic
        ..values.body = post.body ?? resultPost.body
        ..where((o) => o.pid).equalTo(pid);
      resultPost = await queryPost.updateOne();
      if (resultPost == null) {
        return Response.serverError();
      }

      return Response.ok({"msg": "Post Edited", "data": resultPost.asMap()});
  }

  @Operation.delete("fid", "tid", "pid")
  Future<Response> deleteForum() async {
    final fid = int.parse(request.path.variables['fid']);
    final tid = int.parse(request.path.variables['tid']);
    final pid = int.parse(request.path.variables['pid']);
    var queryThread = Query<Thread>(context)..where((o) => o.tid).equalTo(tid);
    var resultThread = await queryThread.fetchOne();
    final queryPost = Query<Post>(context)..where((o) => o.pid).equalTo(pid);
    final resultPost = await queryPost.fetchOne();
    final queryForum = Query<Forum>(context)..where((o) => o.fid).equalTo(fid);
    final resultForum = await queryForum.fetchOne();
    if (resultPost == null || resultPost.tid != tid || resultThread == null || resultThread.fid != fid || resultForum == null) {
      return Response.notFound();
    }

    final List adminsList = (resultForum.admins)["admins"] as List;

    if (request.authorization.ownerID != resultPost.author &&
        request.authorization.ownerID != resultThread.author &&
        !adminsList.contains(request.authorization.ownerID) &&
        request.authorization.ownerID != 1) {
      return Response.badRequest(
          body: {"msg": "Unauthorized", "data": []}
      );
    }

    await queryPost.delete();

    queryThread = Query<Thread>(context)
      ..values.reply = --resultThread.reply
      ..where((o) => o.tid).equalTo(tid);

    resultThread = await queryThread.updateOne();
    if (resultThread == null)
      return Response.serverError();

    return Response.ok({"msg": "Post Deleted", "data": []});
  }
}
