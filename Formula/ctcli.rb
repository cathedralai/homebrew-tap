# Formula for the public tap cathedralai/homebrew-tap:
#   brew install cathedralai/tap/ctcli
# The wheel is pure Python. It needs cryptography: since 0.6.0 commands and
# files are sealed to the attested guest by default (AB#800), and offline
# receipt verify uses it too. brew's cryptography bottle does not build for
# 3.13, so this formula uses python@3.14 and installs cryptography into
# libexec next to the wheel (AB#557).
# On each release, update url and sha256 to the new wheel and its .sha256.
class Ctcli < Formula
  desc "Command-line client for Cathedral sandboxes, Boxes and Workers"
  homepage "https://cathedral.computer"
  url "https://cathedral.computer/ctcli/ctcli-0.6.1-py3-none-any.whl"
  sha256 "6b28e24a9b4a965976a4f1287ceac02e17f7c0be5521a6a278c332e0d3bf7b54"

  depends_on "python@3.14"

  def install
    python = formula_opt_bin("python@3.14")/"python3.14"
    # Homebrew keeps a .whl as one file; a wheel is a zip of the package.
    system python, "-m", "zipfile", "-e", "ctcli-#{version}-py3-none-any.whl", libexec
    # cryptography from PyPI: sealed exec and files (AB#800) and receipt verify (AB#557).
    system python, "-m", "pip", "install", "--upgrade", "-t", libexec, "cryptography>=42"
    (bin/"ctcli").write_env_script python, "-m ctcli", PYTHONPATH: libexec
  end

  test do
    assert_match "ctcli #{version}", shell_output("#{bin}/ctcli --version")
    output = shell_output("#{bin}/ctcli --json sandbox catalog", 1)
    assert_match "auth_required", output
    system formula_opt_bin("python@3.14")/"python3.14", "-c",
           "import sys; sys.path.insert(0, '#{libexec}'); import cryptography; import ctcli"
  end
end
