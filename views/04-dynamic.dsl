# Динамічні подання універсальних робочих процесів

dynamic platform "DYN-01-UniversalPatientScenario" "Універсальний наскрізний процес виконання будь-якого формалізованого психіатричного сценарію." {
    title "DYN.01 — Універсальний сценарій взаємодії з пацієнтом"
    1: patient -> platform.patientApp "Розпочинає звернення, обирає канал і надає дані"
    2: platform.patientApp -> platform.apiGateway "Надсилає захищений запит"
    3: platform.apiGateway -> platform.identityConsentService "Перевіряє ідентичність, повноваження та згоду"
    4: platform.apiGateway -> platform.interactionOrchestrator "Створює або відновлює діалогову сесію"
    5: platform.interactionOrchestrator -> platform.scenarioEngine "Запитує детермінований наступний крок"
    6: platform.scenarioEngine -> platform.algorithmRegistry "Завантажує закріплену версію алгоритму"
    7: platform.interactionOrchestrator -> platform.aiOrchestrator "Формує доступне допоміжне представлення кроку"
    8: platform.scenarioEngine -> platform.clinicalRepository "Зберігає типізовані відповіді та проміжний результат"
    9: platform.scenarioEngine -> platform.clinicalDecisionSupport "Передає структурований результат для клінічної агрегації"
    10: platform.interactionOrchestrator -> platform.schedulerService "Створює наступне завдання, контрольну точку або візит"
    11: platform.schedulerService -> platform.integrationGateway "Передає повідомлення або подію зовнішньому каналу"
    12: platform.integrationGateway -> notificationProvider "Надсилає мінімізоване нагадування"
    autoLayout lr 300 220
}

dynamic platform "DYN-02-OnboardingConsent" "Створення профілю сесії, автентифікація, інформування та фіксація згод." {
    title "DYN.02 — Вхід, доступ та інформована згода"
    1: patient -> platform.patientApp "Відкриває застосунок і обирає спосіб входу"
    2: platform.patientApp -> platform.apiGateway "Запитує початок сесії"
    3: platform.apiGateway -> platform.identityConsentService "Передає токен і мету доступу"
    4: platform.identityConsentService -> identityProvider "Перевіряє електронну ідентичність і MFA"
    5: platform.identityConsentService -> platform.clinicalRepository "Фіксує версію інформування, обсяг і строк згоди"
    6: platform.identityConsentService -> platform.auditService "Реєструє рішення доступу та знімок згод"
    7: platform.apiGateway -> platform.auditService "Реєструє результат початкового запиту"
    autoLayout lr 300 220
}

dynamic platform "DYN-03-ComplaintsAdaptiveCommunication" "Збір скарг і потреб із адаптацією каналу та стилю без зміни клінічного змісту." {
    title "DYN.03 — Збір скарг і адаптивна комунікація"
    1: patient -> platform.patientApp "Описує скарги, потреби та мету звернення"
    2: platform.patientApp -> platform.apiGateway "Передає текст, транскрипт або медіа за згодою"
    3: platform.apiGateway -> platform.interactionOrchestrator "Створює подію введення"
    4: platform.interactionOrchestrator -> platform.aiOrchestrator "Структурує вільний текст і визначає невизначені поля"
    5: platform.interactionOrchestrator -> platform.clinicalRepository "Зберігає підтверджені структуровані дані та джерело"
    6: platform.interactionOrchestrator -> platform.scenarioEngine "Отримує наступне уточнення або формальний крок"
    7: platform.interactionOrchestrator -> platform.auditService "Фіксує канал, політику стилю та походження репліки"
    autoLayout lr 300 220
}

