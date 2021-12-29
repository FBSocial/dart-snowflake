import 'package:snowflake/snowflake.dart';

void main() {
  var cfg = config(1, 2, 1288834974657);

  var worker = idWorker(cfg);
  print(worker.generate());
}
