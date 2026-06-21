# C4 Level 1: ландшафт і системні контексти

systemLandscape "C1-01-Landscape" "Слайдове подання ландшафту платформи, мультидисциплінарних клінічних ролей і зовнішньої цифрової екосистеми." {
    title "C1.01 — Ландшафт системи психіатричних сценаріїв"
    include patient psychiatrist psychologist nurse cardiologist rehabilitationSpecialist neurologist pediatrician researcher securityOfficer
    include platform identityProvider ehrSystem terminologySystem protocolRepository algorithmSourceRepository
    include notificationProvider calendarProvider telemedicinePlatform emergencySystem deviceEcosystem pacsSystem externalAIModels
    autoLayout lr 260 160
}

systemContext platform "C1-02-PlatformContext" "Повний системний контекст платформи та її зовнішніх залежностей." {
    title "C1.02 — Системний контекст платформи"
    include patient psychiatrist psychologist nurse crisisSpecialist methodologist researcher securityOfficer platform
    include identityProvider ehrSystem terminologySystem protocolRepository algorithmSourceRepository notificationProvider
    include calendarProvider telemedicinePlatform emergencySystem deviceEcosystem pacsSystem externalAIModels
    autoLayout lr 350 250
}

systemContext platform "C1-03-PatientContext" "Компактний контекст взаємодії пацієнта і лікаря: скринінг, вимірювання, адаптивна комунікація, підготовка до консультації та маршрутизація." {
    title "C1.03 — Контекст ШІ-асистента пацієнта"
    include patient psychiatrist platform identityProvider notificationProvider calendarProvider telemedicinePlatform emergencySystem deviceEcosystem externalAIModels
    autoLayout lr 240 150
}

systemContext platform "C1-04-ClinicianContext" "Слайдове подання мультидисциплінарного клінічного контуру: структурування даних, протоколи, ризики, мультимодальний аналіз і траєкторія пацієнта." {
    title "C1.04 — Контекст ШІ-асистента медичного працівника"
    include psychiatrist psychologist nurse crisisSpecialist cardiologist rehabilitationSpecialist neurologist pediatrician platform identityProvider ehrSystem terminologySystem protocolRepository telemedicinePlatform emergencySystem deviceEcosystem pacsSystem externalAIModels
    autoLayout lr 240 150
}

systemContext platform "C1-05-AlgorithmLifecycleContext" "Контекст життєвого циклу клінічних алгоритмів — від проєктного документа до перевіреної опублікованої версії." {
    title "C1.05 — Контекст формалізації та керування алгоритмами"
    include methodologist securityOfficer psychiatrist psychologist platform identityProvider algorithmSourceRepository protocolRepository terminologySystem
    autoLayout lr 350 250
}

# C4 Level 2: контейнерні подання

container platform "C2-01-PlatformContainers" "Повне контейнерне подання платформи з розподілом на інтерфейси, доменні сервіси, інтеграції та сховища." {
    title "C2.01 — Контейнери програмної платформи"
    include patient psychiatrist psychologist nurse crisisSpecialist methodologist researcher securityOfficer
    include platform.patientApp platform.clinicianApp platform.algorithmStudio platform.apiGateway platform.identityConsentService
    include platform.interactionOrchestrator platform.scenarioEngine platform.clinicalDecisionSupport platform.aiOrchestrator
    include platform.measurementService platform.schedulerService platform.integrationGateway platform.auditService platform.eventBus
    include platform.operationalDb platform.clinicalRepository platform.algorithmRegistry platform.mediaStore platform.knowledgeStore
    include platform.auditStore platform.analyticsWarehouse platform.cache
    include identityProvider ehrSystem terminologySystem protocolRepository algorithmSourceRepository notificationProvider calendarProvider telemedicinePlatform emergencySystem deviceEcosystem pacsSystem externalAIModels
    autoLayout lr 450 250
}

container platform "C2-02-PatientPath" "Фокус на наскрізному пацієнтському контурі та каналах текст, голос, відео, аватар, VR і голос-в-текст." {
    title "C2.02 — Контейнери пацієнтського контуру"
    include patient platform.patientApp platform.apiGateway platform.identityConsentService platform.interactionOrchestrator
    include platform.scenarioEngine platform.aiOrchestrator platform.measurementService platform.schedulerService platform.integrationGateway
    include platform.operationalDb platform.clinicalRepository platform.algorithmRegistry platform.mediaStore platform.knowledgeStore platform.cache
    include identityProvider notificationProvider calendarProvider telemedicinePlatform emergencySystem deviceEcosystem externalAIModels
    autoLayout lr 400 250
}

container platform "C2-03-ClinicianPath" "Фокус на структурованому огляді, ризиках, протоколах, результатах вимірювань, поясненні та клінічному підтвердженні." {
    title "C2.03 — Контейнери контуру медичного працівника"
    include psychiatrist psychologist nurse crisisSpecialist platform.clinicianApp platform.apiGateway platform.identityConsentService
    include platform.scenarioEngine platform.clinicalDecisionSupport platform.measurementService platform.schedulerService platform.integrationGateway platform.auditService
    include platform.clinicalRepository platform.knowledgeStore platform.mediaStore platform.auditStore
    include ehrSystem terminologySystem protocolRepository telemedicinePlatform emergencySystem deviceEcosystem pacsSystem
    autoLayout lr 400 250
}

container platform "C2-04-AlgorithmLifecycle" "Контейнери проєктування, перевірки, публікації, виконання та відкликання універсальних визначень алгоритмів." {
    title "C2.04 — Життєвий цикл алгоритмів"
    include methodologist securityOfficer psychiatrist psychologist platform.algorithmStudio platform.apiGateway platform.identityConsentService
    include platform.scenarioEngine platform.algorithmRegistry platform.auditService platform.auditStore platform.eventBus
    include algorithmSourceRepository protocolRepository terminologySystem identityProvider
    autoLayout lr 400 250
}

container platform "C2-05-DataIntegration" "Потоки клінічних, мультимодальних, інтеграційних, аудиторських та аналітичних даних." {
    title "C2.05 — Дані та зовнішні інтеграції"
    include platform.apiGateway platform.identityConsentService platform.scenarioEngine platform.clinicalDecisionSupport platform.aiOrchestrator
    include platform.measurementService platform.schedulerService platform.integrationGateway platform.auditService platform.eventBus
    include platform.operationalDb platform.clinicalRepository platform.algorithmRegistry platform.mediaStore platform.knowledgeStore platform.auditStore platform.analyticsWarehouse platform.cache
    include identityProvider ehrSystem terminologySystem protocolRepository notificationProvider calendarProvider telemedicinePlatform emergencySystem deviceEcosystem pacsSystem externalAIModels
    autoLayout lr 450 250
}

container platform "C2-06-SafetyGovernance" "Архітектурні механізми клінічної безпеки, приватності, контролю людиною, відтворюваності й аудиту." {
    title "C2.06 — Безпека, клінічне керування та аудит"
    include patient psychiatrist psychologist crisisSpecialist methodologist securityOfficer
    include platform.patientApp platform.clinicianApp platform.algorithmStudio platform.apiGateway platform.identityConsentService
    include platform.scenarioEngine platform.clinicalDecisionSupport platform.aiOrchestrator platform.schedulerService platform.integrationGateway platform.auditService
    include platform.algorithmRegistry platform.clinicalRepository platform.auditStore platform.analyticsWarehouse
    include identityProvider emergencySystem externalAIModels
    autoLayout lr 400 250
}
