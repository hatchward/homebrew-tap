class Hatchward < Formula
  # Rendered by bin/brew-formula and committed to influpert/homebrew-tap by the
  # `distribute` job in .github/workflows/release.yml. Do not hand-edit the copy
  # in the tap: the next release overwrites it. Edit this template instead.
  desc "Multi-instance agent-fleet orchestrator"
  homepage "https://hatchward.dev"

  # There is deliberately no `version` line. Homebrew scans one out of the URL,
  # and `brew audit --strict` fails with "version ... is redundant with version
  # scanned from URL" if it is also stated here — confirmed against this exact
  # formula, so do not "fix" this by adding it back.
  #
  # What it scans is the /download/<tag>/ path segment, NOT the filename: the
  # bare `hatchward_v1.0.0_darwin_arm64.tar.gz` would infer `64` from the
  # trailing arch digits. So the URLs below must keep the tag in the path. If
  # they ever move to a host that drops it, restore the version line in the same
  # change — the golden test in cli.yml will not notice, but every user's
  # `brew install` will.

  # The EULA has no SPDX identifier, and :cannot_represent is the documented
  # value for that. A bare string like "Proprietary" is not a valid expression
  # and fails audit.
  license :cannot_represent

  # NOT depends_on "git". Homebrew lists git among the tools macOS provides, so
  # uses_from_macos takes the system one and installs nothing; depends_on would
  # pull the git formula and its dependency tree onto every machine for no gain.
  # On Linux this degrades to a real dependency, which is what we want there.
  uses_from_macos "git"

  # Four bare Mach-O/ELF tarballs, one per target, each containing the binary
  # and LICENSE. No bottle block: bottles are for formulae Homebrew builds, and
  # `bottle :unneeded` was removed from the DSL. A tap formula shipping
  # prebuilt binaries simply has neither.
  #
  # on_linux is NOT optional. Formula#initialize runs validate_attributes!
  # unconditionally, which raises when stable.url is blank — so a macOS-only
  # formula fails to CONSTRUCT on Linux rather than failing to install, and
  # `brew install`, `info`, `search` and `readall` all die with
  # "invalid attribute for formula ... url ()".
  on_macos do
    on_arm do
      url "https://github.com/influpert/homebrew-tap/releases/download/v0.3.1/hatchward_v0.3.1_darwin_arm64.tar.gz"
      sha256 "347580c91c3314c41921adb7e3895f61871a9d8597d9aee4c1fbb5e86af7437e"
    end
    on_intel do
      url "https://github.com/influpert/homebrew-tap/releases/download/v0.3.1/hatchward_v0.3.1_darwin_amd64.tar.gz"
      sha256 "a0fd7ef9714361e27d26ba3d0e8802b1c3913a1ecad0faf3104bd9707b8cf8f4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/influpert/homebrew-tap/releases/download/v0.3.1/hatchward_v0.3.1_linux_arm64.tar.gz"
      sha256 "8ceff5c0e260e71d845c273ed2aae30623f9057f7ed2d1180a20f48dfd8acc1c"
    end
    on_intel do
      url "https://github.com/influpert/homebrew-tap/releases/download/v0.3.1/hatchward_v0.3.1_linux_amd64.tar.gz"
      sha256 "7eb25097ca1603defe453a737bafe17971b695e3d06687721a856f33b8d89ec6"
    end
  end

  def install
    bin.install "hatchward"
    # hatchward is licensed, not sold, and the tarball is world-downloadable.
    # The terms travel with it.
    doc.install "LICENSE"
  end

  # Homebrew re-signs a Mach-O ad-hoc if keg relocation rewrites it. That never
  # fires here — a CGO_ENABLED=0 Go binary carries no Cellar paths to rewrite —
  # but if a Developer ID signature is ever added upstream, check that this
  # still holds before trusting the installed binary to be notarized.

  test do
    assert_match "v0.3.1", shell_output("#{bin}/hatchward --version")
  end
end
