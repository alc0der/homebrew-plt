class Plt < Formula
  desc "Self-hosted LanguageTool in an Apple container with no internet access"
  homepage "https://github.com/alc0der/languagetool"
  url "https://github.com/alc0der/languagetool/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "6d64b0b1ee9a7109f8f5a1a8dc18c738ca7f5bdafd9e8f337981cf19f2cfeefc"
  license "MIT"
  head "https://github.com/alc0der/languagetool.git", branch: "main"

  depends_on :macos

  def install
    libexec.install "container-run.sh"
    (libexec/"scripts").install "scripts/download-ngrams.sh"
    libexec.install "bin/plt" => "plt-exec"
    chmod 0755, libexec/"container-run.sh"
    chmod 0755, libexec/"plt-exec"
    (libexec/"scripts").children.each { |f| chmod 0755, f }

    (bin/"plt").write <<~BASH
      #!/bin/bash
      export PLT_LIBEXEC="#{libexec}"
      export PLT_DATA="#{var}/plt"
      exec "#{libexec}/plt-exec" "$@"
    BASH
  end

  def post_install
    (var/"plt/ngrams").mkpath
  end

  service do
    run [opt_bin/"plt", "run"]
    keep_alive false
    log_path var/"log/plt.log"
    error_log_path var/"log/plt.err"
  end

  def caveats
    <<~EOS
      Requires Apple's container CLI (brew install container).

      First-time setup (optional):
        plt download-ngrams  # ~1.6 GB, enables extra grammar checks

      Start the service:
        brew services start plt

      LanguageTool will be available at http://localhost:8010

      Before uninstalling, remove the container:
        plt uninstall
    EOS
  end
end
