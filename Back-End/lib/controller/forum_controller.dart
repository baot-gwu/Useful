import 'package:useful/model/forum.dart';
import 'package:useful/useful.dart';

class ForumController extends ResourceController {
  ForumController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  // forbidden blocked users
//    if (request.authorization.ownerID != id) {
//      return Response.forbidden(body: {"msg": "User are blocked"});
//    }

  @Operation.get()
  Future<Response> getAll() async {
    final queryForum = Query<Forum>(context)..sortBy((o) => o.fid, QuerySortOrder.ascending);
    final List resultForum = await queryForum.fetch();
    List resultForumasMap = [];
    for (int i = 0; i < resultForum.length; i++){
      resultForumasMap.add(resultForum[i].asMap());
    }
    return Response.ok({"msg": "Forum List Fetched", "data": resultForumasMap});
  }

  @Operation.get("fid")
  Future<Response> getForum(@Bind.path("fid") int fid) async {
    final queryForum = Query<Forum>(context)..where((o) => o.fid).equalTo(fid);
    final resultForum = await queryForum.fetchOne();
    if (resultForum == null) {
      return Response.notFound();
    }
    return Response.ok({"msg": "Forum Fetched", "data": resultForum.asMap()});
  }

  @Operation.post()
  Future<Response> createForum(@Bind.body() Forum forum) async {
    // only Administrator can create forum!
    if (request.authorization.ownerID != 1) {
      return Response.badRequest(
          body: {"msg": "Unauthorized", "data": []}
      );
    }

    final queryForum = Query<Forum>(context)..values = forum;

    final resultForum = await queryForum.insert();
    if (resultForum == null) {
      return Response.serverError();
    }

    return Response.ok({"msg": "Forum Created", "data": resultForum.asMap()});
  }

  @Operation.put("fid")
  Future<Response> updateForum(
      @Bind.path("fid") int fid, @Bind.body() Forum forum) async {
    var queryForum = Query<Forum>(context)..where((o) => o.fid).equalTo(fid);
    var resultForum = await queryForum.fetchOne();
    if (resultForum == null) {
      return Response.notFound();
    } else {
      // only admins can modify forum info
      final List adminsList = (resultForum.admins)["admins"] as List;
      if (!adminsList.contains(request.authorization.ownerID) &&
          request.authorization.ownerID != 1) {
        return Response.badRequest(
            body: {"msg": "Unauthorized", "data": []}
        );
      }

      queryForum = Query<Forum>(context)
        ..values = forum
        ..where((o) => o.fid).equalTo(fid);
      resultForum = await queryForum.updateOne();
      if (resultForum == null) {
        return Response.notFound();
      }

      return Response.ok({"msg": "Forum Edited", "data": resultForum.asMap()});
    }
  }

  @Operation.delete("fid")
  Future<Response> deleteForum(@Bind.path("fid") int fid) async {
    final queryForum = Query<Forum>(context)..where((o) => o.fid).equalTo(fid);
    final resultForum = await queryForum.fetchOne();
    if (resultForum == null) {
      return Response.notFound();
    } else {
      // only admins can modify forum info
      final List adminsList = (resultForum.admins)["admins"] as List;
      if (!adminsList.contains(request.authorization.ownerID) &&
          request.authorization.ownerID != 1) {
        return Response.badRequest(
            body: {"msg": "Unauthorized", "data": []}
        );
      }
    }

    await authServer.revokeAllGrantsForResourceOwner(fid);
    await queryForum.delete();

    return Response.ok({"msg": "Forum Deleted", "data": []});
  }
}
