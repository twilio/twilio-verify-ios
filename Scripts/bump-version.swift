#!/usr/bin/swift
// swiftlint:disable nesting

import Foundation

struct VersionNumber {
  var key: String
  var version: String
}

struct Constants {
  static let versionFileRelativePath = "../TwilioVerify/Config/Version.xcconfig"
  static let missingArgumentsError = """
  Expected version argument not set correctly e.g. 0.1.0
  """
  struct Separator {
    static let dot = "."
    static let space = " "
    static let newLine = "\n"
  }
}

func bumpVersion() {
  guard CommandLine.argc > 1, CommandLine.arguments[1].components(separatedBy: Constants.Separator.dot).count == 3  else {
    print(Constants.missingArgumentsError)
    return
  }
  let nextVersion = CommandLine.arguments[1]
  print("Bumping version to \(nextVersion)")
  var versionNumber = currentVersionNumber()
  versionNumber.version = nextVersion
  updateFile(withVersion: versionNumber)
}

func currentVersionNumber() -> VersionNumber {
  let versionFilePath = versionFilePathURL()
  do {
    let fileContents = try String(contentsOf: versionFilePath, encoding: .utf8)
    let marketingVersionComponents = fileContents.components(separatedBy: Constants.Separator.newLine)[0]
                                      .components(separatedBy: Constants.Separator.space)
    let versionKey = marketingVersionComponents[0]
    let currentVersion = marketingVersionComponents.last!
    return VersionNumber(key: versionKey, version: currentVersion)
  } catch {
    print(error.localizedDescription)
  }
  return VersionNumber(key: String(), version: String())
}

func updateFile(withVersion versionNumber: VersionNumber) {
  let versionFilePath = versionFilePathURL()
  let newVersion = "\(versionNumber.key) = \(versionNumber.version)"
  do {
    try newVersion.write(to: versionFilePath, atomically: true, encoding: .utf8)
  } catch {
    print(error.localizedDescription)
  }
}

func versionFilePathURL() -> URL {
  let currentPathURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  return currentPathURL.appendingPathComponent(Constants.versionFileRelativePath)
}

@discardableResult
func shell(_ args: String...) -> Int32 {
  let task = Process()
  task.launchPath = "/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core/git"
  task.arguments = args
  task.launch()
  task.waitUntilExit()
  return task.terminationStatus
}

bumpVersion()