dynamic platform.scenarioEngine "DYN-04-QuestionnaireScoring" "Внутрішній детермінований процес виконання опитувальника, розгалуження, оцінювання та формування результату." {
    title "DYN.04 — Опитувальник, розгалуження та обчислення балів"
    1: platform.scenarioEngine.definitionLoader -> platform.algorithmRegistry "Отримує підписану версію визначення"
    2: platform.scenarioEngine.definitionLoader -> platform.scenarioEngine.schemaValidator "Передає визначення на повторну перевірку"
    3: platform.scenarioEngine.schemaValidator -> platform.scenarioEngine.stateMachine "Активує валідний граф станів"
    4: platform.scenarioEngine.answerValidator -> platform.scenarioEngine.stateMachine "Передає типізовану відповідь"
    5: platform.scenarioEngine.stateMachine -> platform.scenarioEngine.stepSelector "Запитує наступний допустимий крок"
    6: platform.scenarioEngine.stepSelector -> platform.scenarioEngine.branchingEvaluator "Перевіряє умови переходу"
    7: platform.scenarioEngine.branchingEvaluator -> platform.scenarioEngine.scoringCalculator "Передає релевантні відповіді"
    8: platform.scenarioEngine.scoringCalculator -> platform.scenarioEngine.redFlagEvaluator "Обчислює бали та передає критичні ознаки"
    9: platform.scenarioEngine.redFlagEvaluator -> platform.scenarioEngine.outcomeMapper "Додає прапорці й пріоритет"
    10: platform.scenarioEngine.outcomeMapper -> platform.scenarioEngine.provenanceRecorder "Формує структурований результат"
    11: platform.scenarioEngine.outcomeMapper -> platform.clinicalDecisionSupport "Передає результат до підтримки клінічних рішень"
    12: platform.scenarioEngine.provenanceRecorder -> platform.clinicalRepository "Зберігає результат і відтворюване походження"
    13: platform.scenarioEngine.provenanceRecorder -> platform.auditService "Реєструє доказ виконання"
    autoLayout lr 300 220
}

dynamic platform "DYN-05-RedFlagCrisis" "Негайне виявлення, ескалація, підтвердження отримання та резервний кризовий маршрут." {
    title "DYN.05 — Червоний прапорець і кризове реагування"
    1: patient -> platform.patientApp "Надає відповідь або активує кнопку кризової допомоги"
    2: platform.patientApp -> platform.apiGateway "Передає пріоритетний запит"
    3: platform.apiGateway -> platform.scenarioEngine "Запускає формальну перевірку кризових правил"
    4: platform.scenarioEngine -> platform.schedulerService "Створює критичну ескалацію з максимальним строком реакції"
    5: platform.schedulerService -> platform.integrationGateway "Запускає основний і резервний канали"
    6: platform.integrationGateway -> emergencySystem "Передає мінімально необхідну кризову інформацію"
    7: platform.scenarioEngine -> platform.eventBus "Публікує подію червоного прапорця"
    8: platform.eventBus -> platform.auditService "Записує незмінний доказ ескалації"
    9: crisisSpecialist -> platform.clinicianApp "Відкриває пріоритетну картку випадку"
    10: platform.clinicianApp -> platform.apiGateway "Фіксує контакт, оцінку та вжиту дію"
    11: platform.apiGateway -> platform.clinicalDecisionSupport "Оновлює підтверджену траєкторію та подальші контрольні точки"
    autoLayout lr 300 220
}

dynamic platform.measurementService "DYN-06-MultimodalMeasurement" "Контрольований конвеєр ЕКГ, голосу, відео та медичних зображень." {
    title "DYN.06 — Мультимодальне вимірювання та контроль якості"
    1: deviceEcosystem -> platform.measurementService.deviceGateway "Передає дозволений сигнал і технічні метадані"
    2: platform.measurementService.deviceGateway -> platform.measurementService.qualityAssessor "Передає потік для перевірки якості"
    3: platform.measurementService.qualityAssessor -> platform.measurementService.signalPreprocessor "Допускає придатні дані до оброблення"
    4: platform.measurementService.signalPreprocessor -> platform.measurementService.ecgMinnesotaAnalyzer "Передає ЕКГ для кодування й виділення ознак"
    5: platform.measurementService.signalPreprocessor -> platform.measurementService.voiceAnalyzer "Передає аудіо для дозволеного аналізу"
    6: platform.measurementService.signalPreprocessor -> platform.measurementService.videoAnalyzer "Передає відео для дозволеного аналізу"
    7: platform.measurementService.signalPreprocessor -> platform.measurementService.imageAnalyzer "Передає підтримуване медичне зображення"
    8: platform.measurementService.ecgMinnesotaAnalyzer -> platform.measurementService.featureFusion "Додає коди й ознаки ЕКГ"
    9: platform.measurementService.voiceAnalyzer -> platform.measurementService.featureFusion "Додає голосові ознаки"
    10: platform.measurementService.videoAnalyzer -> platform.measurementService.featureFusion "Додає відеоознаки"
    11: platform.measurementService.imageAnalyzer -> platform.measurementService.featureFusion "Додає зображувальні ознаки"
    12: platform.measurementService.featureFusion -> platform.measurementService.measurementNormalizer "Формує узгоджений результат із внеском модальностей"
    13: platform.measurementService.measurementNormalizer -> platform.clinicalRepository "Зберігає показники, якість і версію аналізатора"
    14: platform.measurementService.measurementNormalizer -> platform.auditService "Фіксує ланцюг оброблення"
    autoLayout lr 300 220
}

