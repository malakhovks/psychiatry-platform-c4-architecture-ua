# Фізичне розгортання: основний гібридний контур
production = deploymentEnvironment "Виробниче гібридне середовище" {
    prodPatientDevice = deploymentNode "Пристрій пацієнта" "Смартфон, планшет або персональний комп'ютер пацієнта." "Android / iOS / modern browser" "ClientNode" {
        prodPatientApp = containerInstance platform.patientApp
    }

    prodClinicianDevice = deploymentNode "Робоче місце медичного працівника" "Керований пристрій із захищеним браузером і багатофакторною автентифікацією." "Managed workstation" "ClientNode,TrustedNode" {
        prodClinicianApp = containerInstance platform.clinicianApp
    }

    prodMethodologistDevice = deploymentNode "Робоче місце методолога" "Керований адміністративний пристрій для редагування й погодження алгоритмів." "Managed workstation" "ClientNode,TrustedNode" {
        prodAlgorithmStudio = containerInstance platform.algorithmStudio
    }

    prodDmz = deploymentNode "Периметр / DMZ" "Публічний вхід із сегментацією, фільтрацією та припиненням TLS." "Hardened Linux / reverse proxy" "DMZNode" {
        prodWaf = infrastructureNode "WAF і захист від DDoS" "Фільтрує мережевий трафік та відомі класи атак." "WAF" "SecurityInfrastructure"
        prodApiGateway = containerInstance platform.apiGateway
        prodWaf -> prodApiGateway "Передає дозволений TLS-трафік"
    }

    prodApplicationCluster = deploymentNode "Кластер прикладних сервісів" "Відмовостійкий приватний кластер з автоматичним масштабуванням і мережевою сегментацією." "Kubernetes / containers" "ApplicationNode" "3..N" {
        prodServiceMesh = infrastructureNode "Service mesh" "Взаємна TLS-автентифікація, політики сервісної мережі та трасування." "mTLS service mesh" "SecurityInfrastructure"
        prodIdentity = containerInstance platform.identityConsentService
        prodInteraction = containerInstance platform.interactionOrchestrator
        prodScenario = containerInstance platform.scenarioEngine
        prodCds = containerInstance platform.clinicalDecisionSupport
        prodAi = containerInstance platform.aiOrchestrator
        prodMeasurement = containerInstance platform.measurementService
        prodScheduler = containerInstance platform.schedulerService
        prodIntegration = containerInstance platform.integrationGateway
        prodAudit = containerInstance platform.auditService
        prodEventBus = containerInstance platform.eventBus
        prodCache = containerInstance platform.cache
        prodAudit -> prodServiceMesh "Експортує безпечну технічну телеметрію"
    }

    prodDataCluster = deploymentNode "Кластер клінічних даних" "Приватний сегмент із шифруванням, реплікацією, резервним копіюванням і розділенням обов'язків." "HA databases and object storage" "DataNode,TrustedNode" {
        prodKms = infrastructureNode "KMS / HSM" "Керує ключами шифрування та операціями підпису." "KMS/HSM" "SecurityInfrastructure"
        prodBackup = infrastructureNode "Резервне копіювання та відновлення" "Незмінні резервні копії, перевірка відновлення й окремий домен доступу." "Backup/DR" "SecurityInfrastructure"
        prodOperationalDb = containerInstance platform.operationalDb
        prodClinicalRepo = containerInstance platform.clinicalRepository
        prodAlgorithmRegistry = containerInstance platform.algorithmRegistry
        prodMediaStore = containerInstance platform.mediaStore
        prodKnowledgeStore = containerInstance platform.knowledgeStore
        prodAuditStore = containerInstance platform.auditStore
        prodAnalytics = containerInstance platform.analyticsWarehouse
        prodClinicalRepo -> prodKms "Використовує ключі шифрування"
        prodMediaStore -> prodKms "Використовує ключі шифрування"
        prodAuditStore -> prodKms "Використовує ключі підпису й шифрування"
        prodClinicalRepo -> prodBackup "Передає зашифровані резервні копії"
        prodAlgorithmRegistry -> prodBackup "Передає незмінні резервні копії"
        prodAuditStore -> prodBackup "Передає незмінні резервні копії"
    }

    prodMonitoring = deploymentNode "Контур моніторингу й реагування" "Ізольоване збирання метрик, трасувань, подій безпеки та оповіщень." "Observability/SIEM" "OperationsNode" {
        prodObservability = infrastructureNode "Моніторинг, трасування та SIEM" "Приймає очищену телеметрію без вмісту клінічних повідомлень." "OpenTelemetry / SIEM" "OperationsInfrastructure"
        prodAudit -> prodObservability "Передає технічну телеметрію й події безпеки"
    }

    prodExternal = deploymentNode "Зовнішні керовані сервіси" "Системи за межами довіреного контуру платформи." "External infrastructure" "ExternalNode" {
        prodIdp = softwareSystemInstance identityProvider
        prodEhr = softwareSystemInstance ehrSystem
        prodTerminology = softwareSystemInstance terminologySystem
        prodProtocols = softwareSystemInstance protocolRepository
        prodAlgorithmSource = softwareSystemInstance algorithmSourceRepository
        prodNotifications = softwareSystemInstance notificationProvider
        prodCalendar = softwareSystemInstance calendarProvider
        prodTelemedicine = softwareSystemInstance telemedicinePlatform
        prodEmergency = softwareSystemInstance emergencySystem
        prodDevices = softwareSystemInstance deviceEcosystem
        prodPacs = softwareSystemInstance pacsSystem
        prodModels = softwareSystemInstance externalAIModels
    }
}

