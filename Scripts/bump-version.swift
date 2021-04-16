#!/usr/bin/swift

import Foundation

struct Constants {
  static let configFileRelativePath = "../TwilioVerifySDK/TwilioVerify/Sources/TwilioVerifyConfig.swift"
  static let plistFileRelativePath = "../TwilioVerifySDK/Info.plist"
  static let missingArgumentsError = """
  Expected version argument not set correctly e.g. 0.1.0
  """
  static let versionKey = "version"
  static let bundleShortVersionKey = "CFBundleShortVersionString"
  
  struct Separator {
    static let dot = "."
    static let equal: Character = "="
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
  updateConfigFile(withVersion: nextVersion)
  updatePlistFile(withVersion: nextVersion)
}

func updateConfigFile(withVersion newVersion: String) {
  let configFilePath = configFilePathURL()
  do {
    var fileContents = try String(contentsOf: configFilePath, encoding: .utf8)
    let versionComponents: [String] = fileContents.components(separatedBy: Constants.Separator.newLine).map {
      if $0.contains(Constants.versionKey) {
        let currentVersion = $0.split(separator: Constants.Separator.equal)[1].trimmingCharacters(in: .whitespacesAndNewlines)
        return $0.replacingOccurrences(of: currentVersion, with: "\"\(newVersion)\"")
      } else {
        return $0
      }
    }
    fileContents = versionComponents.joined(separator: Constants.Separator.newLine)
    try fileContents.write(to: configFilePath, atomically: true, encoding: .utf8)
  } catch {
    print(error.localizedDescription)
  }
}

func configFilePathURL() -> URL {
  let currentPathURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  return currentPathURL.appendingPathComponent(Constants.configFileRelativePath)
}

func updatePlistFile(withVersion newVersion: String) {
  guard var plistDictionary = NSDictionary(contentsOfFile: Constants.plistFileRelativePath) as? [String: Any] else {
    return
  }
  plistDictionary.updateValue(newVersion, forKey: Constants.bundleShortVersionKey)
  (plistDictionary as NSDictionary).write(toFile: Constants.plistFileRelativePath, atomically: true)
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
