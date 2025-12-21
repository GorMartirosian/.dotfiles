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
(set-fringe-mode '(5 . 5))  ; Give some breathing room
(menu-bar-mode -1)          ; Disable the menu bar

(setq delete-by-moving-to-trash t)
(cond
 (my/is-macos-system
  (setq trash-directory "~/.Trash"))
 (my/is-windows-system
  (setq trashcan-dirname (expand-file-name "~/Recycle Bin"))))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

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

(add-hook 'prog-mode-hook
          #'(lambda ()
	      (set-face-attribute 'font-lock-comment-face
				  nil
				  :family "DejaVuSansM Nerd Font"
				  :slant 'italic
				  :foreground "cyan4")
	      (set-face-attribute 'font-lock-keyword-face nil :weight 'bold)
	      (set-face-attribute 'font-lock-type-face nil :weight 'bold)
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
  ;; for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 10)))

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
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 1))

(column-number-mode)
(setq-default display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

(use-package org-roam
  :config
  (unless (file-directory-p "~/OrgRoam")
    (make-directory "~/OrgRoam" t))

  (setq org-roam-directory (file-truename "~/OrgRoam"))

  (global-set-key (kbd "C-c n l") #'org-roam-buffer-toggle)
  (global-set-key (kbd "C-c n f") #'org-roam-node-find)
  (global-set-key (kbd "C-c n i") #'org-roam-node-insert)

  (org-roam-db-autosync-mode))

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
  (global-set-key (kbd "C-x b") #'consult-buffer))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :init
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-h x") #'helpful-command))

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

(defun my/set-additional-keybindings ()
  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  
  (define-key evil-normal-state-map (kbd "C-d") #'my/evil-scroll-down-and-center)
  (define-key evil-normal-state-map (kbd "C-u") #'my/evil-scroll-up-and-center)

  (define-key evil-insert-state-map (kbd "C-w") 'evil-window-map)

  (keymap-set evil-insert-state-map "C-g" 'evil-normal-state)
  
  (with-eval-after-load 'vertico

    (defvar my/listed-entries-minibuffer-keymap
      (let ((map (make-sparse-keymap)))
	(define-key map (kbd "C-n") #'next-line-or-history-element)
	(define-key map (kbd "C-p") #'previous-line-or-history-element)
	map))

    (defvar my/one-line-minibuffer-keymap
      (let ((map (make-sparse-keymap)))
	(define-key map (kbd "C-n") #'next-line-or-history-element)
	(define-key map (kbd "C-p") #'previous-line-or-history-element)
	map))

    (defvar my/extended-global-keymap
      (let ((map (make-sparse-keymap)))
	(define-key map (kbd "C-S-f") #'consult-grep)
	(define-key map (kbd "C-f") #'consult-line)
	(define-key map (kbd "C-S-p") #'consult-find)
	map))

    (add-to-list
     'emulation-mode-map-alists
     `((my/is-listed-entries-minibuffer-keymap-enabled . ,my/listed-entries-minibuffer-keymap)))
    (add-to-list
     'emulation-mode-map-alists
     `((my/is-one-line-minibuffer-keymap-enabled . ,my/one-line-minibuffer-keymap)))
    (add-to-list 'emulation-mode-map-alists `((t . ,my/extended-global-keymap)))

    (add-hook 'minibuffer-setup-hook
	      #'(lambda ()
		  (if (eq this-command 'eval-expression)
		      (setq-local my/is-one-line-minibuffer-keymap-enabled t)
		    (setq-local my/is-listed-entries-minibuffer-keymap-enabled t))))))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-minibuffer t)
  :config
  (evil-mode 1)

  (advice-add 'evil-search-next :after
              #'(lambda (&rest x) (evil-scroll-line-to-center (line-number-at-pos))))

  (advice-add 'evil-search-previous :after
              #'(lambda (&rest x) (evil-scroll-line-to-center (line-number-at-pos))))

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
    (corfu-preselect 'first)      ;; Preselect the prompt
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

(use-package ultra-scroll
  :vc (:url "https://github.com/jdtsmith/ultra-scroll"
	    :rev :newest)
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

;; Machine specific: do not forget to install the LSP servers.
(use-package eglot
  :after (clojure-mode)
  :init
  (setopt eglot-autoshutdown t)
  :config
  (dolist (mode-hook '(clojure-mode-hook
		       c-mode-hook
		       c-ts-mode-hook
		       c++-mode-hook
		       python-ts-mode-hook
		       js-ts-mode-hook))
    (add-hook mode-hook #'eglot-ensure)))