# Фізичне розгортання: локальний контур закладу з обмеженим зв'язком
offlineClinic = deploymentEnvironment "Локальний контур закладу з обмеженим зв'язком" {
    edgePatientDevice = deploymentNode "Локальний пристрій пацієнта" "Пристрій у закладі або керований мобільний пристрій." "Browser / mobile" "ClientNode" {
        edgePatientApp = containerInstance platform.patientApp
    }

    edgeClinicianDevice = deploymentNode "Локальне робоче місце фахівця" "Керований пристрій у клінічній мережі." "Managed workstation" "ClientNode,TrustedNode" {
        edgeClinicianApp = containerInstance platform.clinicianApp
    }

    edgeServer = deploymentNode "Edge-сервер закладу" "Локальне виконання критичних функцій при нестабільному зовнішньому зв'язку." "Hardened Linux / lightweight Kubernetes" "EdgeNode,TrustedNode" {
        edgeGateway = containerInstance platform.apiGateway
        edgeIdentity = containerInstance platform.identityConsentService
        edgeInteraction = containerInstance platform.interactionOrchestrator
        edgeScenario = containerInstance platform.scenarioEngine
        edgeMeasurement = containerInstance platform.measurementService
        edgeScheduler = containerInstance platform.schedulerService
        edgeIntegration = containerInstance platform.integrationGateway
        edgeAudit = containerInstance platform.auditService
        edgeEventBus = containerInstance platform.eventBus
        edgeOperationalDb = containerInstance platform.operationalDb
        edgeClinicalRepo = containerInstance platform.clinicalRepository
        edgeAlgorithmRegistry = containerInstance platform.algorithmRegistry
        edgeMediaStore = containerInstance platform.mediaStore
        edgeAuditStore = containerInstance platform.auditStore
        edgeCache = containerInstance platform.cache
        edgeSyncQueue = infrastructureNode "Зашифрована черга синхронізації" "Накопичує ідемпотентні пакети до відновлення каналу." "Durable queue" "IntegrationInfrastructure"
        edgeIntegration -> edgeSyncQueue "Передає підписані пакети синхронізації"
    }

    edgeDevices = deploymentNode "Пристрої та сенсори закладу" "ЕКГ, мікрофон, камера й підтримувані теледіагностичні пристрої." "Medical devices" "DeviceNode" {
        edgeDeviceSystem = softwareSystemInstance deviceEcosystem
    }

    edgeSecureLink = deploymentNode "Захищений канал до центрального контуру" "Відновлюваний VPN/mTLS-канал із взаємною автентифікацією." "VPN / mTLS" "NetworkNode" {
        edgeVpn = infrastructureNode "VPN-шлюз" "Передає лише дозволені підписані пакети." "WireGuard/IPsec/mTLS" "SecurityInfrastructure"
        edgeSyncQueue -> edgeVpn "Передає накопичені пакети після відновлення зв'язку"
    }
}
