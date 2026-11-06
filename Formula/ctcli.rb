# Formula for the public tap cathedralai/homebrew-tap:
#   brew install cathedralai/tap/ctcli
# The wheel is pure Python. Offline receipt verify (ctcli receipt verify --bundle)
# needs the cryptography package (ctcli[verify]); the formula installs it next
# to the wheel so brew users get verify without a separate pip step.
# On each release, update url and sha256 to the new wheel and its .sha256.
class Ctcli < Formula
  desc "Command-line client for Cathedral sandboxes, Boxes and Workers"
  homepage "https://cathedral.computer"
  url "https://cathedral.computer/ctcli/ctcli-0.5.19-py3-none-any.whl"
  sha256 "d83f724920d2e071cfc74dfd9f4165013a38171edae1171d5907e5052d180595"

  depends_on "python@3.13"

  def install
    python = formula_opt_bin("python@3.13")/"python3.13"
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
    # verify extra is present: the module imports when cryptography is on PYTHONPATH
    system formula_opt_bin("python@3.13")/"python3.13", "-c",
           "import sys; sys.path.insert(0, '#{libexec}'); import cryptography; import ctcli"
  end
end
