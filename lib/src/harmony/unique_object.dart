part of harmony;

class UniqueObject {
  int _instanceId;
  int get instanceId {
    if(_instanceId == null) generateIdFor(this);
    return _instanceId;
  }
}

final GUIDGen _generator = new GUIDGen();
final Set<int> _ids = new Set<int>();
void generateIdFor(UniqueObject obj) {
  int newID = _generator.generate();
  while(_ids.contains(newID)) {
    newID = _generator.generate();
  }
  obj._instanceId = newID;
  _ids.add(newID);
}

void removeId(UniqueObject obj) {
  if(obj._instanceId == null) return;
  _ids.remove(obj._instanceId);
  obj._instanceId = null;
}


class GUIDGen {
  final Random _random = new Random(new DateTime.now().millisecond);
  int generate() {
    final String hexDigits = "01234567890123456";
    final List<String> uuid = new List<String>(18);

    for (int i = 0; i < 18; i++) {
      final int hexPos = _random.nextInt(16);
      uuid[i] = (hexDigits.substring(hexPos, hexPos + 1));
    }

    int pos = (int.parse(uuid[10], radix: 16) & 0x3) | 0x8;

    uuid[7] = "4";
    uuid[10] = hexDigits.substring(pos, pos + 1);

    uuid[4] = uuid[6] = uuid[9] = uuid[11] = "0";

    final StringBuffer buffer = new StringBuffer();
    buffer.writeAll(uuid);
    return int.parse(buffer.toString());
  }
}