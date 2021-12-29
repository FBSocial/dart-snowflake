library snowflake;

part 'config.dart';

int millisecond(int id, int epoch) {
  return id >> 22 + epoch;
}

int machine(int id) {
  return id >> 12 & 0x1f;
}

int dataCenter(int id) {
  return id >> 17 & 0x1f;
}

abstract class idWorker {
  factory idWorker(config cfg) {
    return _idWorker._(
        machine: (cfg as _config).machine & 0x1f,
        dataCenter: cfg.dataCenter & 0x1f,
        epoch: cfg.epoch);
  }

  external int generate();
}

class _idWorker implements idWorker {
  final int machine;
  final int dataCenter;
  final int epoch;
  int sequence;
  int lastTimestamp;

  _idWorker._(
      {required this.machine, required this.dataCenter, required this.epoch})
      : sequence = 0,
        lastTimestamp = -1;

  @override
  int generate() {
    var timeGen = (int? epoch) {
      return DateTime.now().millisecondsSinceEpoch - epoch!;
    };

    var t = timeGen(epoch);
    if (t != lastTimestamp) {
      sequence = 0;
      lastTimestamp = t;
      var id = lastTimestamp << 22;
      id |= (dataCenter << 17);
      id |= (machine << 12);
      id |= sequence;

      return id;
    }

    sequence = (sequence + 1) & 0xfff;
    if (sequence == 0) {
      while (true) {
        t = timeGen(epoch);
        if (t > lastTimestamp) {
          break;
        }
      }
    }

    lastTimestamp = t;
    var id = lastTimestamp << 22;
    id |= (dataCenter << 17);
    id |= (machine << 12);
    id |= sequence;

    return id;
  }
}
