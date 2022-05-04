;; author @aleballest
;; Rotatable Wallet Contract
(namespace "free")
;;;;-----------------------------------------------------------
;;  When deploying new contracts, ensure to use a unique keyset
;;  and unique module from any previously deployed contract
;; Keysets cannot be created in code, thus we read them in
;; from the load message data.
;;;;-----------------------------------------------------------

;; define and read module-admin keyset
(define-keyset 'module-admin
  (read-keyset "module-admin"))
;; define and read operate-admin keyset
(define-keyset 'operate-admin
  (read-keyset "operate-admin"))

;; Define the module.
(module auth 'module-admin
    "auth module"
  
    ;;define a user schema
    (defschema user
      nickname:string
      keyset:keyset
    )

    ;;define a users table
    (deftable users:{user})

    (defun hello-world (str)
        "This function takes a string and returns hello world!, + string"
        (+ "hello world!, " str)
    )

    (defun create-user (id nickname keyset)
        "define a function create-user that takes arguments id, nickname, and keyset"
        ;;enforce access to restrict function calls to the operate-admin
        (enforce-keyset 'operate-admin)
        ;; insert a row into the users table at the given id, keyset, and nickname
        (insert users id {
            "keyset": keyset,
            "nickname": nickname
        })
    )
    
    (defun enforce-user (id)
        "restrict access permissions for a given row in the data to only users with a given id"
        ;; read users table to find id then bind value k equal this id's keyset
        (with-read users id { "keyset":= k }
            ;; enforce user authorization of data to the given keyset
            (enforce-keyset k)
            ;;return the value of the keyset
            k)
    )

    (defun update-nickname (id new-nickname)
        "allow users to update their own nickname"
        ;;verify that this user has access to referenced id data
        (enforce-user id)
        ;;update data
        (update users id { "nickname": new-nickname })
        ;;return a message summarizing the update
        (format "updated nickname for user {} to {}" [id new-nickname])
    )

    (defun update-keyset (id new-keyset)
        "allow users to update their own keyset"
        ;;verify that this user has access to referenced id data
        (enforce-user id)
        ;;update data
        (update users id { "keyset": new-keyset})
        ;;return a message summarizing the update
        (format "Updated keyset for user {} to {}" [id new-keyset])
    )
)
;; and say hello!
(hello-world "my name is aleballest")


