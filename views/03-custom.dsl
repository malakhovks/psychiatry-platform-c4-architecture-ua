# C4 Level 4 / custom: логічні контракти даних і правил

custom "L4-01-AlgorithmDefinition" "L4.01 — Контракт визначення універсального алгоритму" "Логічна структура версійованого формального визначення алгоритму." {
    include codeAlgorithmDefinition codeEligibility codeConsent codeStep codeQuestion codeBranchRule codeScoringRule codeRedFlagRule
    include codeMeasurement codeOutcome codeRouting codeFollowUp codeCommunication codeDataPolicy codeTestCase
    autoLayout lr 350 220
}

custom "L4-02-ScenarioSession" "L4.02 — Агрегат виконання сценарію" "Логічна структура сесії, результатів, ризиків, клінічного підтвердження й аудиту." {
    include codeScenarioSession codeAlgorithmDefinition codePatientContext codeSessionConsent codeAnswer codeMeasurementResult
    include codeScore codeRiskFlag codeDecisionDraft codeClinicalDecision codeCareTrajectory codeTask codeAuditEvent
    autoLayout lr 350 220
}
