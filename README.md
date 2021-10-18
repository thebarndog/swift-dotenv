# SwiftDotenv

A Swift micro-framework for loading and using `.env` files in a Swift framework or application.

## Overview

`SwiftDotenv` is a small and compact Swift package that allows you to load and save `.env` files at runtime.

### What is a `.env` file?

`.env` files are used, most often in server-side applications, to inject environment variables into an application during active development. They can contain api keys, secrets, and other sensitive information and therefore **should not be committed to version control**. An environment file should only exist locally on a development machine; on a continuous integration system like TravisCI or CircleCI, environment variables are added via the respective UI in lieu of a `.env` file.

## Installation

`SwiftDotenv` supports Swift Package Manager and can be added by adding this entry to your `Package.swift` manifest file:

```swift
.package(url: "https://github.com/thebarndog/swift-dotenv.git", .upToNextMajor("1.0.0"))

import SwiftDotenv
```

## Usage

### `Environment`

`Environment` is an immutable model representing an `.env` file. It can be created by loading it via the `Dotenv` structure or created in code via dictionary literals. `Environment` uses type-safe representations of environment values such as `.boolean(Bool)` or `.integer(Int)`.

To create an environment from scratch:

```swift
let environment = try Environment(values: ["API_KEY": "some-key"])
```

or with the type-safe api:

```swift
let environment = try Environment(values: ["FEATURE_ON": .boolean(true)])
```

`Environment` also supports `@dynamicMemberLookup`:

```swift
let environment = try Environment(values: [
    "apiKey": "some-key",
    "onboardingEnabled": false
])

let key = environment.apiKey // "some-key"
let enabled = environment.onboardingEnabled // false
```

**Note**: Keys that use snake case or dashes will not work with dynamic member lookup as the special characters aren't easily translated to property names.

### `Dotenv`

To load an environment from a `.env` file, use `Dotenv.load(path:)`:

```swift
let environment = try Dotenv.load(path: ".env")
```

Enviroments that were created programmatically can also be saved to disk via `Dotenv.save(environment:toPath:force:)`: 

```swift
let environment = try Environment(values: ["API_KEY": "some-key"])
try Dotenv.save(environment, atPath: ".env", force: false) // wont overwrite an existing file when force == false
```

### Contributing

If you find a bug, have an idea for a feature request, or want to help out, please open an issue describing your problem or a pull request with your feature. Please follow the [Code of Conduct](.github/CodeOfConduct.md) at all times.

Made with Swift and ❤️.
