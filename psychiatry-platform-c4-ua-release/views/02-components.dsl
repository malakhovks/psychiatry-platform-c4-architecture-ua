# C4 Level 3: компонентні подання

component platform.patientApp "C3-01-PatientApp" "Компоненти пацієнтського застосунку та їхні точки взаємодії з платформою." {
    title "C3.01 — Компоненти застосунку пацієнта"
    include patient platform.patientApp.appShell platform.patientApp.accessibilityModule platform.patientApp.communicationPreferences
    include platform.patientApp.complaintIntake platform.patientApp.questionnaireRenderer platform.patientApp.mediaCapture
    include platform.patientApp.measurementWizard platform.patientApp.calendarUi platform.patientApp.visitPreparation platform.patientApp.crisisControl
    include platform.apiGateway telemedicinePlatform emergencySystem
    autoLayout lr 350 220
}

component platform.clinicianApp "C3-02-ClinicianApp" "Компоненти кабінету медичного працівника з окремим контролем ризиків, пояснень і підтвердження." {
    title "C3.02 — Компоненти кабінету медичного працівника"
    include psychiatrist psychologist nurse crisisSpecialist
    include platform.clinicianApp.patientTimeline platform.clinicianApp.assessmentWorkspace platform.clinicianApp.resultReview
    include platform.clinicianApp.redFlagPanel platform.clinicianApp.protocolPanel platform.clinicianApp.trajectoryEditor
    include platform.clinicianApp.teleconsultationUi platform.clinicianApp.approvalUi
    include platform.apiGateway telemedicinePlatform
    autoLayout lr 350 220
}

component platform.algorithmStudio "C3-03-AlgorithmStudio" "Компоненти формалізації та керування життєвим циклом алгоритму." {
    title "C3.03 — Компоненти студії алгоритмів"
    include methodologist securityOfficer
    include platform.algorithmStudio.sourceImporter platform.algorithmStudio.definitionEditor platform.algorithmStudio.clinicalValidator
    include platform.algorithmStudio.testRunner platform.algorithmStudio.approvalWorkflow platform.algorithmStudio.versionManager platform.algorithmStudio.publisher
    include algorithmSourceRepository platform.algorithmRegistry platform.auditService
    autoLayout lr 350 220
}

component platform.apiGateway "C3-04-ApiGateway" "Компоненти контрольованого входу, перевірки токенів, квот, контрактів і маршрутизації." {
    title "C3.04 — Компоненти API-шлюзу"
    include platform.patientApp platform.clinicianApp platform.algorithmStudio
    include platform.apiGateway.authMiddleware platform.apiGateway.rateLimiter platform.apiGateway.schemaFirewall platform.apiGateway.apiRouter
    include platform.identityConsentService platform.interactionOrchestrator platform.scenarioEngine platform.clinicalDecisionSupport platform.measurementService platform.schedulerService platform.integrationGateway platform.auditService
    autoLayout lr 350 220
}

component platform.identityConsentService "C3-05-IdentityConsent" "Компоненти федеративної ідентичності, атрибутної авторизації, згод і сесійних токенів." {
    title "C3.05 — Компоненти ідентичності, доступу та згод"
    include platform.apiGateway
    include platform.identityConsentService.oidcAdapter platform.identityConsentService.rbacAbac platform.identityConsentService.consentManager platform.identityConsentService.sessionTokenService
    include identityProvider platform.operationalDb platform.clinicalRepository platform.auditService
    autoLayout lr 350 220
}

component platform.interactionOrchestrator "C3-06-InteractionOrchestrator" "Компоненти сесії, діалогового стану, контексту, каналів і адаптивної комунікації." {
    title "C3.06 — Компоненти оркестратора взаємодії"
    include platform.apiGateway
    include platform.interactionOrchestrator.sessionManager platform.interactionOrchestrator.dialogueState platform.interactionOrchestrator.contextAssembler
    include platform.interactionOrchestrator.channelRouter platform.interactionOrchestrator.styleSelector platform.interactionOrchestrator.responseCoordinator
    include platform.scenarioEngine platform.aiOrchestrator platform.schedulerService platform.operationalDb platform.clinicalRepository platform.cache platform.auditService
    autoLayout lr 350 220
}

component platform.scenarioEngine "C3-07-ScenarioEngine" "Компоненти універсального детермінованого виконання клінічного сценарію." {
    title "C3.07 — Компоненти детермінованого рушія сценаріїв"
    include platform.interactionOrchestrator
    include platform.scenarioEngine.definitionLoader platform.scenarioEngine.schemaValidator platform.scenarioEngine.stateMachine
    include platform.scenarioEngine.stepSelector platform.scenarioEngine.branchingEvaluator platform.scenarioEngine.answerValidator
    include platform.scenarioEngine.scoringCalculator platform.scenarioEngine.redFlagEvaluator platform.scenarioEngine.outcomeMapper platform.scenarioEngine.provenanceRecorder
    include platform.algorithmRegistry platform.clinicalRepository platform.clinicalDecisionSupport platform.measurementService platform.schedulerService platform.auditService
    autoLayout lr 350 220
}

