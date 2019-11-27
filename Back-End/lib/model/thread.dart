import '../useful.dart';

class Thread extends ManagedObject<_Thread>
    implements _Thread, ManagedAuthResourceOwner<_Thread> {
  @override
  void willUpdate() {
//    updateTime = DateTime.now();
  }

  @override
  void willInsert() {
    createTime = DateTime.now();
    updateTime = createTime;
  }
}

class _Thread {
  @primaryKey
  int tid;

  @Column(defaultValue: null)
  int fid;

  @Column(defaultValue: r"Untitled Topic")
  @Validate.length(lessThan: 50, onInsert: true, onUpdate: true)
  String topic;

  @Column(defaultValue: null)
  Document abstract;

  @Column(defaultValue: null)
  Document body;

  @Column(defaultValue: null)
  int author;

  @Column(defaultValue: r"0")
  int view;

  @Column(defaultValue: r"0")
  int reply;

  @Column(defaultValue: r"2")
  int nextFloor;

  @Column(defaultValue: null)
  DateTime createTime;

  @Column(defaultValue: null)
  DateTime updateTime;
}
