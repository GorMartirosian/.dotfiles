;;; -*- lexical-binding: t; -*-

(setq custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

(fset 'yes-or-no-p 'y-or-n-p)

(setq inhibit-startup-message t)

(setq initial-frame-alist
      '((fullscreen . maximized)
	(undecorated . t)))

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode '(5 . 12)) ; Give some breathing room
(menu-bar-mode -1)          ; Disable the menu bar

(setq delete-by-moving-to-trash t)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(setq use-package-always-ensure t)

(use-package emacs
  :custom
  (enable-recursive-minibuffers t)
  (minibuffer-depth-indicate-mode 1)

  (tab-always-indent 'complete)
  (completion-cycle-threshold 3)

  ;; Only useful commands for current buffer are shown in M-x
  (read-extended-command-predicate #'command-completion-default-include-p))

(setq lazy-highlight-cleanup nil)

;; Font
;; Change needed on new machine. Install the necessary fonts.
(set-face-attribute 'default nil
		    :family "JetBrains Mono"
		    :height 120
		    :weight 'regular)

(setq show-paren-delay 0) 

(add-hook 'prog-mode-hook
          #'(lambda ()
	      (set-face-attribute 'font-lock-comment-face
				  nil
				  :slant 'italic
				  :foreground "cyan4")
	      (set-face-attribute 'font-lock-keyword-face nil :weight 'bold)
	      (set-face-attribute 'font-lock-type-face nil :weight 'bold)
	      (let ((fg (face-foreground 'default nil 'default)))
		(set-face-attribute 'show-paren-match nil
				    :box `(:line-width (-1 . -1) :color ,fg)))
	      (set-face-attribute 'show-paren-mismatch nil
				  :box '(:line-width (-1 . -1) :color "red"))
	      (hs-minor-mode 1)))

;;Theme
;; Install icons using nerd-icons-install-fonts
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-molokai t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(setq isearch-lazy-count t)

;;Change Emacs backup file location
(setq backup-directory-alist
      `(("." . ,(concat user-emacs-directory "backups"))))

;;Change Emacs auto-save file location
(setq auto-save-list-file-prefix "~/.emacs.d/autosave/")

(setq auto-save-file-name-transforms
      '((".*" "~/.emacs.d/autosave/" t)))

(use-package which-key
  :diminish which-key-mode
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 1))

(column-number-mode)
(setq-default display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

(use-package vertico
  :custom
  (vertico-count 10)
  (vertico-mode 1))

(use-package savehist
  :init
  (savehist-mode))

(use-package recentf
  :init
  (recentf-mode 1))

(use-package orderless
  :config
  (setq read-file-name-completion-ignore-case t
	read-buffer-completion-ignore-case t
	completion-ignore-case t)
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult
  :after recentf
  :custom
  (consult-mode 1)
  :config
  (keymap-global-set "C-x b" #'consult-buffer)
  (keymap-global-set "M-s d" #'consult-find)
  (keymap-global-set "M-s c" #'consult-locate)
  (keymap-global-set "M-s g" #'consult-ripgrep)
  (keymap-global-set "M-s l" #'consult-line))

(use-package embark
  :after vertico
  :config
  (setq grep-use-headings t)
  (keymap-set vertico-map "C-." #'embark-export))

(defun my/hide-line ()
  (interactive)
  (let ((inhibit-read-only t))
    (kill-whole-line)
    (delete-blank-lines)))

(add-hook 'grep-mode-hook
          (lambda ()
            (face-remap-add-relative 'default :height 0.9)
            (face-remap-add-relative 'grep-heading :height 1.1 :weight 'bold)

	    (keymap-set grep-mode-map "C-k" #'my/hide-line)))

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
	      (keymap-set occur-mode-map "C-k" #'my/hide-line)))

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

(use-package sly
  :commands (sly sly-connect)
  :init
  (setq inferior-lisp-program "sbcl"))

(setq scroll-margin 4)
(setq scroll-conservatively 101)
(setq scroll-preserve-screen-position t)

(setq-default truncate-lines t)
(setq truncate-partial-width-windows nil)
(setq auto-hscroll-mode t)
(setq mouse-wheel-tilt-scroll t)
(setq mouse-wheel-progressive-speed nil)
;; OS specific
(setq mouse-wheel-flip-direction nil)

(setq hscroll-step 7)
(setq hscroll-margin 3)

(use-package nerd-icons-dired
  :hook
  (dired-mode . nerd-icons-dired-mode))

;; Install grammars using treesit-auto-install-all
(use-package treesit-auto
  :config
  (global-treesit-auto-mode))

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
		       css-ts-mode-hook
		       html-ts-mode-hook
		       json-ts-mode-hook))
    (add-hook mode-hook #'eglot-ensure)))

(use-package apheleia
  :config
  (apheleia-global-mode +1))

(add-hook 'emacs-startup-hook
          #'(lambda ()
              (setq gc-cons-threshold (* 32 1024 1024))
              (message "Emacs loaded in %.2f seconds with %d garbage collections."
                       (float-time
			(time-subtract after-init-time before-init-time))
                       gcs-done)))
