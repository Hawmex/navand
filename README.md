<div align="center">

<img
    alt="Navand"
    style="width: 100%"
    src="https://raw.githubusercontent.com/Hawmex/Hawmex/main/assets/banner.svg"
/>

---

[ [GitHub](https://github.com/Hawmex/navand) |
[Wiki](https://github.com/Hawmex/navand/wiki) |
[Pub](https://pub.dev/packages/navand) |
[API Reference](https://pub.dev/documentation/navand) ]

---

</div>

Navand, meaning "a swift horse" in Persian, is a web framework in Dart that lets
developers create UIs with a widget model similar to Flutter. Navand apps are
compiled into JS and painted using HTML & CSS.

- [Code of Conduct](./CODE_OF_CONDUCT.md)
- [Contributing to Navand](./CONTRIBUTING.md)
- [Changelog](./CHANGELOG.md)

### Features

- **Command-Line Tool**: Navand has a command-line tool that scaffolds, serves,
  and builds your applications.
- **Navigation**: Navand offers a navigation solution called `Navigator`,
  providing a seamlessly native experience.
- **Styled Widgets**: Navand includes an API for styling your widgets. The
  `Style` API is inspired by the declaration blocks in CSS rulesets.
- **Animated Widgets**: You can use Navand's animation system to improve the UI
  of your application. The `Animation` API is designed similar to the animation
  API of JavaScript.
- **Stateful Widgets & Global State Management**: You can add reactivity to your
  applications using the `StatefulWidget` base class. Moreover, you can tailor a
  global state management solution by utilizing the `Store`, `Provider`,
  `ConsumerWidget`, and `ConsumerBuilder` APIs together.
- **Support for Asynchronous Data Flow**: Futures and streams can be dealt with
  using widgets such as `FutureBuilder` and `StreamBuilder`.
- **Dependency Injection**: The `InheritedWidget` API can be used to inject
  dependencies through the application tree.
- **Extensibility**: Navand's API can be extended in almost every way. For
  instance, you can create widgets that paint any HTML element on the screen.
