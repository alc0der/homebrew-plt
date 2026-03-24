class Plt < Formula
  desc "Self-hosted LanguageTool in an Apple container with no internet access"
  homepage "https://github.com/alc0der/languagetool"
  url "https://github.com/alc0der/languagetool/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "c9135aef20c3708e7addb6cb7560caa5afa4e43ed010f0bd2e00c00f8714c3ec"
  license "MIT"
  head "https://github.com/alc0der/languagetool.git", branch: "main"

  depends_on :macos

  def install
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

      First-time setup (optional):
        plt download-ngrams  # ~1.6 GB, enables extra grammar checks

      Start the service:
        brew services start plt

      LanguageTool will be available at http://localhost:8010
    EOS
  end
end
