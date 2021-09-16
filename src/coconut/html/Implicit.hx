package coconut.html;

import coconut.ui.internal.ImplicitContext;
import coconut.html.RenderResult.RenderResultObject;

class Implicit implements RenderResultObject {

  final children:Children;
  final defaults:ImplicitValues;

  public function new(attr) {
    this.children = attr.children;
    this.defaults = attr.defaults;
  }

  public function renderInto(implicits:ImplicitContext, buffer:HtmlBuffer) {
    var ctx = new ImplicitContext(implicits);
    ctx.update(defaults);
    for (c in children)
      c.renderInto(ctx, buffer);
  }
}