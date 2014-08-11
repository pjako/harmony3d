part of harmony;

class Debug {
  static DebugDrawManager get _debugDraw => _renderDevice.debug;


  static final Vector4 _debugColor = new Vector4(1.0,0.0,0.0,1.0);



  /** Add a line primitive extending from [start] to [finish].
   * Filled with [color].
   *
   * Optional parameters: [duration] and [depthEnabled].
   */
  static void drawLine(Vector3 start, Vector3 finish, Vector4 color,
               {num duration: 0.0, bool depthEnabled: true}) {
    _debugDraw.drawLine(start, finish, color, duration, depthEnabled);
  }

  /** Add a cross primitive at [point]. Filled with [color].
   *
   * Optional paremeters: [size], [duration], and [depthEnabled].
   */
  static void drawCross(Vector3 point, Vector4 color,
                {num size: 1.0, num duration: 0.0, bool depthEnabled:true}) {
    _debugDraw.drawCross(point, color, size, duration, depthEnabled);
  }

  /** Add a sphere primitive at [center] with [radius]. Filled with [color].
   *
   * Optional paremeters: [duration] and [depthEnabled].
   */
  static void drawSphere(Vector3 center, num radius, Vector4 color,
                 {num duration: 0.0, bool depthEnabled: true}) {
    _debugDraw.drawSphere(center, radius, color, duration, depthEnabled);
  }
  /// Add a plane primitive whose normal is [normal] at is located at
  /// [center]. The plane is drawn as a grid of [size] square. Drawn
  /// with [color].
  /// Optional parameters: [duration], [depthEnabled] and [numSegments].
  static void drawPlane(Vector3 normal, Vector3 center, double size,
                Vector4 color, {num duration: 0.0, bool depthEnabled: true,
                int numSegments: 16}) {
    _debugDraw.drawPlane(normal, center, size, color, duration, depthEnabled, numSegments);
  }

  /** Add a cone primitive at [apex] with [height] and [angle]. Filled with
   *  [color].
   *
   * Optional parameters: [duration], [depthEnabled] and [numSegments].
   */
  static void drawCone(Vector3 apex, Vector3 direction, num height, num angle,
               Vector4 color, num duration, bool depthEnabled,
               int numSegments) {
    _debugDraw.drawCone(apex, direction, height, angle, color, duration, depthEnabled, numSegments);
  }

  /** Add an arc primitive at [center] in the plane whose normal is
   * [planeNormal] with a [radius]. The arc begins at [startAngle] and extends
   * to [stopAngle]. Filled with [color].
   *
   * Optional parameters: [duration], [depthEnabled], and [numSegments].
   */
  static void drawArc(Vector3 center, Vector3 planeNormal, num radius, num startAngle,
              num stopAngle, Vector4 color, {num duration: 0.0,
              bool depthEnabled: true, int numSegments: 16}) {
    _debugDraw.drawArc(center, planeNormal, radius, startAngle, stopAngle, color, duration, depthEnabled, numSegments);
  }

  /** Add an circle primitive at [center] in the plane whose normal is
   * [planeNormal] with a [radius]. Filled with [color].
   *
   * Optional parameters: [duration], [depthEnabled], and [numSegments].
   */
  static void drawCircle(Vector3 center, Vector3 planeNormal, num radius, Vector4 color,
                 {num duration: 0.0, bool depthEnabled: true,
                 int numSegments: 16}) {
    _debugDraw.drawCircle(center, planeNormal, radius, color, duration, depthEnabled, numSegments);
  }

  /// Add a coordinate system primitive. Derived from [xform]. Scaled by [size].
  ///
  /// X,Y, and Z axes are colored Red,Green, and Blue
  ///
  /// Optional paremeters: [duration], and [depthEnabled]
  static void drawAxes(Matrix4 xform, num size,
               {num duration: 0.0, bool depthEnabled: true}) {
    _debugDraw.drawAxes(xform, size, duration, depthEnabled);
  }

  /// Add a triangle primitives from vertices [vertex0], [vertex1],
  /// and [vertex2]. Filled with [color].
  ///
  /// Optional parameters: [duration] and [depthEnabled]
  static void drawTriangle(Vector3 vertex0, Vector3 vertex1, Vector3 vertex2, Vector4 color,
                   {num duration: 0.0, bool depthEnabled: true}) {
    _debugDraw.drawTriangle(vertex0, vertex1, vertex2, color, duration, depthEnabled);
  }

  /// Add an Axis Aligned Bounding Box with corners at [boxMin] and [boxMax].
  /// Filled with [color].
  ///
  /// Option parameters: [duration] and [depthEnabled]
  static void drawAABB(Vector3 boxMin, Vector3 boxMax, Vector4 color,
               {num duration: 0.0, bool depthEnabled: true}) {
    _debugDraw.drawAABB(boxMin, boxMax, color, duration, depthEnabled);
  }

}