dynamic platform.aiOrchestrator "DYN-07-SafeAIResponse" "Формування допоміжної ШІ-відповіді з мінімізацією даних, RAG, перевіркою структури та контролем людиною." {
    title "DYN.07 — Безпечне формування відповіді ШІ"
    1: platform.interactionOrchestrator -> platform.aiOrchestrator.promptManager "Передає завдання, локаль і дозволений контекст"
    2: platform.aiOrchestrator.promptManager -> platform.aiOrchestrator.ragRetriever "Запитує дозволені джерела"
    3: platform.aiOrchestrator.ragRetriever -> platform.knowledgeStore "Отримує фрагменти з версією і посиланням"
    4: platform.aiOrchestrator.promptManager -> platform.aiOrchestrator.safetyGuardrails "Застосовує клінічні та приватнісні обмеження"
    5: platform.aiOrchestrator.safetyGuardrails -> platform.aiOrchestrator.modelRouter "Дозволяє мінімізований запит"
    6: platform.aiOrchestrator.ragRetriever -> platform.aiOrchestrator.modelRouter "Передає дозволений контекст"
    7: platform.aiOrchestrator.modelRouter -> externalAIModels "Викликає обрану локальну або зовнішню модель"
    8: platform.aiOrchestrator.modelRouter -> platform.aiOrchestrator.outputValidator "Передає відповідь на перевірку контракту"
    9: platform.aiOrchestrator.outputValidator -> platform.aiOrchestrator.safetyGuardrails "Виконує післягенераційний контроль"
    10: platform.aiOrchestrator.safetyGuardrails -> platform.aiOrchestrator.responseComposer "Передає лише дозволений зміст"
    11: platform.aiOrchestrator.responseComposer -> platform.aiOrchestrator.humanControl "Маркує клінічно значущий проєкт"
    12: platform.aiOrchestrator.humanControl -> platform.auditService "Фіксує модель, шаблон, джерела й режим контролю"
    autoLayout lr 300 220
}

dynamic platform "DYN-08-ClinicianReviewTrajectory" "Огляд медичним працівником, пояснення, коригування та підтвердження траєкторії." {
    title "DYN.08 — Клінічний перегляд і траєкторія пацієнта"
    1: psychiatrist -> platform.clinicianApp "Відкриває випадок і часову шкалу"
    2: platform.clinicianApp -> platform.apiGateway "Запитує результати, прапорці та джерела"
    3: platform.apiGateway -> platform.clinicalDecisionSupport "Отримує проєкт узагальнення та пояснення"
    4: platform.clinicalDecisionSupport -> protocolRepository "Перевіряє релевантні протоколи"
    5: platform.clinicalDecisionSupport -> platform.clinicalRepository "Зберігає коригування та підтверджене рішення"
    6: platform.clinicalDecisionSupport -> platform.schedulerService "Створює погоджені контрольні точки"
    7: platform.clinicalDecisionSupport -> platform.auditService "Фіксує фахівця, обґрунтування й версію джерел"
    autoLayout lr 300 220
}

dynamic platform "DYN-09-VisitPreparationRouting" "Підготовка пацієнта до візиту та маршрутизація до відповідного фахівця." {
    title "DYN.09 — Підготовка до візиту та маршрутизація"
    1: patient -> platform.patientApp "Запитує підготовку до консультації"
    2: platform.patientApp -> platform.apiGateway "Передає запит із дозволеним контекстом"
    3: platform.apiGateway -> platform.interactionOrchestrator "Формує зрозумілий підсумок і перелік питань"
    4: platform.apiGateway -> platform.clinicalDecisionSupport "Визначає допустимі варіанти маршруту"
    5: platform.clinicalDecisionSupport -> platform.schedulerService "Передає роль фахівця, пріоритет і часові межі"
    6: platform.schedulerService -> platform.integrationGateway "Запитує доступний слот або телемедичний сеанс"
    7: platform.integrationGateway -> calendarProvider "Створює або резервує подію"
    8: platform.integrationGateway -> telemedicinePlatform "За потреби створює захищений дистанційний сеанс"
    autoLayout lr 300 220
}

dynamic platform "DYN-10-FollowUpReminders" "Плановий супровід, повторні опитування, вимірювання й контроль прострочених дій." {
    title "DYN.10 — Повторний супровід і нагадування"
    1: platform.scenarioEngine -> platform.schedulerService "Створює повторне опитування або вимірювання"
    2: platform.schedulerService -> platform.integrationGateway "Передає нагадування дозволеним каналом"
    3: platform.integrationGateway -> notificationProvider "Надсилає мінімізоване повідомлення"
    4: platform.integrationGateway -> calendarProvider "Оновлює календарну подію"
    5: patient -> platform.patientApp "Повертається до запланованого завдання"
    6: platform.patientApp -> platform.apiGateway "Підтверджує виконання або повідомляє причину пропуску"
    7: platform.apiGateway -> platform.schedulerService "Оновлює статус завдання"
    8: platform.schedulerService -> platform.eventBus "Публікує виконання або прострочення"
    9: platform.eventBus -> platform.auditService "Фіксує подію й резервний маршрут"
    autoLayout lr 300 220
}