component platform.clinicalDecisionSupport "C3-08-ClinicalDecisionSupport" "Компоненти нормалізації, агрегації ризику, підбору протоколу, траєкторії, пояснення та клінічного контролю." {
    title "C3.08 — Компоненти підтримки клінічних рішень"
    include platform.scenarioEngine platform.clinicianApp
    include platform.clinicalDecisionSupport.dataNormalizer platform.clinicalDecisionSupport.riskAggregator platform.clinicalDecisionSupport.protocolMatcher
    include platform.clinicalDecisionSupport.trajectoryPlanner platform.clinicalDecisionSupport.followUpPlanner
    include platform.clinicalDecisionSupport.explanationBuilder platform.clinicalDecisionSupport.clinicalReviewGate
    include protocolRepository platform.knowledgeStore platform.schedulerService platform.clinicalRepository platform.auditService
    autoLayout lr 350 220
}

component platform.aiOrchestrator "C3-09-AIOrchestrator" "Компоненти безпечного застосування генеративних і спеціалізованих моделей ШІ." {
    title "C3.09 — Компоненти оркестратора ШІ та запобіжників"
    include platform.interactionOrchestrator
    include platform.aiOrchestrator.structuredExtractor platform.aiOrchestrator.promptManager platform.aiOrchestrator.ragRetriever
    include platform.aiOrchestrator.modelRouter platform.aiOrchestrator.safetyGuardrails platform.aiOrchestrator.outputValidator
    include platform.aiOrchestrator.responseComposer platform.aiOrchestrator.humanControl
    include platform.knowledgeStore protocolRepository externalAIModels platform.auditService
    autoLayout lr 350 220
}

component platform.measurementService "C3-10-MeasurementService" "Компоненти приймання, контролю якості, аналізу та нормалізації мультимодальних вимірювань." {
    title "C3.10 — Компоненти мультимодальних вимірювань"
    include platform.scenarioEngine
    include platform.measurementService.deviceGateway platform.measurementService.qualityAssessor platform.measurementService.signalPreprocessor
    include platform.measurementService.ecgMinnesotaAnalyzer platform.measurementService.voiceAnalyzer platform.measurementService.videoAnalyzer platform.measurementService.imageAnalyzer
    include platform.measurementService.featureFusion platform.measurementService.measurementNormalizer
    include deviceEcosystem externalAIModels platform.mediaStore platform.clinicalRepository platform.auditService
    autoLayout lr 350 220
}

component platform.schedulerService "C3-11-Scheduler" "Компоненти планування завдань, нагадувань, SLA ескалації та надійних повторів." {
    title "C3.11 — Компоненти завдань, нагадувань та ескалацій"
    include platform.interactionOrchestrator platform.scenarioEngine platform.clinicalDecisionSupport
    include platform.schedulerService.taskPlanner platform.schedulerService.reminderDispatcher platform.schedulerService.escalationScheduler platform.schedulerService.retryManager
    include platform.integrationGateway platform.operationalDb platform.auditService
    autoLayout lr 350 220
}

component platform.integrationGateway "C3-12-IntegrationGateway" "Компоненти FHIR/DICOM-обміну, термінологій, повідомлень, календаря, телемедицини та приватності." {
    title "C3.12 — Компоненти інтеграційного шлюзу"
    include platform.apiGateway platform.schedulerService
    include platform.integrationGateway.fhirApi platform.integrationGateway.ehrConnector platform.integrationGateway.terminologyAdapter
    include platform.integrationGateway.dicomConnector platform.integrationGateway.notificationAdapter platform.integrationGateway.calendarAdapter
    include platform.integrationGateway.telemedicineAdapter platform.integrationGateway.consentPolicyEnforcer platform.integrationGateway.pseudonymizer
    include ehrSystem terminologySystem pacsSystem notificationProvider calendarProvider telemedicinePlatform emergencySystem platform.clinicalRepository platform.analyticsWarehouse
    autoLayout lr 350 220
}

component platform.auditService "C3-13-AuditObservability" "Компоненти незмінного аудиту, походження, безпекового моніторингу, звітності та очищеної телеметрії." {
    title "C3.13 — Компоненти аудиту та спостережуваності"
    include securityOfficer
    include platform.auditService.auditCollector platform.auditService.provenanceService platform.auditService.securityMonitor
    include platform.auditService.complianceReporter platform.auditService.telemetryExporter
    include platform.auditStore platform.analyticsWarehouse
    autoLayout lr 350 220
}
