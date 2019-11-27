import '../useful.dart';

class User extends ManagedObject<_User>
    implements _User, ManagedAuthResourceOwner<_User> {
  @Serialize(input: true, output: false)
  String password;
}

class _User extends ResourceOwnerTableDefinition {
/* This class inherits the following from ManagedAuthenticatable:

  @primaryKey
  int id;

  @Column(unique: true, indexed: true)
  String username;

  @Column(omitByDefault: true)
  String hashedPassword;

  @Column(omitByDefault: true)
  String salt;

  ManagedSet<ManagedAuthToken> tokens;
 */
  @Column(unique: true)
  @Validate.matches(r"^[a-zA-Z0-9_-]+@[a-zA-Z0-9-\.]+\.[a-zA-Z0-9]+$", onInsert: true, onUpdate: true)
  String email;

  @Column(defaultValue: r"default.png")
  String avatarurl;
}
