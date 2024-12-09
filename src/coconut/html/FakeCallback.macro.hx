package coconut.html;

abstract FakeCallback(Dynamic) {
  static function create(e:haxe.macro.Expr) {
    return switch e.expr {
      case EConst(CString(_)): macro @:pos(e.pos) cast $e;
      default: macro null;
    }
  }
}