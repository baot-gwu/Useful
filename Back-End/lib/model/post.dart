import '../useful.dart';

class Post extends ManagedObject<_Post>
    implements _Post, ManagedAuthResourceOwner<_Post> {
  @override
  void willUpdate() {
    updateTime = DateTime.now();
  }

  @override
  void willInsert() {
    createTime = DateTime.now();
    updateTime = createTime;
  }
}

class _Post {
  @primaryKey
  int pid;

  @Column(defaultValue: null)
  int tid;

  @Column(nullable: true)
  String topic;

  @Column(defaultValue: null)
  Document body;

  @Column(defaultValue: null)
  int postIndex;

  @Column(defaultValue: null)
  int author;

  @Column(defaultValue: null)
  DateTime createTime;

  @Column(defaultValue: null)
  DateTime updateTime;
}
