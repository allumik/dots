;; Personal channel: what Guix and nonguix do not ship (D8). Prebuilt
;; upstream binaries only; loaded with -L guix/modules (see README.md).
(define-module (allu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages rust-apps)
  #:use-module (guix base16)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (nonguix build-system binary)
  #:use-module ((nonguix licenses) #:prefix nonfree:))

(define-public claude-code
  (package
    (name "claude-code")
    ;; Bump: version from .../claude-code-releases/latest, sha256 from the
    ;; linux-x64 "checksum" in .../<version>/manifest.json.
    (version "2.1.301")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://downloads.claude.ai/claude-code-releases/"
                           version "/linux-x64/claude"))
       (sha256
        (base16-string->bytevector
         "bc1aad9982c7b59c7d889ff92595d61cf46e0a6eae074cb551d932a989bcd222"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; Stripping drops the Bun payload; the binary then runs plain bun.
      #:strip-binaries? #f
      #:patchelf-plan ''(("claude" ("libc")))
      #:install-plan ''(("claude" "bin/"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'make-executable
            (lambda _ (chmod "claude" #o755)))
          (add-after 'install 'wrap
            (lambda _
              ;; The self-updater and the bundled ripgrep would both fetch
              ;; or unpack binaries that expect /lib64/ld-linux.
              (wrap-program (string-append #$output "/bin/claude")
                '("DISABLE_AUTOUPDATER" = ("1"))
                '("DISABLE_INSTALLATION_CHECKS" = ("1"))
                '("USE_BUILTIN_RIPGREP" = ("0"))
                `("PATH" prefix
                  (,(string-append #$(this-package-input "ripgrep") "/bin"))))))
          ;; A broken Bun binary exits 0 and prints bun's version instead.
          (add-after 'wrap 'smoke-test
            (lambda _
              (setenv "HOME" "/tmp")
              (invoke "sh" "-c"
                      (string-append #$output "/bin/claude --version | grep -F "
                                     #$version)))))))
    (inputs (list bash-minimal ripgrep))
    (supported-systems '("x86_64-linux"))
    (home-page "https://code.claude.com")
    (synopsis "Anthropic's agentic coding CLI")
    (description "Claude Code, installed from the official prebuilt native
binary.")
    (license (nonfree:nonfree "https://code.claude.com/docs/en/legal-and-compliance"))))

(define-public tailscale
  (package
    (name "tailscale")
    (version "1.104.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://pkgs.tailscale.com/stable/tailscale_"
                           version "_amd64.tgz"))
       (sha256
        (base16-string->bytevector
         "108d1d96ecf410d305571e173516f27038f870919a9b89c914a167c6d33a4528"))))
    ;; Static Go binaries: nothing to patch (O4).
    (build-system copy-build-system)
    (arguments
     (list #:install-plan ''(("tailscale" "bin/") ("tailscaled" "bin/"))))
    (supported-systems '("x86_64-linux"))
    (home-page "https://tailscale.com")
    (synopsis "Mesh VPN client and daemon")
    (description "Upstream static Tailscale CLI and @command{tailscaled}.")
    (license license:bsd-3)))

(define-public chicago95
  (package
    (name "chicago95")
    (version "3.0.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/grassmunk/Chicago95/archive"
                           "/refs/tags/v" version ".tar.gz"))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base16-string->bytevector
         "ddf0e35c00899ce0cea752db09f71d1e28ec3caf15e0653838c0d7b3bc5e043a"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan ''(("Icons/Chicago95" "share/icons/"))
      #:phases
      #~(modify-phases %standard-phases
          ;; No Inherits= upstream, so icons it lacks render blank instead
          ;; of falling back (same fix as the NixOS overlay).
          (add-after 'unpack 'add-fallbacks
            (lambda _
              (substitute* "Icons/Chicago95/index.theme"
                (("^Name=Chicago95" all)
                 (string-append all "\nInherits=Papirus-Light,Papirus,hicolor"))))))))
    (home-page "https://github.com/grassmunk/Chicago95")
    (synopsis "Windows 95 icon theme")
    (description "The Chicago95 icon theme.")
    (license license:gpl3+)))
