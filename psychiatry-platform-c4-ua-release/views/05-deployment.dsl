# C4 deployment views

deployment * production "C4-01-ProductionDeployment" "Виробниче гібридне розгортання з DMZ, прикладним кластером, приватним кластером даних, моніторингом і зовнішніми сервісами." {
    title "C4.01 — Виробниче гібридне розгортання"
    include *
    autoLayout lr 350 250
}

deployment * offlineClinic "C4-02-OfflineClinicDeployment" "Локальний edge-контур закладу для критичних функцій при обмеженому або нестабільному зовнішньому зв'язку." {
    title "C4.02 — Локальний контур закладу з обмеженим зв'язком"
    include *
    autoLayout lr 350 250
}
