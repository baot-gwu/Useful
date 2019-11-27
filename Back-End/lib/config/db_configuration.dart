import 'package:useful/useful.dart';

ManagedContext getContext(String fileName) {
  final config = DataConfiguration(fileName);
  return contextWithConnectionInfo(config.database);
}

ManagedContext contextWithConnectionInfo(DatabaseConfiguration connectionInfo) {
  final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
  final psc = PostgreSQLPersistentStore(
      connectionInfo.username,
      connectionInfo.password,
      connectionInfo.host,
      connectionInfo.port,
      connectionInfo.databaseName);

  return ManagedContext(dataModel, psc);
}

class DataConfiguration extends Configuration {
  DataConfiguration(String fileName) : super.fromFile(File(fileName));
  DatabaseConfiguration database;
}
