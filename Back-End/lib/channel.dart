import 'package:useful/config/db_configuration.dart' as db;
import 'package:useful/controller/identity_controller.dart';
import 'package:useful/controller/post_controller.dart';
import 'package:useful/controller/register_controller.dart';
import 'package:useful/controller/user_controller.dart';
import 'package:useful/model/user.dart';

import 'controller/forum_controller.dart';
import 'controller/thread_controller.dart';
import 'useful.dart';

class UsefulChannel extends ApplicationChannel
    implements AuthRedirectControllerDelegate {
  AuthServer authServer;
  ManagedContext context;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
    context = db.getContext(options.configurationFilePath);
    final authStorage = ManagedAuthDelegate<User>(context);
    authServer = AuthServer(authStorage);
  }

  @override
  Controller get entryPoint {
    final router = Router();

//    router
//      .route("/example")
//      .linkFunction((request) async {
//        return Response.ok({"key": "value"});
//      });

    /* OAuth 2.0 Endpoints */
    router.route("/auth/token").link(() => AuthController(authServer));

    router
        .route("/auth/form")
        .link(() => AuthRedirectController(authServer, delegate: this));

    /* Create an account */
    router
        .route("/register")
        .link(() => Authorizer.basic(authServer))
        .link(() => RegisterController(context, authServer));

    /* Gets profile for user with bearer token */
    router
        .route("/me")
        .link(() => Authorizer.bearer(authServer))
        .link(() => IdentityController(context));

    /* Gets all users or one specific user by id */
    router
        .route("/users/[:id]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => UserController(context, authServer));

    /* Get forum list or one specific forum by id*/
    router
        .route("/forum/[:fid]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => ForumController(context, authServer));

    /* Get threads list or one specific thread by id*/
    router
        .route("/forum/:fid/thread/[:tid]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => ThreadController(context, authServer));

    /* Get posts by id*/
    router
        .route("/forum/:fid/thread/:tid/post/[:pid]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => PostController(context, authServer));

    return router;
  }

  @override
  Future<String> render(AuthRedirectController forController, Uri requestUri,
      String responseType, String clientID, String state, String scope) {
    return null;
  }
}
