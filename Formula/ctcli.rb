# Formula for the public tap cathedralai/homebrew-tap:
#   brew install cathedralai/tap/ctcli
# The wheel is pure Python. Offline receipt verify needs cryptography; brew's
# cryptography bottle does not build for 3.13, so this formula uses python@3.14
# and installs cryptography into libexec next to the wheel (AB#557).
# On each release, update url and sha256 to the new wheel and its .sha256.
class Ctcli < Formula
  desc "Command-line client for Cathedral sandboxes, Boxes and Workers"
  homepage "https://cathedral.computer"
  url "https://cathedral.computer/ctcli/ctcli-0.5.19-py3-none-any.whl"
  sha256 "d83f724920d2e071cfc74dfd9f4165013a38171edae1171d5907e5052d180595"

  depends_on "python@3.14"

  def install
    python = formula_opt_bin("python@3.14")/"python3.14"
    # Homebrew keeps a .whl as one file; a wheel is a zip of the package.
    system python, "-m", "zipfile", "-e", "ctcli-#{version}-py3-none-any.whl", libexec
    # AB#557: cryptography for the shipped room-kit verify_receipts module.
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
