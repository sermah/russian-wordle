class IntVec2 {
  final int x;
  final int y;

  const IntVec2(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (other is! IntVec2) return false;
    return (x == other.x) && (y == other.y);
  }

  @override
  int get hashCode => (x << 32) | (y & 0xFFFFFFFF00000000);
}