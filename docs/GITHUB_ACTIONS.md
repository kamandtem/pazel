# GitHub Actions

The repository includes `.github/workflows/verify.yml`. On `push`, pull request and manual dispatch it runs the source bootstrap, formatter, analyzer, tests, debug APK build and Web build. It uploads the APK and coverage.

`release-apk` runs on `main` pushes and manual dispatch after verification and uploads a second debug APK named with the commit SHA. This is intentionally not a signed Play Store release. Add a separate protected release workflow with GitHub Environments and encrypted keystore secrets only after local/device QA.

The bootstrap creates a temporary official Flutter project because this source delivery did not include generated SDK wrappers. It copies missing Android/iOS/Web platform files and Gradle wrapper files without overwriting custom source. The first CI run is the real integration check.
