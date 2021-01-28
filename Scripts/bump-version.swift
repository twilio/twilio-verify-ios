#!/usr/bin/swift

import Foundation

struct Constants {
  static let versionFileRelativePath = "../TwilioVerify/TwilioVerify/Sources/TwilioVerifyConfig.swift"
  static let missingArgumentsError = """
  Expected version argument not set correctly e.g. 0.1.0
  """
  static let versionKey = "version"
  
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
  updateFile(withVersion: nextVersion)
}

func updateFile(withVersion newVersion: String) {
  let versionFilePath = versionFilePathURL()
  do {
    var fileContents = try String(contentsOf: versionFilePath, encoding: .utf8)
    let versionComponents: [String] = fileContents.components(separatedBy: Constants.Separator.newLine).map {
      if $0.contains(Constants.versionKey) {
        let currentVersion = $0.split(separator: Constants.Separator.equal)[1].trimmingCharacters(in: .whitespacesAndNewlines)
        return $0.replacingOccurrences(of: currentVersion, with: "\"\(newVersion)\"")
      } else {
        return $0
      }
    }
    fileContents = versionComponents.joined(separator: Constants.Separator.newLine)
    try fileContents.write(to: versionFilePath, atomically: true, encoding: .utf8)
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
