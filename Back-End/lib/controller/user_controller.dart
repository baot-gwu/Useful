import 'package:useful/model/user.dart';
import 'package:useful/useful.dart';

class UserController extends ResourceController {
  UserController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.get()
  Future<Response> getAll() async {
    final queryUser = Query<User>(context);
    final List resultUser = await queryUser.fetch();
    List resultUserasMap = [];
    for (int i = 0; i < resultUser.length; i++){
      resultUserasMap.add(resultUser[i].asMap());
    }
    return Response.ok({"msg": "User Fetched", "data": resultUserasMap});
  }

  @Operation.get("id")
  Future<Response> getUser(@Bind.path("id") int id) async {
    final queryUser = Query<User>(context)..where((o) => o.id).equalTo(id);
    final resultUser = await queryUser.fetchOne();
    if (resultUser == null) {
      return Response.notFound();
    }

//    if (request.authorization.ownerID != id) {
//      // Filter out stuff for non-owner of user
//    }

    return Response.ok({"msg": "User Fetched", "data": resultUser.asMap()});
  }

  @Operation.put("id")
  Future<Response> updateUser(
      @Bind.path("id") int id, @Bind.body() User user) async {
    if (request.authorization.ownerID != id) {
      return Response.badRequest(
          body: {"msg": "Unauthorized", "data": []}
      );
    }

    user
      ..salt = AuthUtility.generateRandomSalt()
      ..hashedPassword = authServer.hashPassword(user.password, user.salt);

    final queryUser = Query<User>(context)
      ..values = user
      ..where((o) => o.id).equalTo(id);

    final resultUser = await queryUser.updateOne();
    if (resultUser == null) {
      return Response.notFound();
    }

    return Response.ok({"msg": "User Edited", "data": resultUser.asMap()});
  }

  @Operation.delete("id")
  Future<Response> deleteUser(@Bind.path("id") int id) async {
    if (request.authorization.ownerID != id ||
        request.authorization.ownerID == 1) {
      return Response.badRequest(
          body: {"msg": "Unauthorized", "data": []}
      );
    }

    final queryUser = Query<User>(context)..where((o) => o.id).equalTo(id);
    await authServer.revokeAllGrantsForResourceOwner(id);
    await queryUser.delete();

    return Response.ok({"msg": "User Deleted", "data": []});
  }
}
