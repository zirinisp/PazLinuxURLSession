import PackageDescription

let package = Package(
    name: "PazLinuxURLSession",
    dependencies: [
        .Package(url: "https://github.com/ibm-bluemix-mobile-services/bluemix-simple-http-client-swift.git", majorVersion: 0)
    ]
)
