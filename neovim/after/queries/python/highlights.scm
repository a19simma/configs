; extends
; WORKAROUND: Fix for nvim-treesitter bug where "except*" is treated as a keyword string
; instead of matching the except_clause node type.
;
; Bug: https://github.com/nvim-treesitter/nvim-treesitter/issues/8440
; The upstream query file incorrectly uses "except*" as a string literal, but Tree-sitter
; doesn't have a keyword called "except*" - it's two tokens (except + *) that form an
; except_clause node.
;
; This file overrides the broken exception keyword matching with proper node-based matching.

; Correct way to match exception handling keywords using node types
(try_statement
  "try" @keyword.exception)

(except_clause
  "except" @keyword.exception)

(raise_statement
  "raise" @keyword.exception)

(try_statement
  (finally_clause
    "finally" @keyword.exception))

(raise_statement
  "from" @keyword.exception)

(try_statement
  (else_clause
    "else" @keyword.exception))
