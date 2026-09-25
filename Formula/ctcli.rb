# Formula for the public tap cathedralai/homebrew-tap:
#   brew install cathedralai/tap/ctcli
# ctcli is pure Python with no dependencies, so this extracts the served wheel
# and runs the package with Homebrew's Python; nothing is built or fetched. The
# wheel is byte-for-byte reproducible, so its SHA-256 is stable per release.
# On each release, update url and sha256 to the new wheel and its .sha256.
class Ctcli < Formula
  desc "Command-line client for Cathedral sandboxes, Boxes and Workers"
  homepage "https://cathedral.computer"
  url "https://cathedral.computer/ctcli/cathedral_cli-0.5.16-py3-none-any.whl"
  sha256 "d5312947dc28ea14574aaaa1c0466f7e3750a7299d6820c56035ac3b7b2fd56a"

  depends_on "python@3.13"

  def install
    python = formula_opt_bin("python@3.13")/"python3.13"
    # Homebrew keeps a .whl as one file; a wheel is a zip of the package.
    system python, "-m", "zipfile", "-e", "cathedral_cli-#{version}-py3-none-any.whl", libexec
    (bin/"ctcli").write_env_script python, "-m ctcli", PYTHONPATH: libexec
  end

  test do
    assert_match "ctcli #{version}", shell_output("#{bin}/ctcli --version")
    output = shell_output("#{bin}/ctcli --json sandbox catalog", 1)
    assert_match "auth_required", output
  end
end
