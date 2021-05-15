package coconut.html;

import tink.state.*;
import coconut.ui.internal.ImplicitContext;

@:build(coconut.ui.macros.ViewBuilder.build((_:coconut.html.RenderResult)))
@:autoBuild(coconut.html.View.build())
class View extends ViewBase {
  macro function hxx(e);
}

class ViewBase implements RenderResult.RenderResultObject {

  @:noCompletion final __rendered:Observable<RenderResult>;
  @:noCompletion final __coco_implicits_ = new State<ImplicitContext>(null);
  @:noCompletion var __coco_implicits(get, never):ImplicitContext;
    @:noCompletion inline function get___coco_implicits()
      return __coco_implicits_.value;

  public function new(o, _, _, _)
    this.__rendered = o;

  public function renderInto(implicits, buffer:HtmlBuffer) {
    __coco_implicits_.set(implicits);
    __rendered.value.renderInto(implicits, buffer);
  }

}