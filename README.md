# Coconut HTML backend

A special coconut backend to render plain HTML, for use in static generators and server side rendering.

## Code removal

Because coconut.html can run on any platform, it removes quite a bit of code intended for client side use:

- DOM event handlers
- refs
- life cycle callbacks
- any fields prefixed annotated with `@:clientside`

All the removed code is not type checked, so code that compiles fine for the server may produce errors when you switch to client.
