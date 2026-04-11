;;; -*- lexical-binding: t; -*-

(setq custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

;; Add this line, if init.el is separated into different files
;;(add-to-list 'load-path '"~/.emacs.d/modules")

(setopt auto-save-interval 20)
(setopt auto-save-visited-mode t)
(setopt auto-save-visited-interval 2) 

(fset 'yes-or-no-p 'y-or-n-p)

(defvar my/is-linux-system (eq system-type 'gnu/linux))
(defvar my/is-windows-system (eq system-type 'windows-nt))
(defvar my/is-macos-system (eq system-type 'darwin))

(when my/is-windows-system
  (setq find-program "C:/cygwin64/bin/find.exe"))

(setq inhibit-startup-message t)

(setq initial-frame-alist
      '((fullscreen . maximized)
	(undecorated . t)))

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode '(5 . 12)) ; Give some breathing room
(menu-bar-mode -1)          ; Disable the menu bar

(setq search-nonincremental-instead nil)

(defvar-local my/last-searched-string nil)

(defvar-local my/evil-last-search-candidate-overlay nil)

(defun my/unhighlight-last-searched-string ()
  (interactive)
  (unhighlight-regexp my/last-searched-string)
  (when (overlayp my/evil-last-search-candidate-overlay)
    (delete-overlay my/evil-last-search-candidate-overlay)))

(defface my/search-hl-face
  '((t :inherit lazy-highlight))
  "Face for my persistent search highlight.")

(defun my/highlight-new-search ()
  (let ((last-searched-string (car evil-ex-search-history)))
    (highlight-regexp last-searched-string 'my/search-hl-face)
    (when (looking-at last-searched-string)
      (let ((last-searched-string-size
	     (length (my/evil-strip-boundaries last-searched-string))))
	(setq my/evil-last-search-candidate-overlay
	      (make-overlay (point) (+ (point) last-searched-string-size)))
	(overlay-put my/evil-last-search-candidate-overlay 'face 'isearch)))
    (setq my/last-searched-string last-searched-string)))

(advice-add
 'evil-ex-start-search
 :after
 #'(lambda (&rest _args)
     (my/unhighlight-last-searched-string)
     (my/highlight-new-search)))

(advice-add
 'evil-ex-search-next
 :after
 #'(lambda (&rest _args)
     (my/unhighlight-last-searched-string)
     (my/highlight-new-search)))

(advice-add
 'evil-ex-search-previous
 :after
 #'(lambda (&rest _args)
     (my/unhighlight-last-searched-string)
     (my/highlight-new-search)))

(advice-add
 'evil-ex-start-word-search
 :after
 #'(lambda (&rest _args)
     (my/unhighlight-last-searched-string)
     (my/highlight-new-search)))

(setq delete-by-moving-to-trash t)
(cond
 (my/is-macos-system
  (setq trash-directory "~/.Trash"))
 (my/is-windows-system
  (setq trashcan-dirname (expand-file-name "~/Recycle Bin"))))

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
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

;; Font
;; Change needed on new machine. Install the necessary fonts.
(set-face-attribute 'default nil
		    :family "AdwaitaMono Nerd Font"
		    :height 120
		    :weight 'medium)

(setq show-paren-delay 0) 

(add-hook 'prog-mode-hook
          #'(lambda ()
	      (set-face-attribute 'font-lock-comment-face
				  nil
				  :family "DejaVuSansM Nerd Font"
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

(add-hook 'help-mode-hook
          #'(lambda ()
	      (face-remap-add-relative 'default
				       :family "AdwaitaMono Nerd Font"
				       :weight 'bold)))

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

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 10))
  :config
  (setq doom-modeline-buffer-file-name-style 'truncate-nil))

(use-package anzu
  :config
  (global-anzu-mode 1))

(use-package evil-anzu
  :after (evil anzu))

;;Change Emacs backup file location
(setq backup-directory-alist
      `(("." . ,(concat user-emacs-directory "backups"))))

;;Change Emacs auto-save file location
(setq auto-save-list-file-prefix "~/.emacs.d/autosave/")

(setq auto-save-file-name-transforms
      '((".*" "~/.emacs.d/autosave/" t)))

(use-package vlf
  :config
  (require 'vlf-setup)
  (setopt vlf-application 'dont-ask))

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
  (vertico-count 10)    ; Display at most this many matches
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

(use-package marginalia
  :custom
  (marginalia-mode 1))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package consult
  :after recentf
  :custom
  (consult-mode 1)
  :config
  (keymap-global-set "C-x b" #'consult-buffer))

(use-package embark
  :after vertico
  :config
  (keymap-global-set "C-;" #'embark-act)
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

	    (keymap-set evil-normal-state-local-map "d" #'my/hide-line)))

(use-package embark-consult
  :after (embark consult))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :init
  (keymap-global-set "C-h f" #'helpful-callable)
  (keymap-global-set "C-h v" #'helpful-variable)
  (keymap-global-set "C-h k" #'helpful-key)
  (keymap-global-set "C-h x" #'helpful-command))

(defun my/evil-scroll-down-and-center ()
  "Scroll down and center the cursor."
  (interactive)
  (evil-scroll-down nil)
  (recenter))

(defun my/evil-scroll-up-and-center ()
  "Scroll up and center the cursor."
  (interactive)
  (evil-scroll-up nil)
  (recenter))

(defun my/keyboard-escape-quit-and-unhighlight ()
  (interactive)
  (my/unhighlight-last-searched-string)
  (anzu--reset-mode-line)
  (keyboard-escape-quit))

(defun my/keyboard-quit-and-unhighlight ()
  (interactive)
  (my/unhighlight-last-searched-string)
  (anzu--reset-mode-line)
  (keyboard-quit))

(add-hook 'occur-mode-hook
	  #'(lambda ()
	      (keymap-set evil-normal-state-local-map "d" #'my/hide-line)))

(defun my/evil-strip-boundaries (s)
  "Remove Emacs symbol-boundary tokens \\_< and \\_> from S."
  (when (stringp s)
    (setq s (string-replace "\\_<" "" s))
    (setq s (string-replace "\\_>" "" s))
    s))

(defun my/isearch-occur-and-jump-to-window ()
  (interactive)
  (let* ((raw (car evil-ex-search-history))
         (pattern (my/evil-strip-boundaries raw)))
    (unless (and pattern (not (string-empty-p pattern)))
      (user-error "No Evil search pattern in evil-ex-search-history"))
    (isearch-occur pattern)
    (other-window 1)))

(defun my/isearch-occur-and-jump-to-window-from-evil-search ()
  (interactive)
  (let* ((raw (minibuffer-contents-no-properties))
         (pattern (my/evil-strip-boundaries raw)))
    (unless (and pattern (not (string-empty-p pattern)))
      (user-error "No Evil search pattern"))
    (run-at-time
     0 nil
     (lambda ()
       (isearch-occur pattern)
       (other-window 1)))
    (exit-minibuffer)))

(defun my/setup-minibuffer-keys ()
  (cond
   ((memq this-command '(consult-ripgrep consult-find consult-line))
    (keymap-set evil-normal-state-local-map "C-n" #'next-history-element)
    (keymap-set evil-normal-state-local-map "C-p" #'previous-history-element)
    (keymap-set evil-insert-state-local-map "C-n" #'vertico-next)
    (keymap-set evil-insert-state-local-map "C-p" #'vertico-previous)
    (keymap-set evil-insert-state-local-map "C-." #'embark-export)
    (keymap-set evil-normal-state-local-map "C-." #'embark-export))

   ((eq this-command 'eval-expression)
    (keymap-set evil-normal-state-local-map "C-n" #'next-line-or-history-element)
    (keymap-set evil-normal-state-local-map "C-p" #'previous-line-or-history-element)
    (keymap-set evil-insert-state-local-map "C-n" #'corfu-next)
    (keymap-set evil-insert-state-local-map "C-p" #'corfu-previous))

   (t
    (when (eq this-command 'evil-ex-search-forward)
      (keymap-set evil-normal-state-local-map "C-." #'my/isearch-occur-and-jump-to-window-from-evil-search)
      (keymap-set evil-insert-state-local-map "C-." #'my/isearch-occur-and-jump-to-window-from-evil-search))
    (keymap-set evil-normal-state-local-map "C-n" #'next-line-or-history-element)
    (keymap-set evil-normal-state-local-map "C-p" #'previous-line-or-history-element)
    (keymap-set evil-insert-state-local-map "C-n" #'next-line-or-history-element)
    (keymap-set evil-insert-state-local-map "C-p" #'previous-line-or-history-element))))

(defun my/unset-minibuffer-keys (&rest _)
  (keymap-unset evil-insert-state-local-map "C-." t)
  (keymap-unset evil-normal-state-local-map "C-." t)
  (keymap-unset evil-insert-state-local-map "C-p" t)
  (keymap-unset evil-normal-state-local-map "C-p" t)
  (keymap-unset evil-insert-state-local-map "C-n" t)
  (keymap-unset evil-normal-state-local-map "C-n" t))

(defun my/set-additional-keybindings ()
  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (keymap-global-set "<escape>" #'keyboard-escape-quit)
  (keymap-global-set "<mouse-3>" #'context-menu-open)

  (keymap-set evil-normal-state-map "<escape>" #'my/keyboard-escape-quit-and-unhighlight)

  (keymap-global-set "C-g" #'my/keyboard-quit-and-unhighlight)

  (keymap-set evil-normal-state-map "C-d" #'my/evil-scroll-down-and-center)
  (keymap-set evil-normal-state-map "C-u" #'my/evil-scroll-up-and-center)

  (keymap-set evil-insert-state-map "C-w" evil-window-map)

  (keymap-set evil-insert-state-map "C-g" #'evil-normal-state)

  (keymap-set evil-normal-state-map "C-." #'my/isearch-occur-and-jump-to-window)

  (with-eval-after-load 'consult

    (defvar my/extended-global-keymap
      (let ((map (make-sparse-keymap)))
	(keymap-set map "C-S-f" #'consult-ripgrep)
	(keymap-set map "C-f" #'consult-line)
	(keymap-set map "C-S-p" #'consult-find)
	map))

    (add-to-list 'emulation-mode-map-alists `((t . ,my/extended-global-keymap))))

  (with-eval-after-load 'vertico
    (add-hook 'minibuffer-setup-hook #'my/setup-minibuffer-keys))

  (advice-add 'abort-minibuffers :before #'my/unset-minibuffer-keys))

(use-package evil
  :init
  (setq evil-search-module 'evil-search)
  (setq evil-ex-search-persistent-highlight nil)
  (setq evil-ex-search-highlight-all nil)
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-minibuffer t)
  (setq evil-regexp-search t)
  (setq evil-symbol-word-search t)
  :config
  (evil-mode 1)

  (advice-add 'evil-search-next
	      :after
	      #'(lambda (&rest x)
		  (evil-scroll-line-to-center (line-number-at-pos))))

  (advice-add 'evil-search-previous
	      :after
	      #'(lambda (&rest x)
		  (evil-scroll-line-to-center (line-number-at-pos))))

  (my/set-additional-keybindings))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package project)

(use-package magit
  :config
  (setq ediff-split-window-function 'split-window-horizontally)
  (setq ediff-window-setup-function 'ediff-setup-windows-plain))

(use-package diff-hl
  :config
  (global-diff-hl-mode))

(defun my/disable-auto-save ()
  (setq-local auto-save-visited-mode nil))

(add-hook 'makefile-mode-hook #'my/disable-auto-save)
(add-hook 'vlf-mode-hook #'my/disable-auto-save)

(defun my/disable-auto-save-on-tramp ()
  (when (file-remote-p default-directory)
    (my/disable-auto-save)))

(add-hook 'find-file-hook #'my/disable-auto-save-on-tramp)

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

(use-package evil-nerd-commenter
  :bind ("C-/" . evilnc-comment-or-uncomment-lines))

(defun my/set-sly-repl-mode-keybindings ()
  (evil-define-key 'normal sly-mrepl-mode-map
    (kbd "C-n") 'sly-mrepl-next-input-or-button
    (kbd "C-p") 'sly-mrepl-previous-input-or-button)
  (evil-define-key 'insert sly-mrepl-mode-map
    (kbd "C-n") 'sly-mrepl-next-input-or-button
    (kbd "C-p") 'sly-mrepl-previous-input-or-button))

(use-package sly
  :commands (sly sly-connect)
  :init
  (setq inferior-lisp-program "sbcl")
  :config
  (my/set-sly-repl-mode-keybindings))

(setq-default truncate-lines t)
(setq truncate-partial-width-windows nil)
(setq auto-hscroll-mode t)
(setq mouse-wheel-tilt-scroll t)
(setq mouse-wheel-progressive-speed nil)
;; OS specific
(setq mouse-wheel-flip-direction nil)

(setq hscroll-step 7)
(setq hscroll-margin 3)

(use-package ultra-scroll
  :init
  (setq scroll-conservatively 101 ; important!
        scroll-margin 0)
  :config
  (ultra-scroll-mode 1))

(use-package dashboard
  :init
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t)
  (setq dashboard-vertically-center-content t)
  (setq dashboard-startupify-list (list #'dashboard-insert-banner
					#'dashboard-insert-newline
					#'dashboard-insert-banner-title
					#'dashboard-insert-newline
					#'dashboard-insert-init-info
					#'dashboard-insert-items
					#'dashboard-insert-newline))

  :config
  (dashboard-setup-startup-hook))

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
  (apheleia-global-mode +1)
  (setf (alist-get 'prettier-javascript apheleia-formatters)
	'("apheleia-npx" "prettier" "--stdin-filepath" filepath))
  (setf (alist-get 'prettier-html apheleia-formatters)
	'("apheleia-npx" "prettier" "--stdin-filepath" filepath)))

(use-package treemacs
  :config
  (treemacs-git-mode 'deferred)
  (treemacs-indent-guide-mode t)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always))

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package treemacs-nerd-icons
  :config
  (treemacs-load-theme "nerd-icons"))
