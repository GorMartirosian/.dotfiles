;;; -*- lexical-binding: t; -*-

(setopt custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

(add-hook 'emacs-startup-hook
          #'(lambda ()
              (setopt gc-cons-threshold (* 32 1024 1024))
              (message "Emacs loaded in %.2f seconds with %d garbage collections."
                       (float-time
			(time-subtract after-init-time before-init-time))
                       gcs-done)))

(setopt inhibit-startup-screen t)

(setopt initial-frame-alist
	'((fullscreen . maximized)
	  (undecorated . t)))

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(menu-bar-mode -1)          ; Disable the menu bar

(setopt delete-by-moving-to-trash t)

;; Initialize package sources
(require 'package)

(setopt package-archives '(("melpa" . "https://melpa.org/packages/")
                           ("org" . "https://orgmode.org/elpa/")
                           ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(setopt use-package-always-ensure t)

(use-package emacs
  :custom
  (enable-recursive-minibuffers t)

  (tab-always-indent 'complete)
  (completion-cycle-threshold 3)

  ;; Only useful commands for current buffer are shown in M-x
  (read-extended-command-predicate #'command-completion-default-include-p)
  :init
  (minibuffer-depth-indicate-mode 1))

(delete-selection-mode 1)
(global-auto-revert-mode 1)

(add-hook 'prog-mode-hook #'hs-minor-mode)

;;Theme
;; Install icons using nerd-icons-install-fonts
(use-package doom-themes
  :config
  (setopt doom-themes-enable-bold t    ; if nil, bold is universally disabled
          doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-molokai t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; Font
;; Change needed on new machine. Install the necessary fonts.
(set-face-attribute 'default nil
		    :family "JetBrains Mono"
		    :height 120
		    :weight 'regular)

(setopt show-paren-delay 0)

(set-face-attribute 'font-lock-comment-face nil
                    :slant 'italic
                    :foreground "cyan4")

(set-face-attribute 'font-lock-keyword-face nil :weight 'bold)

(set-face-attribute 'font-lock-type-face nil :weight 'bold)

(let ((fg (face-foreground 'default nil 'default)))
  (set-face-attribute 'show-paren-match nil
		      :box `(:line-width (-1 . -1) :color ,fg)))

(set-face-attribute 'show-paren-mismatch nil
                    :box '(:line-width (-1 . -1) :color "red"))

(set-face-attribute 'completions-annotations nil
                    :foreground "#b0b0b0")

(defun my/add-todo-font-lock ()
  (font-lock-add-keywords
   nil
   '(("\\<TODO"
      0 'font-lock-warning-face prepend))))

(add-hook 'prog-mode-hook #'my/add-todo-font-lock)

(setopt isearch-lazy-count t)
(setopt lazy-highlight-buffer t)
(setopt lazy-highlight-cleanup nil)

;;Change Emacs backup file location
(setopt backup-directory-alist
	`(("." . ,(concat user-emacs-directory "backups"))))

;;Change Emacs auto-save file location
(setopt auto-save-list-file-prefix "~/.emacs.d/autosave/")

(setopt auto-save-file-name-transforms
	'((".*" "~/.emacs.d/autosave/" t)))

(use-package which-key
  :diminish which-key-mode
  :config
  (which-key-mode 1))

(column-number-mode)
(setq-default display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

(use-package vertico
  :custom
  (vertico-count 10)
  :init
  (vertico-mode))

(use-package savehist
  :init
  (savehist-mode))

(use-package recentf
  :init
  (recentf-mode 1))

(use-package orderless
  :config
  (setopt read-file-name-completion-ignore-case t
	  read-buffer-completion-ignore-case t)
  (setq completion-ignore-case t)
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult
  :after recentf
  :config
  (keymap-global-set "C-x b" #'consult-buffer)
  (keymap-global-set "M-s d" #'consult-find)
  (keymap-global-set "M-s g" #'consult-ripgrep)
  (keymap-global-set "M-s l" #'consult-line)
  (setopt consult-ripgrep-args
          (concat consult-ripgrep-args " --fixed-strings"))
  (setopt xref-show-xrefs-function #'consult-xref
	  xref-show-definitions-function #'consult-xref))

(use-package embark
  :after vertico
  :config
  (setq grep-use-headings t)
  (keymap-set vertico-map "C-." #'embark-export))

(defun my/grep-hide-line ()
  (interactive)
  (let ((inhibit-read-only t))
    (kill-whole-line)
    (delete-blank-lines)))

(with-eval-after-load 'grep
  (set-face-attribute 'grep-heading nil
                      :foreground "#b8b8b8"
                      :background "#2f2f2f"
                      :height 1.1
                      :weight 'bold)

  (keymap-set grep-mode-map "C-k" #'my/grep-hide-line)

  (add-hook 'grep-mode-hook
            (lambda ()
              (face-remap-add-relative 'default :height 0.9))))

(use-package embark-consult
  :after (embark consult))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :init
  (keymap-global-set "C-h f" #'helpful-callable)
  (keymap-global-set "C-h v" #'helpful-variable)
  (keymap-global-set "C-h k" #'helpful-key)
  (keymap-global-set "C-h x" #'helpful-command))

(add-hook 'occur-mode-hook
	  #'(lambda ()
	      (keymap-set occur-mode-map "C-k" #'my/grep-hide-line)))

(keymap-global-set "<escape>" #'keyboard-escape-quit)
(keymap-global-set "<mouse-3>" #'context-menu-open)

(use-package magit
  :config
  (setq ediff-split-window-function 'split-window-horizontally)
  (setq ediff-window-setup-function 'ediff-setup-windows-plain))

(use-package diff-hl
  :config
  (global-diff-hl-mode))

(use-package corfu
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-preselect 'prompt)      ;; Preselect the prompt
  (corfu-auto t)
  (corfu-quit-no-match 'separator)
  (corfu-preview-current nil)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0)
  ;; initial time to show docs, time between scrolls to show docs
  (corfu-popupinfo-delay '(0.5 . 0.2))
  :config
  (global-corfu-mode 1)
  (corfu-history-mode 1)
  (corfu-popupinfo-mode 1))

(use-package slime
  :commands (slime slime-connect)
  :init
  (setq inferior-lisp-program "sbcl"))

(setopt scroll-margin 4)
(setopt scroll-conservatively 101)
(setopt scroll-preserve-screen-position t)

(setq-default truncate-lines t)
(setopt truncate-partial-width-windows nil)
(setopt auto-hscroll-mode t)
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-progressive-speed nil)
;; OS specific
(setopt mouse-wheel-flip-direction nil)

(setopt hscroll-step 7)
(setopt hscroll-margin 3)

(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(setopt dired-kill-when-opening-new-dired-buffer t)
(setopt dired-free-space nil)

(use-package nerd-icons-dired
  :config
  (add-hook 'dired-mode-hook #'nerd-icons-dired-mode))

;; Install grammars using treesit-auto-install-all
(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (global-treesit-auto-mode)
  (treesit-auto-add-to-auto-mode-alist)
  (setopt treesit-font-lock-level 4))

(setopt c-ts-mode-indent-offset 4)

(use-package rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

;; Machine specific: do not forget to install the LSP servers.
(use-package eglot
  :init
  (setopt eglot-autoshutdown t)
  :config
  (dolist (mode-hook '(c-ts-mode-hook
		       c++-ts-mode-hook
		       python-ts-mode-hook
		       js-ts-mode-hook
                       typescript-ts-base-mode-hook
		       css-ts-mode-hook
		       html-ts-mode-hook
		       json-ts-mode-hook))
    (add-hook mode-hook #'eglot-ensure)))

(use-package apheleia
  :config
  (apheleia-global-mode +1))

(use-package markdown-mode
  :mode "\\.md\\'")

(use-package csv-mode)

(use-package yaml-ts-mode
  :mode ("\\.ya?ml\\'" . yaml-ts-mode))

(defun my/recenter (&rest _)
  (recenter))

(with-eval-after-load 'xref
  ;; (advice-add #'xref-find-definitions :after #'my/recenter)
  (advice-add #'xref-go-back :after #'my/recenter))

(with-eval-after-load 'isearch
  (advice-add #'isearch-repeat-forward :after #'my/recenter))

(use-package indent-bars
  :config
  (setopt
   indent-bars-color '(highlight :face-bg t :blend 0.2)
   indent-bars-pattern "."
   indent-bars-width-frac 0.1
   indent-bars-pad-frac 0.1
   indent-bars-zigzag nil
   indent-bars-highlight-current-depth nil)
  (dolist (mode-hook '(c-ts-mode-hook
                       c++-ts-mode-hook
                       python-ts-mode-hook
                       js-ts-mode-hook
                       typescript-ts-base-mode-hook
                       css-ts-mode-hook
                       html-ts-mode-hook
                       json-ts-mode-hook
                       yaml-ts-mode-hook))
    (add-hook mode-hook #'indent-bars-mode)))
