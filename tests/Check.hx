using StringTools;

class Check {
  public final failures = new Array<String>();

  public function new() {}

  public function html(expected:String, actual:String, ?pos:haxe.PosInfos)
    if (normalize(actual) != normalize(expected))
      failures.push('${pos.fileName}:${pos.lineNumber}:\n  expected $expected\n       got $actual');

  static final VOID = ['area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'source', 'track', 'wbr'];

  /**
    Sorts the attributes of each start tag, because their order depends on the target,
    and drops the slash of void tags.
  **/
  static function normalize(html:String)
    return ~/<([a-zA-Z][a-zA-Z0-9]*)((?:\s+[^\s=>\/]+(?:="[^"]*")?)*)\s*(\/?)>/g.map(html, tag -> {
      var name = tag.matched(1),
          attrs = [],
          attrRe = ~/\s+([^\s=>\/]+(?:="[^"]*")?)/g,
          rest = tag.matched(2);
      while (attrRe.match(rest)) {
        attrs.push(attrRe.matched(1));
        rest = attrRe.matchedRight();
      }
      attrs.sort(Reflect.compare);
      var slash = if (tag.matched(3) == '/' && !VOID.contains(name)) '/' else '';
      '<' + [name].concat(attrs).join(' ') + slash + '>';
    });
}
