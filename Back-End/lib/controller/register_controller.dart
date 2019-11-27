import 'package:useful/model/user.dart';
import 'package:useful/useful.dart';

class RegisterController extends ResourceController {
  RegisterController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.post()
  Future<Response> createUser(@Bind.body() User user) async {
    // Check for required parameters before we spend time hashing
    user.username = user.username.trim();
    user.password = user.password.trim();
    if (user.username.isEmpty || user.password.isEmpty) {
      return Response.badRequest(
          body: {"msg": "username and password required."});
    }

    user
      ..salt = AuthUtility.generateRandomSalt()
      ..hashedPassword = authServer.hashPassword(user.password, user.salt);

    final queryUser = Query<User>(context)..values = user;

    final resultUser = await queryUser.insert();
    final token = await authServer.authenticate(
        user.username,
        user.password,
        request.authorization.credentials.username,
        request.authorization.credentials.password);

    final response = AuthController.tokenResponse(token);
    final newBody = resultUser.asMap()..["authorization"] = response.body;
    return response..body = newBody;
  }

  @override
  Map<String, APIResponse> documentOperationResponses(
      APIDocumentContext context, Operation operation) {
    return {
      "200": APIResponse.schema("User successfully registered.",
          context.schema.getObject("UserRegistration")),
      "400": APIResponse.schema("Error response", APISchemaObject.freeForm())
    };
  }

  @override
  void documentComponents(APIDocumentContext context) {
    super.documentComponents(context);

    final userSchemaRef = context.schema.getObjectWithType(User);
    final userRegistration = APISchemaObject.object({
      "authorization": APISchemaObject.object({
        "access_token": APISchemaObject.string(),
        "token_type": APISchemaObject.string(),
        "expires_in": APISchemaObject.integer(),
        "refresh_token": APISchemaObject.string(),
        "scope": APISchemaObject.string()
      })
    });

    context.schema.register("UserRegistration", userRegistration);

    context.defer(() {
      final userSchema = context.document.components.resolve(userSchemaRef);
      userRegistration.properties.addAll(userSchema.properties);
    });
  }
}
