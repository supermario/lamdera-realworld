# ![RealWorld Example App](logo.png)

> ### Lamdera port of [elm-spa realworld frontend](https://github.com/ryannhg/elm-spa-realworld), adding a full backend implementation.


### [Demo](https://realworld.lamdera.app/)&nbsp;&nbsp;&nbsp;&nbsp;[RealWorld Spec](https://github.com/gothinkster/realworld)


You can take a look at how the conversion progressed in two PRs:

- [#1](https://github.com/supermario/lamdera-realworld/pull/1) Porting all HTTP API calls to `Lamdera.sendToBackend` and removing all JSON encoders/decoders
- [#2](https://github.com/supermario/lamdera-realworld/pull/2) Implementing the full Realworld backend functionality in Elm


# How it works

This application was built with

- [Lamdera](https://lamdera.com), a delightful platform
for full-stack web apps
- [elm-spa](https://elm-spa.dev), a friendly tool for building SPAs with Elm!

Check out the [the source code](./src) to get a feel for the project structure!


# Getting started

Clone the project and boot the Lamdera local dev environment:

```
git clone git@github.com:supermario/lamdera-realworld.git
cd lamdera-realworld
lamdera reset
lamdera live
```

For any `elm-spa` changes, such as vendoring one of the `.elm-spa` defaults, re-run `elm-spa make`.

Note: the `.elm-spa` folder currently needs to be committed to successfully deploy, as Lamdera doesn't run elm-spa build commands.

See [Getting Started](https://lamdera.com/start) if you're new to Lamdera.
