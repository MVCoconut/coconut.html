# Coconut HTML backend

A special coconut backend to render plain HTML, for use in static generators and server side rendering.

Usage:

```haxe
coconut.html.Renderer.render('
  <div>Hello world!</div>
');
```

This will give you a [`tink.HtmlString`](https://github.com/haxetink/tink_htmlstring#tinkerbell-html-string), which you can serve, dump into a file, or process in any other way you may see fit.

## Code removal

Because `coconut.html` can run on any platform, it removes quite a bit of code intended for client side use:

- DOM event handlers
- refs
- life cycle callbacks
- any fields annotated with `@:clientside`

All the removed code is not type checked, so that views which compile fine for the server may produce errors when you switch to client.
