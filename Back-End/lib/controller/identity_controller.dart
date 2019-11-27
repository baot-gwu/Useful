import 'package:useful/model/user.dart';
import 'package:useful/useful.dart';

class IdentityController extends ResourceController {
  IdentityController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getIdentity() async {
    final queryUser = Query<User>(context)
      ..where((o) => o.id).equalTo(request.authorization.ownerID);

    final resultUser = await queryUser.fetchOne();
    if (resultUser == null) {
      return Response.notFound();
    }

    return Response.ok({"msg": "User Fetched", "data": resultUser.asMap()});
  }
}
