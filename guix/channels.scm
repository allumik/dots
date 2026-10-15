;; Channel inputs, unpinned. The pin lives in channels-lock.scm:
;;   guix pull -C guix/channels.scm
;;   guix describe -f channels > guix/channels-lock.scm
;; The personal channel (allu ...) is not listed here; it is loaded from this
;; checkout with -L guix/ (see README.md) so edits apply without a commit.
(cons* (channel
        (name 'nonguix)
        (url "https://gitlab.com/nonguix/nonguix")
        ;; Kernel, firmware, microcode, steam (D2, D5).
        (introduction
         (make-channel-introduction
          "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
          (openpgp-fingerprint
           "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
       %default-channels)
