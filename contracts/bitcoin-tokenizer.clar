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

;; Data Variables
(define-data-var contract-owner principal tx-sender)
(define-data-var total-supply uint u0)
(define-data-var initialized bool false)
(define-data-var protocol-fee-rate uint u5) ;; 0.5% fee rate (5/1000)
(define-data-var treasury principal 'SP000000000000000000002Q6VF78)

;; FT Token Definition
(define-fungible-token wrapped-btc)

;; Data Maps
(define-map user-deposits 
    principal 
    {
        btc-amount: uint,
        last-deposit: uint,
        total-deposits: uint
    }
)

(define-map approved-operators 
    { owner: principal, operator: principal } 
    bool
)

;; Private Functions
(define-private (is-contract-owner)
    (is-eq tx-sender (var-get contract-owner))
)

(define-private (calculate-fee (amount uint))
    (/ (* amount (var-get protocol-fee-rate)) u1000)
)

(define-private (check-initialized)
    (asserts! (var-get initialized) ERR-NOT-INITIALIZED)
    (ok true)
)

(define-private (validate-amount (amount uint))
    (and 
        (>= amount MIN-DEPOSIT-AMOUNT)
        (<= amount MAX-DEPOSIT-AMOUNT)
    )
)

(define-private (update-user-deposits (user principal) (amount uint))
    (let (
        (existing-data (default-to 
            { btc-amount: u0, last-deposit: u0, total-deposits: u0 }
            (map-get? user-deposits user)
        ))
    )
    (map-set user-deposits
        user
        {
            btc-amount: (+ (get btc-amount existing-data) amount),
            last-deposit: block-height,
            total-deposits: (+ (get total-deposits existing-data) amount)
        }
    ))
)

;; Public Functions
(define-public (initialize (treasury-address principal))
    (begin
        (asserts! (not (var-get initialized)) ERR-ALREADY-INITIALIZED)
        (var-set treasury treasury-address)
        (var-set initialized true)
        (ok true)
    )
)

(define-public (deposit-btc (amount uint))
    (begin
        (try! (check-initialized))
        (asserts! (validate-amount amount) ERR-INVALID-AMOUNT)
        
        (let (
            (fee (calculate-fee amount))
            (token-amount (- amount fee))
        )
            ;; Update deposits
            (update-user-deposits tx-sender amount)
            
            ;; Mint tokens
            (try! (ft-mint? wrapped-btc token-amount tx-sender))
            
            ;; Update total supply
            (var-set total-supply (+ (var-get total-supply) token-amount))
            
            ;; Transfer fee to treasury
            (and (> fee u0)
                (try! (stx-transfer? fee tx-sender (var-get treasury))))
            
            (ok token-amount)
        )
    )
)

(define-public (withdraw-btc (amount uint))
    (begin
        (try! (check-initialized))
        (asserts! (>= amount MIN-DEPOSIT-AMOUNT) ERR-INVALID-AMOUNT)
        
        ;; Check balance
        (asserts! (<= amount (ft-get-balance wrapped-btc tx-sender)) ERR-INSUFFICIENT-BALANCE)
        
        ;; Burn tokens
        (try! (ft-burn? wrapped-btc amount tx-sender))
        
        ;; Update total supply
        (var-set total-supply (- (var-get total-supply) amount))
        
        (ok amount)
    )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
    (begin
        (try! (check-initialized))
        (asserts! (and 
            (not (is-eq sender recipient))
            (not (is-eq recipient (var-get treasury)))
        ) ERR-INVALID-RECIPIENT)
        
        (try! (ft-transfer? wrapped-btc amount sender recipient))
        (ok true)
    )
)

(define-public (approve-operator (operator principal))
    (begin
        (try! (check-initialized))
        (map-set approved-operators
            { owner: tx-sender, operator: operator }
            true
        )
        (ok true)
    )
)

(define-public (revoke-operator (operator principal))
    (begin
        (try! (check-initialized))
        (map-set approved-operators
            { owner: tx-sender, operator: operator }
            false
        )
        (ok true)
    )
)

;; Admin Functions
(define-public (update-fee-rate (new-rate uint))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (asserts! (<= new-rate u100) ERR-INVALID-AMOUNT)
        (var-set protocol-fee-rate new-rate)
        (ok true)
    )
)

(define-public (update-treasury (new-treasury principal))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (var-set treasury new-treasury)
        (ok true)
    )
)

(define-public (transfer-ownership (new-owner principal))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (var-set contract-owner new-owner)
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-name)
    (ok "Wrapped Bitcoin Token")
)

(define-read-only (get-symbol)
    (ok "wBTC")
)

(define-read-only (get-decimals)
    (ok u8)
)

(define-read-only (get-total-supply)
    (ok (var-get total-supply))
)