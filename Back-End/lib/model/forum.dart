import '../useful.dart';

class Forum extends ManagedObject<_Forum>
    implements _Forum, ManagedAuthResourceOwner<_Forum> {}

class _Forum {
  @primaryKey
  int fid;

  @Column(indexed: true)
  String name ;

  @Column(defaultValue: r"")
  String description;

  @Column(defaultValue: r"default.png")
  String icon;

  @Column(defaultValue: r"[]")
  Document admins;

  @Column(defaultValue: r"")
  String bulletin;

  @Column(defaultValue: r"[]")
  Document widgets;
}