dynamic platform.algorithmStudio "DYN-11-AlgorithmPublishing" "Перетворення вихідного документа на перевірену, погоджену та опубліковану версію алгоритму." {
    title "DYN.11 — Формалізація, тестування та публікація алгоритму"
    1: methodologist -> platform.algorithmStudio.sourceImporter "Ініціює імпорт документа або створення чернетки"
    2: platform.algorithmStudio.sourceImporter -> algorithmSourceRepository "Отримує вихідний документ і метадані"
    3: platform.algorithmStudio.sourceImporter -> platform.algorithmStudio.definitionEditor "Створює структуровану чернетку"
    4: platform.algorithmStudio.definitionEditor -> platform.algorithmStudio.clinicalValidator "Передає правила, кроки та метадані на перевірку"
    5: platform.algorithmStudio.clinicalValidator -> platform.algorithmStudio.testRunner "Допускає валідну версію до симуляції"
    6: platform.algorithmStudio.testRunner -> platform.algorithmStudio.approvalWorkflow "Передає протокол тестів і відхилення"
    7: platform.algorithmStudio.approvalWorkflow -> platform.algorithmStudio.versionManager "Фіксує погоджену редакцію"
    8: platform.algorithmStudio.versionManager -> platform.algorithmStudio.publisher "Створює незмінний кандидат на випуск"
    9: platform.algorithmStudio.publisher -> platform.algorithmRegistry "Атомарно публікує підписану версію"
    10: platform.algorithmStudio.publisher -> platform.auditService "Фіксує авторів, погодження, контрольну суму та дату чинності"
    autoLayout lr 300 220
}

dynamic platform.integrationGateway "DYN-12-FhirEhrSync" "Контрольований обмін структурованими клінічними даними з МІС/EHR." {
    title "DYN.12 — Обмін із МІС / EHR через FHIR"
    1: platform.apiGateway -> platform.integrationGateway.fhirApi "Передає авторизовану команду обміну"
    2: platform.integrationGateway.fhirApi -> platform.integrationGateway.terminologyAdapter "Перевіряє коди й версії словників"
    3: platform.integrationGateway.terminologyAdapter -> terminologySystem "Валідує або відображає код"
    4: platform.integrationGateway.fhirApi -> platform.integrationGateway.consentPolicyEnforcer "Перевіряє мету, обсяг і чинну згоду"
    5: platform.integrationGateway.consentPolicyEnforcer -> platform.integrationGateway.ehrConnector "Дозволяє мінімізований обмін"
    6: platform.integrationGateway.ehrConnector -> ehrSystem "Надсилає або отримує профільовані ресурси"
    autoLayout lr 300 220
}

dynamic platform "DYN-13-PauseResume" "Безпечне призупинення та відновлення незавершеної сесії без втрати версії алгоритму й контексту." {
    title "DYN.13 — Призупинення та відновлення сесії"
    1: patient -> platform.patientApp "Просить зберегти прогрес або втрачає з'єднання"
    2: platform.patientApp -> platform.apiGateway "Передає останній підтверджений стан"
    3: platform.apiGateway -> platform.interactionOrchestrator "Позначає сесію як призупинену"
    4: platform.interactionOrchestrator -> platform.operationalDb "Фіксує поточний крок і закріплену версію алгоритму"
    5: platform.interactionOrchestrator -> platform.schedulerService "Створює ненав'язливе нагадування"
    6: platform.schedulerService -> platform.integrationGateway "Передає нагадування"
    7: platform.integrationGateway -> notificationProvider "Надсилає мінімізоване повідомлення"
    8: patient -> platform.patientApp "Повертається до сесії"
    9: platform.patientApp -> platform.apiGateway "Запитує відновлення"
    10: platform.apiGateway -> platform.interactionOrchestrator "Відновлює стан після повторної перевірки доступу"
    11: platform.interactionOrchestrator -> platform.cache "Відновлює короткоживучий контекст і блокування"
    12: platform.interactionOrchestrator -> platform.scenarioEngine "Продовжує з чинного кроку тієї самої версії"
    autoLayout lr 300 220
}
