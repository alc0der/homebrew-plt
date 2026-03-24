class Plt < Formula
  desc "Self-hosted LanguageTool in an Apple container with no internet access"
  homepage "https://github.com/alc0der/languagetool"
  url "https://github.com/alc0der/languagetool/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "173226fe18e46a2081ff12187da6183e0c949b58488f1fa40fe413b80ea0de03"
  license "MIT"
  head "https://github.com/alc0der/languagetool.git", branch: "main"

  depends_on :macos

  def install
    libexec.install "Containerfile"
    libexec.install "en_spelling_additions.txt"
    libexec.install "container-run.sh"
    (libexec/"scripts").install Dir["scripts/*"]
    libexec.install "bin/plt" => "plt-exec"

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
      Requires Apple's container CLI (/usr/local/bin/container).

      First-time setup:
        plt build
        plt download-ngrams  # optional, ~1.6 GB

      Start the service:
        brew services start plt

      LanguageTool will be available at http://localhost:8010
    EOS
  end
end
