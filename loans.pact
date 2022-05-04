;;author @aleballest
;; define and read keyset named loans-admin-keyset
(define-keyset 'loans-admin
  (read-keyset "loans-admin"))

;; define module named loans with access given to loans-admin-keyset
(module loans 'loans-admin
    "loans module"
    
    ;;define all schemas for application
    (defschema loan
      "loan schema"
      loanName: string
      entityName: string
      loanAmount: integer
      status: string
    )

    (defschema loan-history
      "loan history schema"
      loanId: string
      buyer: string
      seller: string
      amount: integer
    )

    (defschema loan-inventory
      "loan inventory schema"
      balance: integer
    )


    ;;define all tables for application
    (deftable loan-table:{loan})
    (deftable loan-history-table:{loan-history})
    (deftable loan-inventory-table:{loan-inventory})

    ;;define constants
    (defconst INITIATED "initiated")
    (defconst ASSIGNED "assigned")
  
    (defun inventory-key (loanId:string owner:string)
        "creates a key from the owner and loanId in the format loanId:owner"
        ;; format a composite key from OWNER and LoanId in the format "loanId:owner"
        (format "{}:{}" [loanId owner])
    )

    (defun create-loan (loanId:string loanName:string entityName:string loanAmount:integer)
        "allows users to create loans"
        (insert loan-table loanId {"loanName":loanName, "entityName":entityName, "loanAmount":loanAmount, "status":INITIATED})
        (insert loan-inventory-table (inventory-key loanId entityName) {"balance":loanAmount})
    )
    
    (defun assign-loan (txnId:string loanId:string buyer:string amount:integer)
        "takes parameters txid, loanId, buyer, and amount; assigns loan to a specific entity when needed"
        ;; read from loans-table using loanId
        (with-read loans-table loanId {
        ;; bind "entityName" to the value of entityName
        "entityName":= entityName,
        ;; bind "loanAmount" to the value of issuerBalance
        "loanAmount":= issuerBalance}
        ;;insert into loan-history-table usinx txnId
        (insert loan-history-table txnId {"loanId":loanId, "buyer":buyer, "seller":seller, "amount":amount})
        ;; insert to loan-inventory-table with  inventory-key, loanId, and buyer
        (insert loan-inventory-table (inventory-key loanId buyer) {"balance":amount})
        ;; update loan-inventory-table with the parameters inventory-key, loanId, and entityName
        (update loan-inventory-table (inventory-key loanId entityName){
        ;; update new balance of the issuer in the inventory table
        "balance": (- issuerBalance amount)
        })
        ;; update loan-table using loanId, update "status" to value ASSIGNED
        (update loan-table loanId {"status": ASSIGNED})
    )
    
    (defun sell-loan (txnId:string, loanId:string, buyer:string, seller:string, amount:integer)
        (with-read loan-inventory-table (inventory-key loanId seller){
            ;; bind "balance" to the value of balance
            "balance":= prev-seller-balance}
            (with-read loan-inventory-table (inventory-key loanId buyer){
            "balance":0}
            {"balance":= prev-buyer-balance})
            (insert loan-history-table txnId {"loanId":loanId, "buyer":buyer, "seller":seller, "amount", amount})
            (update loan-inventory-table (inventory-key loanId seller) {"balance": (- prev-seller-balance amount)})
            (write loan-inventory-table (inventory-key loanId buyer) {"balance": (+ prev-buyer-balance amount)})
         )
    )

    (defun read-loan (loanId:string)
        (with-read loan-table loanId))
    )

)


  ;; ------------------------------------------------
  ;;              5.5-read-a-loan
  ;; ------------------------------------------------

  ;; define a function named read-a-loan that takes parameter loanId

  ;; read all values of the loans-table at the given loanId


  ;; ------------------------------------------------
  ;;             5.6-read-loan-tx
  ;; ------------------------------------------------

  ;; define a function named read-loan-tx that takes no parameters

    ;; map the values of the transaction log in the loans table to the txids in the loans table at value 0


  ;; ------------------------------------------------
  ;;              5.7-read-all-loans
  ;; ------------------------------------------------

  ;; define a function named read-all-loans that takes no parameters

    ;; select all values from the loans-table with constantly set to true


  ;; ------------------------------------------------
  ;;              5.8-read-inventory-pair
  ;; ------------------------------------------------

  ;; define a function named read-inventory-pair that takes a parameter named key

    ;; set "inventory-key" to the provided key

     ;; set "balance" the value of the balance of loan-inventory-table at the value of the key



  ;; ------------------------------------------------
  ;;            5.9-read-loan-inventory
  ;; ------------------------------------------------

  ;; define a function named read-loan-inventory that takes no parameters

    ;; map the value of read-inventory-pair to the keys of the loan-inventory-table


  ;; ------------------------------------------------
  ;;          5.10-read-loans-with-status
  ;; ------------------------------------------------

  ;; define a function named read-loans-with-status that takes the parameter status

    ;; select all values from the loans-table where "status" equals the parameter status


;; final parenthesis to close module

;; ================================================
;;                 6-create-tables
;; ================================================

;; create loans-table

;; create loans-history-table

;; create loans-inventory-table
