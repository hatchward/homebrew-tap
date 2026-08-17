class Hatchward < Formula
  # Rendered by bin/brew-formula and committed to influpert/homebrew-tap by the
  # `distribute` job in .github/workflows/release.yml. Do not hand-edit the copy
  # in the tap: the next release overwrites it. Edit this template instead.
  desc "Multi-instance agent-fleet orchestrator"
  homepage "https://hatchward.dev"

  # Stated explicitly, and it has to be. Homebrew otherwise scans a version out
  # of the /download/<tag>/ path segment — but the tap namespaces its tags as
  # `hatchward-v1.2.3`, which does not parse as a version, so the scan falls
  # through to the filename and infers `64` from the trailing arch digits of
  # `hatchward_v1.2.3_darwin_arm64.tar.gz`. Verified: with the prefixed tag and
  # no version line, `brew info` reports `stable 64`.
  #
  # This block previously said the opposite — that stating a version fails
  # `brew audit --strict` as "redundant with version scanned from URL". That is
  # true only while the scan yields the same answer, which the namespaced tag
  # ended. Re-verified against this exact formula: `audit --strict` exits 0.
  #
  # So the two facts are linked. If the tag prefix is ever dropped, the scan
  # starts working again, this line becomes redundant, and audit starts failing
  # — change both together.
  version "0.5.1"

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
      url "https://github.com/influpert/homebrew-tap/releases/download/hatchward-v0.5.1/hatchward_v0.5.1_darwin_arm64.tar.gz"
      sha256 "400bf599d2394c925752a0d1950f54c272eb8e4cf4e2421ece0900ed6bb6b883"
    end
    on_intel do
      url "https://github.com/influpert/homebrew-tap/releases/download/hatchward-v0.5.1/hatchward_v0.5.1_darwin_amd64.tar.gz"
      sha256 "06e3454182af4afe65d07c94c4474668a0af12eec73f9bde27e0ed4eff320a96"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/influpert/homebrew-tap/releases/download/hatchward-v0.5.1/hatchward_v0.5.1_linux_arm64.tar.gz"
      sha256 "295017fd3be8861125156ad76df86271d1dcba816ff3789371e51275e17a708a"
    end
    on_intel do
      url "https://github.com/influpert/homebrew-tap/releases/download/hatchward-v0.5.1/hatchward_v0.5.1_linux_amd64.tar.gz"
      sha256 "ae0be081ab2ba35237c257b6cf3074becaf092a2611b921c9c235f9c38948a6a"
    end
  end

  def install
    bin.install "hatchward"
    # hatchward is licensed, not sold, and the tarball is world-downloadable.
    # The terms travel with it.
    doc.install "LICENSE"
  end

  # `brew services start hatchward` runs the control plane, for operators who
  # manage everything else on the box that way.
  #
  # opt_bin, not bin. bin resolves into the VERSIONED Cellar directory that the
  # next `brew upgrade` deletes; opt_bin is the stable symlink Homebrew
  # repoints, and a service naming the other one dies at the upgrade with its
  # complaint going somewhere nobody looks. `hatchward controlplane install`
  # keeps the same path unresolved for exactly this reason.
  #
  # This and an init-installed launchd agent are TWO supervisors for one port.
  # Whichever binds first wins and the other loops on "address already in use";
  # `hatchward controlplane status` reports what is actually running. Pick one —
  # docs/controlplane.md says which to pick when.
  service do
    run [opt_bin/"hatchward", "controlplane", "serve"]
    keep_alive true
    log_path var/"log/hatchward-controlplane.log"
    error_log_path var/"log/hatchward-controlplane.log"
  end

  # Homebrew re-signs a Mach-O ad-hoc if keg relocation rewrites it. That never
  # fires here — a CGO_ENABLED=0 Go binary carries no Cellar paths to rewrite —
  # but if a Developer ID signature is ever added upstream, check that this
  # still holds before trusting the installed binary to be notarized.

  test do
    assert_match "v0.5.1", shell_output("#{bin}/hatchward --version")
  end
end
