# Swiftdown

![status: archived](https://img.shields.io/badge/status-archived-lightgrey.svg)
![maintenance: inactive](https://img.shields.io/badge/maintenance-inactive-red.svg)
![type: cli-tool](https://img.shields.io/badge/type-cli--tool-blue.svg)

> Because Markdown was too mainstream.

**Swiftdown** lets you write entire technical articles using Swift files. Comments become prose. Code stays as code.

![](swiftdown.png)

## Motivation

Writing in Markdown is fine. But for developers writing about Swift, it's disconnected. Swiftodwn keeps everything in the same medium:

- Write and explain code using `//` comments.
- Structure your article using code blocks.
- Export to HTML in one command.

All within the comfort of a `.swift` file.

## Features

- `//` and `///` comments are treated as narrative content.
- Code blocks are preserved with syntax highlighting.
- Generates a standalone `.html` file (no assets or dependencies).
- Command-line usage.

## 📹 Demo


https://github.com/user-attachments/assets/1558827f-cb87-45d3-92f6-f3ecb8680c7f


## 📦 Installation

Clone this repo and build:

```bash
git clone https://github.com/crisrojas/swiftdown
cd swiftdown
swift build -c release
```

Then add the binary to your path or use directly from .build/release/swiftdown.

## Usage

You need to structure your project as follows:

```
|- your-swift-blog
    |- sources  
    |- theme
```

Then pass it to the CLI

```bash
~ swiftdown build your-swift-blog
```

Alternatively, you can also serve the contents:

```bash
~ swiftdown serve your-swift-blog
```

## 🧑‍💻 Use Cases

- Technical blog posts written entirely in Swift.
- Annotated code walkthroughs.
- Educational examples and tutorials.
- Reproducible code + prose workflows for teams.

## 🛣️ Roadmap

This project started as an experiment. I was tired of copy-pasting code from playgrounds into articles. I thought: why not write articles in Swift, using Swift itself?

The idea has merit, and some real utility, but also caveats.

Still, Swiftdown is mostly feature-complete. If I ever revisit it, I’d like to add:
- Export to self-contained .html articles `swiftdown Article.swift > article.html`
- Project navigation, displaying files and folders with their icons.

And overall, a more Xcode-like look and feel. Imagine pointing it at your whole project and having it rendered — wouldn’t that be cool?

## License

MIT — You are free to use, modify, and distribute this project. Attribution is required.

## Credits

- Theme toggle styles adapted from [theme-toggles](https://github.com/AlfieJones/theme-toggles) by Alfred Jones — MIT License.
- Syntax highlighting provided by [Splash](https://github.com/JohnSundell/Splash) by John Sundell.
