# SwiftDotenv

A one-stop shop for working with environment values in a Swift program. 

## Overview

`SwiftDotenv` is a small and compact Swift package that allows you to load and save `.env` files at runtime and query for those values as well as system provided environemntal values via `ProcessInfo`. It's a single abstraction for dealing with environment variables at runtime as well as a handy mechanism keeping your secrets and private keys safe in a local configuration file that doesn't get committed to version control, rather than hardcoding secret strings into your app or framework.

### What is a `.env` file?

`.env` files are used, most often in server-side applications, to inject environment variables into an application during active development. They can contain api keys, secrets, and other sensitive information and therefore **should not be committed to version control**. An environment file should only exist locally on a development machine; on a continuous integration system like TravisCI or CircleCI, environment variables are added via the respective UI in lieu of a `.env` file.

## Installation

`SwiftDotenv` supports Swift Package Manager and can be added by adding this entry to your `Package.swift` manifest file:

```swift
.package(url: "https://github.com/thebarndog/swift-dotenv.git", .upToNextMajor("1.0.0"))
```

## Usage

```swift
import SwiftDotenv
```

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

By default, `Dotenv` uses `FileManger.default` to load and save files but even that can be swapped out:

```swift
Dotenv.fileManger = someCustomInstance
```

### `ProcessInfo` & `FallbackStrategy`

If a value doesn't exist in the set of values fetched from your `.env` file, `Environment` will then fallback and look in `ProcessInfo` for the desired value. Custom fallback strategies can be also be set so that `Environment` will query first from `ProcessInfo` and then to the environment values pulled from the configuration file. 

The default fallback strategy is `.init(query: .configuration, fallback: .process)` meaning `Environment` will first look for the value in the configuration file and then fallback to `ProcessInfo` if it can't find it. The `fallback` parameter can also be `nil`, removing fallback functionality. 

To modify the fallback strategy:

```swift
Environment.fallbackStrategy = .init(query: .process)
```  

### Contributing

If you find a bug, have an idea for a feature request, or want to help out, please open an issue describing your problem or a pull request with your feature. Please follow the [Code of Conduct](.github/CodeOfConduct.md) at all times.

Made with Swift and ❤️.
