# Pocket Clock

A small native iPhone clock: analog face, digital time with seconds, local date/time zone, 12/24-hour switch, and an optional keep-screen-awake switch. Preferences persist. The clock follows your phone's time and works offline. No ads, accounts, analytics, dependencies, or paid APIs. Requires iOS 17 or later; exact iOS 27 beta / LiveContainer compatibility needs a device test.

## Free build from Windows

Use a **public** GitHub repository and the included standard `macos-15` runner. GitHub documents standard hosted runners as free for public repositories: https://docs.github.com/en/actions/reference/runners/github-hosted-runners . This project doesn't require a paid Apple developer membership or GitHub secrets. Your source code will be public. The workflow skips its build job in private repositories to keep this on the free public-repository path.

1. Sign in to GitHub and create a new **public** repository named `pocket-clock`. Adding a README when creating it makes the upload screen easy to find.
2. Extract `PocketClock-source.zip` on Windows. Open the extracted `PocketClock` folder.
3. In the repository, choose **Add file → Upload files**. Drag the **contents** of that folder into GitHub, including `.github`, `PocketClock`, `PocketClock.xcodeproj`, `scripts`, and the root files. Commit the upload. Do not upload the ZIP itself or an extra outer `PocketClock` folder.
4. Verify `.github/workflows/build-ipa.yml` appears in the repository. If your browser omitted `.github`, choose **Add file → Create new file**, enter `.github/workflows/build-ipa.yml`, and paste the text of the supplied workflow file. Commit it.
5. Open **Actions → Build Pocket Clock IPA**. The upload should start a build on `main` or `master`. You can also choose **Run workflow** on the default branch. Enable Actions if GitHub prompts you.
6. After the run turns green, open that run and download **PocketClock-IPA** from **Artifacts**. You must be signed in. Extract the artifact ZIP to get `PocketClock.ipa`. Artifacts are retained for 14 days; rerun to get another copy.

Expected root layout:

```text
.github/workflows/build-ipa.yml
PocketClock/PocketClockApp.swift
PocketClock/Info.plist
PocketClock/Assets.xcassets/...
PocketClock.xcodeproj/project.pbxproj
PocketClock.xcodeproj/xcshareddata/xcschemes/PocketClock.xcscheme
scripts/build-ipa.sh
scripts/package-ipa.py
README.md
```

## Open it on your phone

Save `PocketClock.ipa` in Files on your iPhone. In your already configured LiveContainer, tap **+**, select the IPA, then launch Pocket Clock. LiveContainer handles guest signing with its configured certificate. See its official instructions: https://github.com/LiveContainer/LiveContainer#installing-apps .

Alternatively import it through SideStore's **My Apps → +** for a separately installed app. SideStore handles signing with your free Apple account; normal free-account app limits and refresh requirements still apply. Do not upload your Apple credentials, certificates, or provisioning profiles to GitHub.

This is a clock display, not an alarm app. “Keep screen awake” applies only while this app is active. Turning it off restores normal auto-lock; backgrounding the app also releases its idle-timer setting.

## Build details and status

The workflow uses Xcode on GitHub's Mac to compile a Release arm64 iPhoneOS app with account signing disabled, then ZIPs the app under `Payload/PocketClock.app` into an IPA. SideStore/LiveContainer supplies signing afterward. The packager checks for an arm64 Mach-O executable and an iPhoneOS bundle before producing the IPA. No simulator binary is shipped.

The source package was prepared on Windows. Local structure and packaging checks do not substitute for an Xcode build or a phone test. The first successful GitHub Actions run is the compilation check. No compiled IPA is included in this source ZIP.

If a build fails, open the failed **Build and package for sideloading** step and share its error text. If import or launch fails, share the exact error and your LiveContainer/SideStore versions.

On a Mac with Xcode installed, the same build is `bash scripts/build-ipa.sh`. To change the app later, edit `PocketClock/PocketClockApp.swift`, commit, and download the new artifact after the next build.
