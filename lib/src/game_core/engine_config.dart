part of game_core;


class Physics2DMode {
  final int _i;
  const Physics2DMode(this._i);

  static const Physics2DMode xy = const Physics2DMode(0);
  static const Physics2DMode xz = const Physics2DMode(0);

}

class EngineConfig {
  static bool useSimd = false;
  static Physics2DMode physics2dMode = Physics2DMode.xy;

}