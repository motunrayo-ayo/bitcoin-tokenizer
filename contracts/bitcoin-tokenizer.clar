;; Bitcoin Tokenizer Contract

;; This smart contract implements a wrapped Bitcoin token (wBTC) on the Stacks blockchain. 
;; Users can deposit BTC to mint wBTC, withdraw BTC by burning wBTC, and transfer wBTC between accounts.
;; The contract includes functionality for fee management, operator approval, and emergency shutdown.


;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-TRANSFER-FAILED (err u103))
(define-constant ERR-ALREADY-INITIALIZED (err u104))
(define-constant ERR-NOT-INITIALIZED (err u105))
(define-constant ERR-INVALID-RECIPIENT (err u106))
(define-constant MIN-DEPOSIT-AMOUNT u100) ;; Minimum deposit in sats
(define-constant MAX-DEPOSIT-AMOUNT u1000000000) ;; Maximum deposit in sats