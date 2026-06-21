auditService = container "Сервіс аудиту та спостережуваності" "Збирає незмінні клінічні й безпекові події, походження рішень, технічні метрики та докази виконання." "Audit and observability service" "AuditService,Security" {
    auditCollector = component "Збирач аудиту" "Приймає підписані події про доступ, зміну, обчислення, перегляд, публікацію та ескалацію." "Audit ingestion" "AuditComponent"
    provenanceService = component "Сервіс походження даних і рішень" "Пов'язує результат із введенням, алгоритмом, моделлю, правилом, користувачем і часовою міткою." "Provenance graph" "AuditComponent"
    securityMonitor = component "Монітор безпеки" "Виявляє аномальний доступ, масове вивантаження, зловживання токенами й порушення сегментації." "SIEM integration" "AuditComponent,Security"
    complianceReporter = component "Формувач звітів" "Готує перевірювані журнали з урахуванням ролей, строків зберігання та прав суб'єкта даних." "Reporting" "AuditComponent"
    telemetryExporter = component "Експортер телеметрії" "Передає метрики, трасування й технічні логи без клінічного змісту до засобів моніторингу." "OpenTelemetry" "AuditComponent"
}

eventBus = container "Шина доменних подій" "Надійно розповсюджує події сесій, результатів, ескалацій, завдань і інтеграцій між сервісами." "Event broker" "EventBus"
operationalDb = container "Операційна база даних" "Сесії, технічний стан діалогу, черги завдань та ідемпотентні ключі; не є довгостроковою клінічною картою." "Relational database" "DataStore"
clinicalRepository = container "Клінічне сховище" "Версійовані структуровані скарги, відповіді, результати, плани, підтвердження та походження." "FHIR-oriented clinical repository" "DataStore,ClinicalDataStore"
algorithmRegistry = container "Реєстр алгоритмів" "Незмінні підписані опубліковані версії визначень, тестові докази, статус і строки чинності." "Versioned registry" "DataStore,Registry"
mediaStore = container "Захищене об'єктне сховище" "Зашифровані голосові, відео, сигнальні та зображувальні об'єкти з політикою строків зберігання." "Encrypted object storage" "DataStore,SensitiveDataStore"
knowledgeStore = container "База знань та індекс пошуку" "Дозволені фрагменти протоколів, довідки, термінологічні зв'язки й векторний індекс із версіями." "Document and vector store" "DataStore,KnowledgeDataStore"
auditStore = container "Незмінне сховище аудиту" "Append-only події з контрольними сумами, часовими мітками й політикою довготривалого зберігання." "WORM / append-only storage" "DataStore,AuditDataStore"
analyticsWarehouse = container "Аналітичне сховище" "Знеособлені або агреговані набори для контролю якості, досліджень і моніторингу дрейфу." "Analytics warehouse" "DataStore,AnalyticsDataStore"
cache = container "Кеш і короткоживучий стан" "Короткоживучі сесійні дані, блокування та технічні довідники без постійного клінічного зберігання." "In-memory data store" "DataStore,EphemeralDataStore"
