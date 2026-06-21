workspace "Платформа психіатричних сценаріїв та алгоритмів" "Повна C4-модель універсальної програмної платформи для формалізації, виконання та клінічного контролю сценаріїв у сфері психіатрії." {
    !identifiers hierarchical
    !impliedRelationships false

    model {
        # BEGIN INCLUDE: 01-actors-and-external-systems.dsl
        # Люди, ролі та зовнішні системи

        group "Користувачі та клінічні ролі" {
            patient = person "Пацієнт" "Надає скарги й відповіді, проходить опитування та вимірювання, отримує супровід і рекомендацію щодо звернення до фахівця." "Patient"
            psychiatrist = person "Лікар-психіатр" "Оцінює ризики, підтверджує клінічні висновки, коригує траєкторію та ухвалює рішення щодо втручань." "Clinician,Psychiatrist"
            psychologist = person "Психолог / психотерапевт" "Проводить психологічну оцінку, переглядає результати скринінгу та планує супровід." "Clinician,Psychologist"
            nurse = person "Медична сестра / координатор" "Організовує вимірювання, нагадування, повторні контакти та маршрутизацію." "Clinician,Coordinator"
            cardiologist = person "Кардіолог" "Оцінює серцево-судинні ризики, ЕКГ та інші біосигнали у зв'язку з психічним станом і лікуванням." "Clinician,ConsultingPhysician"
            rehabilitationSpecialist = person "Реабілітолог" "Оцінює функціонування, визначає реабілітаційні потреби та контролює результати відновлення." "Clinician,ConsultingPhysician"
            neurologist = person "Невролог" "Оцінює неврологічні та когнітивні симптоми, коморбідність і потребу в додатковому обстеженні." "Clinician,ConsultingPhysician"
            pediatrician = person "Педіатр" "Оцінює вікові особливості стану дітей і підлітків та координує відповідну маршрутизацію." "Clinician,ConsultingPhysician"
            crisisSpecialist = person "Черговий кризовий фахівець" "Приймає ескалації, перевіряє невідкладний ризик і координує кризове реагування." "Clinician,CrisisRole"
            methodologist = person "Клінічний методолог" "Формалізує, тестує, погоджує та публікує версії алгоритмів, опитувальників і протоколів." "Methodologist"
            researcher = person "Аналітик / дослідник" "Працює лише з дозволеними знеособленими даними та агрегованими показниками." "Researcher"
            securityOfficer = person "Адміністратор платформи та безпеки" "Керує конфігурацією, доступом, аудитом, спостережуваністю та реагуванням на інциденти." "Administrator"
        }

        group "Зовнішня клінічна та цифрова екосистема" {
            identityProvider = softwareSystem "Постачальник електронної ідентичності" "OIDC/OAuth 2.0, багатофакторна автентифікація та федерація ідентичностей." "ExternalSystem,IdentitySystem"
            ehrSystem = softwareSystem "МІС / EHR / ЕСОЗ" "Зовнішня медична інформаційна система для обміну направленнями, спостереженнями, анкетами, планами та висновками." "ExternalSystem,ClinicalSystem"
            terminologySystem = softwareSystem "Сервіс термінологій" "Клінічні словники, класифікатори та відповідності кодів для нормалізації даних." "ExternalSystem,KnowledgeSystem"
            protocolRepository = softwareSystem "Репозиторій клінічних протоколів і знань" "Затверджені протоколи, настанови, локальні маршрути та клінічні джерела." "ExternalSystem,KnowledgeSystem"
            algorithmSourceRepository = softwareSystem "Репозиторій вихідних алгоритмів" "Google Drive / Git як проєктне джерело документів команди психіатрії до формалізації та клінічного погодження." "ExternalSystem,DesignTimeSystem"
            notificationProvider = softwareSystem "Провайдер повідомлень" "SMS, електронна пошта, push-повідомлення та службові канали оповіщення." "ExternalSystem,CommunicationSystem"
            calendarProvider = softwareSystem "Календар і запис на прийом" "Слоти фахівців, планові події, нагадування та підтвердження візитів." "ExternalSystem,CommunicationSystem"
            telemedicinePlatform = softwareSystem "Платформа телемедицини" "Захищені відео- й аудіоконсультації, сеанси з аватаром або іншим інтерфейсом присутності." "ExternalSystem,CommunicationSystem"
            emergencySystem = softwareSystem "Кризова / екстрена служба" "Організаційний контур для термінового контакту, кризової бригади або екстреної допомоги." "ExternalSystem,CrisisSystem"
            deviceEcosystem = softwareSystem "Медичні пристрої та сенсори" "ЕКГ, носимі пристрої, мікрофон, камера та інші джерела теледіагностичних сигналів." "ExternalSystem,DeviceSystem"
            pacsSystem = softwareSystem "PACS / DICOM-сховище" "Зовнішні медичні зображення й результати візуалізаційних досліджень." "ExternalSystem,ClinicalSystem"
            externalAIModels = softwareSystem "Реєстр і середовище моделей ШІ" "Локальні або зовнішні мовні, мовленнєві, комп'ютерного зору та сигнальні моделі з контрольованим маршрутизуванням." "ExternalSystem,AISystem"
        }
        # END INCLUDE: 01-actors-and-external-systems.dsl
        # BEGIN INCLUDE: 02-platform.dsl
        # Основна програмна система та її контейнери

        platform = softwareSystem "Платформа реалізації психіатричних сценаріїв та алгоритмів" "Керована клінічна платформа для універсального виконання опитувальників, інтерв'ю, вимірювань, правил ризику, супроводу та підтримки рішень." "PlatformSystem" {
            # BEGIN INCLUDE: 01-patient-app.dsl
            patientApp = container "Застосунок пацієнта" "Мобільний або вебзастосунок для діалогу, опитувань, вимірювань, нагадувань і підготовки до візиту." "PWA / mobile / web, WebRTC, Web Speech APIs" "PatientUI" {
                appShell = component "Оболонка та навігація" "Керує екранами, локальним станом, доступністю та безпечним відновленням перерваної сесії." "Frontend framework" "UIComponent"
                accessibilityModule = component "Модуль доступності" "Масштабування, контрастність, прості формулювання, субтитри та альтернативні способи введення." "WCAG-oriented UI" "UIComponent,Accessibility"
                communicationPreferences = component "Налаштування комунікації" "Дозволяє пацієнту обрати канал, тембр, швидкість, ступінь формальності й інші допустимі параметри." "Frontend module" "UIComponent"
                complaintIntake = component "Збір скарг і потреб" "Підтримує структуроване та вільне введення скарг, потреб, контексту й мети звернення." "Form and dialogue UI" "UIComponent,ClinicalInput"
                questionnaireRenderer = component "Візуалізатор опитувальників" "Відтворює версійовані кроки алгоритму, варіанти відповіді, пояснення та правила обов'язковості." "Schema-driven forms" "UIComponent,ClinicalInput"
                mediaCapture = component "Захоплення голосу та відео" "Отримує окрему згоду, контролює запис і передає медіадані лише для дозволених завдань." "WebRTC / Media APIs" "UIComponent,Media"
                measurementWizard = component "Майстер вимірювань" "Покроково супроводжує підключення пристрою, перевірку якості, повтор вимірювання та передачу результату." "Device integration UI" "UIComponent,Measurement"
                calendarUi = component "Календар і нагадування" "Показує заплановані вимірювання, опитування, візити та підтвердження виконання." "Calendar UI" "UIComponent"
                visitPreparation = component "Підготовка до візиту" "Формує для пацієнта стислий перелік тем, запитань і даних, які доцільно обговорити з фахівцем." "Frontend module" "UIComponent"
                crisisControl = component "Елемент кризової допомоги" "Постійно доступний, не залежить від генеративної моделі та запускає перевірений кризовий маршрут." "Fail-safe UI" "UIComponent,SafetyCritical"
            }
            # END INCLUDE: 01-patient-app.dsl
            # BEGIN INCLUDE: 02-clinician-app.dsl
            clinicianApp = container "Кабінет медичного працівника" "Єдиний клінічний інтерфейс для перегляду часової шкали, балів, червоних прапорців, вимірювань і проєкту траєкторії пацієнта." "Web application" "ClinicianUI" {
                patientTimeline = component "Часова шкала пацієнта" "Об'єднує скарги, відповіді, результати вимірювань, завдання, контакти та клінічні рішення з походженням даних." "Web UI" "UIComponent"
                assessmentWorkspace = component "Робоча область оцінювання" "Дає змогу продовжити структуроване інтерв'ю, додати огляд психічного статусу та уточнити контекст." "Web UI" "UIComponent,ClinicalInput"
                resultReview = component "Перегляд результатів" "Показує обчислені бали, категорії, правила, які спрацювали, версію алгоритму та межі інтерпретації." "Web UI" "UIComponent,Explainability"
                redFlagPanel = component "Панель червоних прапорців" "Пріоритезує ризики, ескалації, прострочені дії та підтвердження кризового реагування." "Web UI" "UIComponent,SafetyCritical"
                protocolPanel = component "Панель протоколів" "Показує релевантні протоколи й джерела з поясненням відповідності та датою версії." "Web UI" "UIComponent,Explainability"
                trajectoryEditor = component "Редактор траєкторії" "Дозволяє лікарю змінити, погодити або відхилити запропонований план подальших дій." "Web UI" "UIComponent,HumanApproval"
                teleconsultationUi = component "Телемедична консультація" "Запускає захищений текстовий, голосовий або відеосеанс із пацієнтом." "WebRTC client" "UIComponent,Media"
                approvalUi = component "Підпис і клінічне підтвердження" "Фіксує відповідального фахівця, рішення, причину відхилення й електронне підтвердження." "Web UI" "UIComponent,HumanApproval"
            }
            # END INCLUDE: 02-clinician-app.dsl
            # BEGIN INCLUDE: 03-algorithm-studio.dsl
            algorithmStudio = container "Студія алгоритмів і протоколів" "Проєктний інтерфейс для перетворення документів команди на формальні, тестовані й версійовані визначення алгоритмів." "Web application" "AdminUI" {
                sourceImporter = component "Імпортер вихідних матеріалів" "Завантажує документи з Google Drive або Git, зберігає посилання на джерело та створює чернетку без автоматичної публікації." "Document import" "StudioComponent"
                definitionEditor = component "Редактор визначення алгоритму" "Редагує метадані, кроки, питання, переходи, оцінювання, червоні прапорці, вимірювання, результати й маршрути." "Schema-driven editor" "StudioComponent"
                clinicalValidator = component "Клінічний і технічний валідатор" "Перевіряє повноту, типи даних, досяжність станів, конфлікти правил, обов'язкові джерела та заборонені конструкції." "Rules and schema validation" "StudioComponent,SafetyCritical"
                testRunner = component "Симулятор і тестові набори" "Виконує позитивні, граничні, кризові та регресійні сценарії до погодження версії." "Test harness" "StudioComponent"
                approvalWorkflow = component "Маршрут клінічного погодження" "Організовує незалежний перегляд, зауваження, повторне тестування та рішення уповноважених осіб." "Workflow engine" "StudioComponent,HumanApproval"
                versionManager = component "Керування версіями" "Формує незмінний номер версії, журнал змін, дату чинності, сумісність і статус життєвого циклу." "Version control" "StudioComponent"
                publisher = component "Публікатор і відкликання" "Атомарно публікує погоджену версію до реєстру, підтримує canary-впровадження та контрольоване відкликання." "Release service" "StudioComponent,SafetyCritical"
            }
            # END INCLUDE: 03-algorithm-studio.dsl
            # BEGIN INCLUDE: 04-api-and-identity.dsl
            apiGateway = container "API-шлюз і BFF" "Єдина контрольована точка входу для клієнтських застосунків, перевірки схем, обмеження запитів і маршрутизації." "Reverse proxy / API gateway" "Gateway,Security" {
                authMiddleware = component "Перевірка автентифікації" "Перевіряє токени, контекст сесії та допустимий клієнт." "OIDC middleware" "GatewayComponent,Security"
                rateLimiter = component "Обмеження навантаження" "Захищає клінічні та ШІ-сервіси від перевантаження й автоматизованого зловживання." "Rate limiting" "GatewayComponent,Security"
                apiRouter = component "Маршрутизатор API" "Спрямовує запит до відповідного доменного сервісу та додає кореляційний ідентифікатор." "API routing" "GatewayComponent"
                schemaFirewall = component "Контроль контрактів" "Відхиляє невалідні або надмірні поля, нормалізує версію API й обмежує розмір медіа." "OpenAPI / JSON Schema" "GatewayComponent,Security"
            }

            identityConsentService = container "Сервіс ідентичності, доступу та згод" "Керує ролями, атрибутами, делегуванням, клінічними згодами й короткоживучими сесіями." "OIDC, RBAC/ABAC, consent service" "SecurityService" {
                oidcAdapter = component "Адаптер OIDC" "Федерація з зовнішнім постачальником ідентичності та перевірка рівня автентифікації." "OIDC/OAuth 2.0" "SecurityComponent"
                rbacAbac = component "Авторизація RBAC/ABAC" "Поєднує роль, заклад, відношення до пацієнта, мету доступу та чутливість ресурсу." "Policy engine" "SecurityComponent"
                consentManager = component "Менеджер згод" "Фіксує мету, обсяг, строк, відкликання та окрему згоду на голос, відео, сенсори й дослідження." "Consent management" "SecurityComponent,ClinicalSafety"
                sessionTokenService = component "Сервіс сесійних токенів" "Видає короткоживучі токени з мінімальними правами й підтримує негайне відкликання." "Token service" "SecurityComponent"
            }
            # END INCLUDE: 04-api-and-identity.dsl
            # BEGIN INCLUDE: 05-interaction-orchestrator.dsl
            interactionOrchestrator = container "Оркестратор взаємодії" "Керує діалоговою сесією, контекстом, каналом комунікації та координацією детермінованого сценарію з допоміжними ШІ-функціями." "Application service" "CoreService" {
                sessionManager = component "Менеджер сесії" "Створює, відновлює, призупиняє та завершує сесію з фіксацією активної версії алгоритму." "Stateful service" "CoreComponent"
                dialogueState = component "Стан діалогу" "Зберігає лише дозволений мінімальний контекст, поточний крок, очікуваний тип відповіді та незавершені дії." "State machine adapter" "CoreComponent"
                contextAssembler = component "Формувач контексту" "Збирає потрібні для кроку дані з клінічного сховища, згод, результатів і профілю комунікації." "Context service" "CoreComponent,Privacy"
                channelRouter = component "Маршрутизатор каналів" "Уніфікує текст, голос, відео, аватар, VR та перетворення голосу на текст без зміни клінічної логіки." "Channel adapters" "CoreComponent,Media"
                styleSelector = component "Селектор стилю комунікації" "Застосовує явний вибір пацієнта або дозволені правила на основі скарг, відповідей і теледіагностичних показників." "Policy service" "CoreComponent"
                responseCoordinator = component "Координатор відповіді" "Поєднує наступний детермінований крок, пояснення, допоміжний текст ШІ та контроль безпеки." "Application service" "CoreComponent,SafetyCritical"
            }
            # END INCLUDE: 05-interaction-orchestrator.dsl
            # BEGIN INCLUDE: 06-scenario-engine.dsl
            scenarioEngine = container "Детермінований рушій сценаріїв" "Виконує формальні версійовані алгоритми, розгалуження, оцінювання та червоні прапорці незалежно від генеративної моделі." "Rules engine / finite-state machine" "CoreClinicalService,SafetyCritical" {
                definitionLoader = component "Завантажувач визначення" "Отримує опубліковану версію алгоритму та закріплює її за сесією до завершення або контрольованої міграції." "Registry client" "ClinicalComponent"
                schemaValidator = component "Валідатор визначення" "Повторно перевіряє підпис, схему, сумісність і статус версії перед виконанням." "JSON Schema validation" "ClinicalComponent,SafetyCritical"
                stateMachine = component "Інтерпретатор станів" "Виконує універсальний життєвий цикл: ініціація, збір, перевірка, пауза, ескалація, завершення." "Finite-state machine" "ClinicalComponent,SafetyCritical"
                stepSelector = component "Селектор наступного кроку" "Обирає наступне питання, завдання, вимірювання або завершальний результат за формальними правилами." "Rules engine" "ClinicalComponent"
                branchingEvaluator = component "Оцінювач переходів" "Визначає розгалуження лише за типізованими відповідями й контекстними умовами." "Expression engine" "ClinicalComponent,SafetyCritical"
                answerValidator = component "Валідатор відповіді" "Перевіряє тип, діапазон, повноту, часову мітку, одиниці та допустимість пропуску." "Validation service" "ClinicalComponent"
                scoringCalculator = component "Калькулятор балів" "Відтворювано обчислює підшкали, сумарні бали, пороги й категорії без участі LLM." "Deterministic calculator" "ClinicalComponent,SafetyCritical"
                redFlagEvaluator = component "Оцінювач червоних прапорців" "Запускається після кожного релевантного введення та формує пріоритетну ескалацію з поясненням правила." "Rules engine" "ClinicalComponent,SafetyCritical"
                outcomeMapper = component "Формувач результату" "Перетворює валідовані бали, ознаки й умови на структурований результат та варіанти маршруту." "Mapping service" "ClinicalComponent"
                provenanceRecorder = component "Фіксація походження" "Зберігає версію визначення, введення, правило, обчислення, час і суб'єкта виконання." "Provenance service" "ClinicalComponent,Audit"
            }
            # END INCLUDE: 06-scenario-engine.dsl
            # BEGIN INCLUDE: 07-clinical-decision-support.dsl
            clinicalDecisionSupport = container "Сервіс підтримки клінічних рішень" "Нормалізує результати, агрегує ризики, підбирає протоколи та формує проєкт траєкторії для обов'язкового перегляду фахівцем." "Clinical decision support service" "CoreClinicalService,HumanApproval" {
                dataNormalizer = component "Нормалізатор клінічних даних" "Узгоджує одиниці, коди, часові інтервали, походження та якість даних." "Clinical data pipeline" "CDSComponent"
                riskAggregator = component "Агрегатор ризиків" "Поєднує результати кількох алгоритмів і вимірювань за затвердженою політикою, не приховуючи первинні ознаки." "Deterministic rules" "CDSComponent,SafetyCritical"
                protocolMatcher = component "Підбір протоколів" "Зіставляє структуровані ознаки з чинними протоколами та повертає джерела й умови відповідності." "Rules plus retrieval" "CDSComponent,Explainability"
                trajectoryPlanner = component "Планувальник траєкторії" "Формує проєкт послідовності дій, фахівців, строків, повторних оцінювань і вимірювань." "Care pathway service" "CDSComponent,HumanApproval"
                followUpPlanner = component "Планувальник супроводу" "Готує частоту нагадувань, контрольні точки, критерії повторного контакту та ескалації." "Scheduling policy" "CDSComponent"
                explanationBuilder = component "Формувач пояснення" "Показує, які вхідні дані, правила та версії спричинили рекомендацію; відокремлює факт від припущення." "Explainability service" "CDSComponent,Explainability"
                clinicalReviewGate = component "Шлюз клінічного підтвердження" "Не дозволяє перетворити проєкт ШІ або CDS на клінічне рішення без уповноваженого фахівця, крім наперед визначених безпечних дій." "Approval workflow" "CDSComponent,HumanApproval,SafetyCritical"
            }
            # END INCLUDE: 07-clinical-decision-support.dsl
            # BEGIN INCLUDE: 08-ai-orchestrator.dsl
            aiOrchestrator = container "Оркестратор ШІ та контроль безпеки" "Надає допоміжне розпізнавання, структурування, пошук і формування тексту; не виконує клінічне оцінювання, пороги або кризову маршрутизацію." "AI gateway / model orchestration" "AIService,SafetyCritical" {
                structuredExtractor = component "Структурований екстрактор" "Перетворює вільний текст або транскрипт на проєкт типізованих полів із доказовими фрагментами та невизначеністю." "LLM/NLP" "AIComponent"
                promptManager = component "Менеджер шаблонів і політик" "Зберігає версійовані системні інструкції, дозволені функції, локаль і клінічні обмеження." "Prompt registry" "AIComponent,Governance"
                ragRetriever = component "Пошук у базі знань" "Повертає дозволені фрагменти протоколів і довідок з ідентифікатором джерела та версією." "RAG / vector search" "AIComponent"
                modelRouter = component "Маршрутизатор моделей" "Обирає локальну або зовнішню модель за типом даних, чутливістю, доступністю, вартістю й дозволеною юрисдикцією." "Model gateway" "AIComponent,Security"
                safetyGuardrails = component "Клінічні та контентні запобіжники" "Блокує самовільне діагностування, призначення, приховування ризику, небезпечні інструкції та витік персональних даних." "Policy and classifiers" "AIComponent,SafetyCritical"
                outputValidator = component "Валідатор структурованого виходу" "Перевіряє JSON-схему, допустимі посилання, узгодженість із детермінованим кроком і заборонені твердження." "Schema and policy validation" "AIComponent,SafetyCritical"
                responseComposer = component "Компонувальник відповіді" "Створює доступну репліку з чітким відокремленням інформації, запитання та кризової інструкції." "NLG service" "AIComponent"
                humanControl = component "Контроль людиною" "Маркує матеріали, що потребують перегляду, та блокує автоматичне надсилання клінічно значущих проєктів." "Human-in-the-loop" "AIComponent,HumanApproval"
            }
            # END INCLUDE: 08-ai-orchestrator.dsl
            # BEGIN INCLUDE: 09-measurement-service.dsl
            measurementService = container "Сервіс мультимодальних вимірювань" "Приймає сигнали та медіа, перевіряє технічну якість, запускає спеціалізований аналіз і повертає нормалізований результат із невизначеністю." "Signal and media processing" "MeasurementService,SafetyCritical" {
                deviceGateway = component "Шлюз пристроїв" "Приймає стандартизовані або адаптерні потоки від ЕКГ, сенсорів, мікрофона та камери." "Device adapters" "MeasurementComponent"
                qualityAssessor = component "Контроль якості" "Перевіряє артефакти, тривалість, частоту дискретизації, повноту кадру, шум і придатність до аналізу." "Quality rules" "MeasurementComponent,SafetyCritical"
                signalPreprocessor = component "Попереднє оброблення сигналів" "Виконує дозволені фільтри, сегментацію, синхронізацію та зберігає параметри перетворення." "DSP pipeline" "MeasurementComponent"
                ecgMinnesotaAnalyzer = component "Аналізатор ЕКГ / Мінесотське кодування" "Формує машинний проєкт кодів і ознак ЕКГ для перевірки медичним працівником." "ECG analysis" "MeasurementComponent,ClinicalAI"
                voiceAnalyzer = component "Аналізатор голосу" "Обчислює дозволені акустичні й мовленнєві характеристики з контролем якості та контексту." "Audio ML" "MeasurementComponent,ClinicalAI"
                videoAnalyzer = component "Аналізатор відео" "Виділяє наперед визначені невербальні або моторні ознаки без ідентифікації особи за обличчям." "Computer vision" "MeasurementComponent,ClinicalAI"
                imageAnalyzer = component "Аналізатор медичних зображень" "Запускає валідований спеціалізований алгоритм для підтримуваного типу зображення." "Medical imaging AI" "MeasurementComponent,ClinicalAI"
                featureFusion = component "Об'єднання ознак" "Поєднує лише сумісні часові й модальні ознаки за затвердженою моделлю та зберігає внесок кожного джерела." "Multimodal fusion" "MeasurementComponent,SafetyCritical"
                measurementNormalizer = component "Нормалізатор результату" "Повертає кодовані показники, якість, версію моделі, інтервал невизначеності та посилання на сирі дані." "Clinical mapping" "MeasurementComponent"
            }
            # END INCLUDE: 09-measurement-service.dsl
            # BEGIN INCLUDE: 10-scheduler-and-integration.dsl
            schedulerService = container "Сервіс завдань, нагадувань і ескалацій" "Планує повторні опитування, вимірювання, візити, нагадування та контроль невиконаних критичних дій." "Workflow scheduler" "WorkflowService" {
                taskPlanner = component "Планувальник завдань" "Створює версійовані завдання з вікном виконання, відповідальним і критеріями завершення." "Workflow engine" "WorkflowComponent"
                reminderDispatcher = component "Диспетчер нагадувань" "Обирає дозволений канал, дотримується тихих годин і мінімізує розкриття чутливого змісту." "Notification service" "WorkflowComponent,Privacy"
                escalationScheduler = component "Контроль ескалацій" "Перевіряє строки реакції, підтвердження отримання та запускає резервний маршрут." "Escalation engine" "WorkflowComponent,SafetyCritical"
                retryManager = component "Керування повторними спробами" "Забезпечує ідемпотентність, обмежені повтори та чергу помилок без дублювання клінічної дії." "Reliable job processing" "WorkflowComponent"
            }

            integrationGateway = container "Інтеграційний шлюз" "Ізолює внутрішню модель від зовнішніх МІС, термінологій, PACS, календарів, повідомлень і телемедицини." "FHIR/DICOM/REST integration service" "IntegrationService" {
                fhirApi = component "FHIR API та мапінг" "Перетворює внутрішні дані на профільовані ресурси й навпаки з валідацією профілю." "HL7 FHIR" "IntegrationComponent"
                ehrConnector = component "Конектор МІС / EHR" "Підтримує ідемпотентний обмін, журнал помилок, повтори та узгодження ідентифікаторів." "FHIR/REST connector" "IntegrationComponent"
                terminologyAdapter = component "Адаптер термінологій" "Перевіряє коди, виконує дозволені відображення та фіксує версію словника." "Terminology API" "IntegrationComponent"
                dicomConnector = component "Конектор PACS / DICOM" "Отримує та публікує підтримувані зображення й метадані через контрольований шлюз." "DICOMweb" "IntegrationComponent"
                notificationAdapter = component "Адаптер повідомлень" "Передає мінімально необхідний зміст провайдеру повідомлень і контролює статус доставки." "SMS/e-mail/push API" "IntegrationComponent"
                calendarAdapter = component "Адаптер календаря" "Синхронізує слоти, події, зміни та скасування без розкриття зайвих клінічних даних." "Calendar API" "IntegrationComponent"
                telemedicineAdapter = component "Адаптер телемедицини" "Створює захищені сеанси й короткоживучі токени приєднання." "WebRTC platform API" "IntegrationComponent"
                consentPolicyEnforcer = component "Контроль політики згод" "Перевіряє мету й обсяг перед кожним зовнішнім передаванням." "Policy enforcement" "IntegrationComponent,Security"
                pseudonymizer = component "Псевдонімізація для аналітики" "Відокремлює прямі ідентифікатори, застосовує політику набору даних і запобігає повторній ідентифікації." "Privacy service" "IntegrationComponent,Privacy"
            }
            # END INCLUDE: 10-scheduler-and-integration.dsl
            # BEGIN INCLUDE: 11-audit-and-data.dsl
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
            # END INCLUDE: 11-audit-and-data.dsl
        }
        # END INCLUDE: 02-platform.dsl
        # BEGIN INCLUDE: 03-code-elements.dsl
        # Логічні контракти рівня коду/даних для спеціалізованих custom views

        # "Контракт визначення алгоритму"
            codeAlgorithmDefinition = element "AlgorithmDefinition" {
                description "Кореневий незмінний документ алгоритму з ідентифікатором, версією, локаллю, призначенням і відповідальним власником."
                tags "CodeElement,AggregateRoot"
            }
            codeEligibility = element "EligibilityPolicy" {
                description "Критерії включення, виключення, віку, ролі та контексту використання."
                tags "CodeElement,Policy"
            }
            codeConsent = element "ConsentRequirement" {
                description "Вимоги до інформування й окремих згод для каналу, медіа, сенсорів і вторинного використання."
                tags "CodeElement,Policy"
            }
            codeStep = element "ScenarioStep" {
                description "Типізований крок: інформація, питання, завдання, вимірювання, очікування, перегляд або завершення."
                tags "CodeElement,Entity"
            }
            codeQuestion = element "QuestionDefinition" {
                description "Текст, тип відповіді, варіанти, діапазон, обов'язковість і період оцінювання."
                tags "CodeElement,ValueObject"
            }
            codeBranchRule = element "BranchRule" {
                description "Безпечний вираз умови та цільовий крок із пріоритетом і поведінкою за замовчуванням."
                tags "CodeElement,Rule"
            }
            codeScoringRule = element "ScoringRule" {
                description "Детермінована формула підшкали, суми, порогу або категорії."
                tags "CodeElement,Rule,SafetyCritical"
            }
            codeRedFlagRule = element "RedFlagRule" {
                description "Умова, рівень критичності, повідомлення, ціль ескалації та максимальний строк реакції."
                tags "CodeElement,Rule,SafetyCritical"
            }
            codeMeasurement = element "MeasurementDefinition" {
                description "Тип сигналу, протокол збору, вимоги якості, аналізатор, одиниці та політика повтору."
                tags "CodeElement,Entity"
            }
            codeOutcome = element "OutcomeDefinition" {
                description "Структурований результат, межі інтерпретації та відображення на категорії ризику."
                tags "CodeElement,Entity"
            }
            codeRouting = element "RoutingPolicy" {
                description "Маршрут до ролі, сервісу або типу допомоги з умовою, пріоритетом і резервною дією."
                tags "CodeElement,Policy,SafetyCritical"
            }
            codeFollowUp = element "FollowUpPolicy" {
                description "Інтервали повторної оцінки, завдання, нагадування та критерії дострокового контакту."
                tags "CodeElement,Policy"
            }
            codeCommunication = element "CommunicationPolicy" {
                description "Дозволені канали, стиль, доступність, темп і правила адаптації без зміни клінічного змісту."
                tags "CodeElement,Policy"
            }
            codeDataPolicy = element "DataPolicy" {
                description "Мета, мінімальний набір, місце оброблення, строки зберігання, доступ і правила експорту."
                tags "CodeElement,Policy,Privacy"
            }
            codeTestCase = element "AlgorithmTestCase" {
                description "Вхідний контекст, послідовність відповідей, очікувані кроки, бали, прапорці та результат."
                tags "CodeElement,TestArtifact"
            }

        codeAlgorithmDefinition -> codeEligibility "Містить"
        codeAlgorithmDefinition -> codeConsent "Містить"
        codeAlgorithmDefinition -> codeStep "Містить упорядкований граф"
        codeAlgorithmDefinition -> codeScoringRule "Містить"
        codeAlgorithmDefinition -> codeRedFlagRule "Містить"
        codeAlgorithmDefinition -> codeMeasurement "Містить"
        codeAlgorithmDefinition -> codeOutcome "Містить"
        codeAlgorithmDefinition -> codeRouting "Містить"
        codeAlgorithmDefinition -> codeFollowUp "Містить"
        codeAlgorithmDefinition -> codeCommunication "Містить"
        codeAlgorithmDefinition -> codeDataPolicy "Містить"
        codeAlgorithmDefinition -> codeTestCase "Перевіряється"
        codeStep -> codeQuestion "Може містити"
        codeStep -> codeBranchRule "Має переходи"
        codeBranchRule -> codeStep "Посилається на цільовий крок"
        codeScoringRule -> codeOutcome "Формує показники для"
        codeRedFlagRule -> codeRouting "Запускає"
        codeMeasurement -> codeOutcome "Додає нормалізовані ознаки до"
        codeOutcome -> codeFollowUp "Визначає"


        # "Агрегат виконання сценарію"
            codeScenarioSession = element "ScenarioSession" {
                description "Агрегат виконання, який закріплює пацієнта, алгоритм, версію, стан, поточний крок і кореляційний ідентифікатор."
                tags "CodeElement,AggregateRoot"
            }
            codePatientContext = element "PatientContext" {
                description "Мінімальний дозволений контекст, потрібний для активного алгоритму."
                tags "CodeElement,ValueObject,Privacy"
            }
            codeSessionConsent = element "ConsentSnapshot" {
                description "Незмінний знімок чинних згод на момент дії."
                tags "CodeElement,ValueObject,Privacy"
            }
            codeAnswer = element "AnswerRecord" {
                description "Типізована відповідь із джерелом, часом, автором, якістю та посиланням на крок."
                tags "CodeElement,Entity"
            }
            codeMeasurementResult = element "MeasurementResult" {
                description "Нормалізований показник, технічна якість, версія аналізатора, невизначеність і посилання на сирий об'єкт."
                tags "CodeElement,Entity"
            }
            codeScore = element "ScoreResult" {
                description "Відтворюваний бал або категорія з формулою, вхідними значеннями та версією правила."
                tags "CodeElement,ValueObject,SafetyCritical"
            }
            codeRiskFlag = element "RiskFlag" {
                description "Ознака ризику з критичністю, правилом, доказом, строком реакції та статусом підтвердження."
                tags "CodeElement,Entity,SafetyCritical"
            }
            codeDecisionDraft = element "ClinicalDecisionDraft" {
                description "Проєкт рекомендації або траєкторії, який не є підтвердженим клінічним рішенням."
                tags "CodeElement,Entity,HumanApproval"
            }
            codeClinicalDecision = element "ClinicalDecision" {
                description "Підтверджене рішення з відповідальним фахівцем, часом, обґрунтуванням і підписом."
                tags "CodeElement,Entity,HumanApproval"
            }
            codeCareTrajectory = element "CareTrajectory" {
                description "Упорядковані дії, фахівці, строки, повторні оцінювання та критерії ескалації."
                tags "CodeElement,Entity"
            }
            codeTask = element "FollowUpTask" {
                description "Завдання з адресатом, вікном виконання, каналом, критичністю та статусом."
                tags "CodeElement,Entity"
            }
            codeAuditEvent = element "AuditEvent" {
                description "Незмінна подія доступу, обчислення, публікації, перегляду, рішення або ескалації."
                tags "CodeElement,Event,Audit"
            }

        codeScenarioSession -> codeAlgorithmDefinition "Посилається на закріплену версію"
        codeScenarioSession -> codePatientContext "Містить мінімальний контекст"
        codeScenarioSession -> codeSessionConsent "Фіксує"
        codeScenarioSession -> codeAnswer "Накопичує"
        codeScenarioSession -> codeMeasurementResult "Накопичує"
        codeScenarioSession -> codeScore "Обчислює"
        codeScenarioSession -> codeRiskFlag "Формує"
        codeScenarioSession -> codeDecisionDraft "Формує проєкт"
        codeDecisionDraft -> codeClinicalDecision "Підтверджується або замінюється фахівцем"
        codeClinicalDecision -> codeCareTrajectory "Затверджує"
        codeCareTrajectory -> codeTask "Породжує"
        codeScenarioSession -> codeAuditEvent "Публікує"
        codeClinicalDecision -> codeAuditEvent "Фіксується"
        # END INCLUDE: 03-code-elements.dsl
        # BEGIN INCLUDE: 04-deployment.dsl
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
        # END INCLUDE: 04-deployment.dsl
        # BEGIN INCLUDE: 05-relationships.dsl
        # Відношення рівня системного контексту
        patient -> platform "Використовує для скринінгу, супроводу, вимірювань і підготовки до звернення"
        psychiatrist -> platform "Використовує для оцінювання ризику, підтвердження висновків і керування траєкторією"
        psychologist -> platform "Використовує для психологічного оцінювання та планування супроводу"
        nurse -> platform "Використовує для координації завдань, повторних контактів і вимірювань"
        cardiologist -> platform "Використовує для оцінювання серцево-судинних ризиків, ЕКГ і клінічної коморбідності"
        rehabilitationSpecialist -> platform "Використовує для оцінювання функціонування, планування реабілітації та моніторингу результатів"
        neurologist -> platform "Використовує для оцінювання неврологічних і когнітивних симптомів та диференційної маршрутизації"
        pediatrician -> platform "Використовує для оцінювання дітей і підлітків з урахуванням вікових особливостей"
        crisisSpecialist -> platform "Отримує та опрацьовує кризові ескалації"
        methodologist -> platform "Формалізує, тестує, погоджує та публікує алгоритми"
        researcher -> platform "Отримує лише дозволені знеособлені або агреговані дані"
        securityOfficer -> platform "Адмініструє доступ, аудит, конфігурацію та спостережуваність"

        platform -> identityProvider "Делегує автентифікацію та перевірку рівня довіри"
        platform -> ehrSystem "Обмінюється клінічними даними та результатами за контрольованими контрактами"
        platform -> terminologySystem "Перевіряє та нормалізує клінічні коди"
        platform -> protocolRepository "Отримує затверджені протоколи й джерела знань"
        platform -> algorithmSourceRepository "Імпортує вихідні документи алгоритмів у проєктному контурі"
        platform -> notificationProvider "Надсилає мінімально необхідні повідомлення"
        platform -> calendarProvider "Синхронізує події, слоти та візити"
        platform -> telemedicinePlatform "Створює захищені дистанційні консультації"
        platform -> emergencySystem "Передає підтверджені або формально визначені кризові ескалації"
        platform -> deviceEcosystem "Отримує дозволені біосигнали та теледіагностичні вимірювання"
        platform -> pacsSystem "Обмінюється підтримуваними медичними зображеннями"
        platform -> externalAIModels "Викликає дозволені моделі через контрольований ШІ-шлюз"

        # Відношення людей до контейнерів
        patient -> platform.patientApp "Працює через доступний текстовий, голосовий, відео або інший дозволений інтерфейс"
        psychiatrist -> platform.clinicianApp "Переглядає дані, пояснення, ризики та підтверджує клінічні рішення"
        psychologist -> platform.clinicianApp "Проводить оцінювання та коригує план психологічного супроводу"
        nurse -> platform.clinicianApp "Координує завдання, вимірювання, контакти й візити"
        cardiologist -> platform.clinicianApp "Переглядає ЕКГ, біосигнали, ризики та клінічну коморбідність"
        rehabilitationSpecialist -> platform.clinicianApp "Переглядає функціональний стан, цілі та динаміку реабілітації"
        neurologist -> platform.clinicianApp "Переглядає неврологічні, когнітивні та мультимодальні дані"
        pediatrician -> platform.clinicianApp "Переглядає віково-специфічні дані та рекомендації щодо маршрутизації"
        crisisSpecialist -> platform.clinicianApp "Приймає ескалацію та фіксує результат кризової дії"
        methodologist -> platform.algorithmStudio "Створює і погоджує формальні визначення алгоритмів"
        researcher -> platform.analyticsWarehouse "Аналізує дозволені знеособлені та агреговані набори"
        securityOfficer -> platform.auditService "Контролює журнали, події безпеки та технічні метрики"
        securityOfficer -> platform.algorithmStudio "Керує технічними політиками публікації та відкликання"

        # Відношення рівня контейнерів
        platform.patientApp -> platform.apiGateway "Викликає захищене пацієнтське API"
        platform.clinicianApp -> platform.apiGateway "Викликає захищене клінічне API"
        platform.algorithmStudio -> platform.apiGateway "Викликає адміністративне API життєвого циклу алгоритмів"

        platform.apiGateway -> platform.identityConsentService "Перевіряє сесію, повноваження та згоду"
        platform.apiGateway -> platform.interactionOrchestrator "Передає запити діалогової взаємодії"
        platform.apiGateway -> platform.scenarioEngine "Передає типізовані команди виконання сценарію"
        platform.apiGateway -> platform.clinicalDecisionSupport "Передає запити на клінічне узагальнення й перегляд"
        platform.apiGateway -> platform.measurementService "Передає метадані та керовані потоки вимірювань"
        platform.apiGateway -> platform.schedulerService "Передає команди щодо завдань, нагадувань і візитів"
        platform.apiGateway -> platform.integrationGateway "Передає контрольовані інтеграційні команди"
        platform.apiGateway -> platform.auditService "Реєструє доступ і результат оброблення запиту"

        platform.identityConsentService -> identityProvider "Федеративно автентифікує користувача"
        platform.identityConsentService -> platform.operationalDb "Зберігає технічний стан сесій і політик доступу"
        platform.identityConsentService -> platform.clinicalRepository "Зберігає версійовані записи згод і відкликань"
        platform.identityConsentService -> platform.auditService "Реєструє рішення авторизації та зміни згод"

        platform.interactionOrchestrator -> platform.scenarioEngine "Отримує детермінований наступний крок і статус сценарію"
        platform.interactionOrchestrator -> platform.aiOrchestrator "Використовує допоміжні функції розпізнавання, структурування та формування реплік"
        platform.interactionOrchestrator -> platform.clinicalRepository "Читає мінімальний клінічний контекст і зберігає структуровану взаємодію"
        platform.interactionOrchestrator -> platform.operationalDb "Зберігає життєвий цикл сесії та незавершені дії"
        platform.interactionOrchestrator -> platform.cache "Зберігає короткоживучий контекст і блокування"
        platform.interactionOrchestrator -> platform.schedulerService "Створює завдання продовження, повторного контакту або візиту"
        platform.interactionOrchestrator -> platform.eventBus "Публікує події сесії та взаємодії"
        platform.interactionOrchestrator -> platform.auditService "Реєструє походження сформованої репліки й виконаного кроку"

        platform.scenarioEngine -> platform.algorithmRegistry "Завантажує підписану опубліковану версію визначення"
        platform.scenarioEngine -> platform.clinicalRepository "Читає та записує відповіді, бали, ознаки й структурований результат"
        platform.scenarioEngine -> platform.clinicalDecisionSupport "Передає завершений або проміжний клінічний результат для агрегації"
        platform.scenarioEngine -> platform.measurementService "Запитує передбачене алгоритмом вимірювання"
        platform.scenarioEngine -> platform.schedulerService "Створює контрольні завдання та строки реакції"
        platform.scenarioEngine -> platform.eventBus "Публікує події результату, прапорця, паузи та завершення"
        platform.scenarioEngine -> platform.auditService "Фіксує версію, введення, правило та результат обчислення"

        platform.clinicalDecisionSupport -> protocolRepository "Отримує чинні протоколи та умови застосування"
        platform.clinicalDecisionSupport -> terminologySystem "Перевіряє коди та клінічні відповідності"
        platform.clinicalDecisionSupport -> platform.knowledgeStore "Виконує пошук у локально дозволеній базі знань"
        platform.clinicalDecisionSupport -> platform.clinicalRepository "Читає результати й зберігає проєкти та підтверджені траєкторії"
        platform.clinicalDecisionSupport -> platform.schedulerService "Передає погоджений або безпечний план супроводу"
        platform.clinicalDecisionSupport -> platform.eventBus "Публікує проєкти рекомендацій і підтверджені рішення"
        platform.clinicalDecisionSupport -> platform.auditService "Реєструє правила, джерела, пояснення та клінічне підтвердження"

        platform.aiOrchestrator -> externalAIModels "Викликає дозволену модель через політики маршрутизації та мінімізації даних"
        platform.aiOrchestrator -> platform.knowledgeStore "Отримує версійовані фрагменти для контрольованого пошуку"
        platform.aiOrchestrator -> protocolRepository "Перевіряє посилання на дозволені клінічні джерела"
        platform.aiOrchestrator -> platform.auditService "Реєструє модель, шаблон, політику, джерела та рішення запобіжників"

        platform.measurementService -> deviceEcosystem "Отримує сигнали, медіа й технічні метадані"
        platform.measurementService -> externalAIModels "Викликає дозволені спеціалізовані сигнальні та мультимодальні моделі"
        platform.measurementService -> platform.mediaStore "Зберігає зашифровані сирі об'єкти та похідні артефакти"
        platform.measurementService -> platform.clinicalRepository "Зберігає нормалізовані показники, якість і версію аналізатора"
        platform.measurementService -> platform.eventBus "Публікує подію готовності або непридатності вимірювання"
        platform.measurementService -> platform.auditService "Реєструє ланцюг оброблення та параметри моделі"

        platform.schedulerService -> platform.integrationGateway "Передає нагадування, події календаря, телемедичні сеанси та ескалації"
        platform.schedulerService -> platform.operationalDb "Зберігає завдання, строки, повтори та ідемпотентні ключі"
        platform.schedulerService -> platform.eventBus "Публікує події виконання, прострочення та ескалації"
        platform.schedulerService -> platform.auditService "Реєструє створення, доставку та результат завдання"

        platform.integrationGateway -> ehrSystem "Обмінюється профільованими клінічними ресурсами"
        platform.integrationGateway -> terminologySystem "Валідує коди й версії класифікаторів"
        platform.integrationGateway -> pacsSystem "Отримує або публікує підтримувані DICOM-об'єкти"
        platform.integrationGateway -> notificationProvider "Надсилає мінімізовані повідомлення та отримує статус доставки"
        platform.integrationGateway -> calendarProvider "Синхронізує слоти, події, перенесення й скасування"
        platform.integrationGateway -> telemedicinePlatform "Створює захищені сеанси та короткоживучі запрошення"
        platform.integrationGateway -> emergencySystem "Передає кризову ескалацію за визначеним маршрутом"
        platform.integrationGateway -> platform.clinicalRepository "Читає або записує нормалізовані інтеграційні дані"
        platform.integrationGateway -> platform.analyticsWarehouse "Передає дозволені знеособлені або агреговані дані"
        platform.integrationGateway -> platform.eventBus "Публікує статуси інтеграцій та помилки доставки"
        platform.integrationGateway -> platform.auditService "Реєструє мету, згоду, склад даних і зовнішній результат"

        platform.algorithmStudio -> algorithmSourceRepository "Імпортує проєктні документи зі збереженням походження"
        platform.algorithmStudio -> platform.algorithmRegistry "Публікує лише погоджені, підписані й протестовані версії"
        platform.algorithmStudio -> platform.eventBus "Публікує події публікації, відкликання та закінчення чинності"
        platform.algorithmStudio -> platform.auditService "Реєструє зміни, перевірки, погодження та випуски"

        platform.eventBus -> platform.schedulerService "Доставляє події для створення або оновлення завдань"
        platform.eventBus -> platform.auditService "Доставляє доменні події для незмінного журналу"
        platform.auditService -> platform.auditStore "Записує незмінні події та контрольні суми"
        platform.auditService -> platform.analyticsWarehouse "Передає очищені технічні та якісні показники"

        # Відношення компонентів застосунку пацієнта
        platform.patientApp.appShell -> platform.patientApp.accessibilityModule "Застосовує налаштування доступності"
        platform.patientApp.appShell -> platform.patientApp.communicationPreferences "Застосовує підтверджений профіль комунікації"
        platform.patientApp.complaintIntake -> platform.apiGateway "Надсилає скарги й потреби як типізований запит"
        platform.patientApp.questionnaireRenderer -> platform.apiGateway "Отримує крок і надсилає валідовану відповідь"
        platform.patientApp.mediaCapture -> platform.apiGateway "Передає медіа за окремою згодою"
        platform.patientApp.measurementWizard -> platform.apiGateway "Керує запуском і повтором вимірювання"
        platform.patientApp.calendarUi -> platform.apiGateway "Отримує завдання, нагадування й події"
        platform.patientApp.visitPreparation -> platform.apiGateway "Запитує підготовлений до візиту підсумок"
        platform.patientApp.crisisControl -> platform.apiGateway "Запускає незалежний кризовий маршрут"

        # Відношення компонентів кабінету медичного працівника
        platform.clinicianApp.patientTimeline -> platform.apiGateway "Отримує часову шкалу з походженням даних"
        platform.clinicianApp.assessmentWorkspace -> platform.apiGateway "Надсилає професійні спостереження та уточнення"
        platform.clinicianApp.resultReview -> platform.apiGateway "Отримує бали, правила, версії та пояснення"
        platform.clinicianApp.redFlagPanel -> platform.apiGateway "Отримує пріоритетні прапорці й статуси реакції"
        platform.clinicianApp.protocolPanel -> platform.apiGateway "Отримує протоколи та умови відповідності"
        platform.clinicianApp.trajectoryEditor -> platform.apiGateway "Зберігає коригування проєкту траєкторії"
        platform.clinicianApp.teleconsultationUi -> telemedicinePlatform "Приєднується до захищеного сеансу"
        platform.clinicianApp.approvalUi -> platform.apiGateway "Підтверджує або відхиляє клінічно значущий проєкт"

        # Відношення компонентів студії алгоритмів
        platform.algorithmStudio.sourceImporter -> algorithmSourceRepository "Завантажує документ і метадані джерела"
        platform.algorithmStudio.sourceImporter -> platform.algorithmStudio.definitionEditor "Створює контрольовану чернетку визначення"
        platform.algorithmStudio.definitionEditor -> platform.algorithmStudio.clinicalValidator "Передає версію на формальну та клінічну перевірку"
        platform.algorithmStudio.clinicalValidator -> platform.algorithmStudio.testRunner "Допускає до симуляції лише валідну структуру"
        platform.algorithmStudio.testRunner -> platform.algorithmStudio.approvalWorkflow "Передає докази проходження тестів"
        platform.algorithmStudio.approvalWorkflow -> platform.algorithmStudio.versionManager "Фіксує погоджену редакцію та статус"
        platform.algorithmStudio.versionManager -> platform.algorithmStudio.publisher "Передає незмінний кандидат на випуск"
        platform.algorithmStudio.publisher -> platform.algorithmRegistry "Публікує або відкликає підписану версію"
        platform.algorithmStudio.publisher -> platform.auditService "Фіксує випуск, автора, погодження та контрольну суму"

        # Відношення компонентів API-шлюзу та доступу
        platform.apiGateway.authMiddleware -> platform.identityConsentService "Перевіряє токен і контекст доступу"
        platform.apiGateway.authMiddleware -> platform.apiGateway.rateLimiter "Передає автентифікований запит"
        platform.apiGateway.rateLimiter -> platform.apiGateway.schemaFirewall "Передає запит у межах встановлених квот"
        platform.apiGateway.schemaFirewall -> platform.apiGateway.apiRouter "Передає валідований контракт"
        platform.apiGateway.apiRouter -> platform.interactionOrchestrator "Маршрутизує діалогові операції"
        platform.apiGateway.apiRouter -> platform.scenarioEngine "Маршрутизує команди сценарію"
        platform.apiGateway.apiRouter -> platform.clinicalDecisionSupport "Маршрутизує клінічний перегляд"
        platform.apiGateway.apiRouter -> platform.measurementService "Маршрутизує вимірювання"
        platform.apiGateway.apiRouter -> platform.schedulerService "Маршрутизує завдання та нагадування"
        platform.apiGateway.apiRouter -> platform.integrationGateway "Маршрутизує зовнішній обмін"
        platform.identityConsentService.oidcAdapter -> identityProvider "Виконує OIDC-обмін"
        platform.identityConsentService.oidcAdapter -> platform.identityConsentService.rbacAbac "Передає підтверджену ідентичність і атрибути"
        platform.identityConsentService.rbacAbac -> platform.identityConsentService.consentManager "Перевіряє мету й необхідну згоду"
        platform.identityConsentService.consentManager -> platform.identityConsentService.sessionTokenService "Дозволяє видати мінімальний сесійний токен"
        platform.identityConsentService.consentManager -> platform.clinicalRepository "Зберігає або читає запис згоди"

        # Відношення компонентів оркестратора взаємодії
        platform.interactionOrchestrator.sessionManager -> platform.operationalDb "Зберігає стан сесії"
        platform.interactionOrchestrator.sessionManager -> platform.cache "Зберігає короткоживучі блокування й маркери відновлення"
        platform.interactionOrchestrator.sessionManager -> platform.interactionOrchestrator.dialogueState "Створює або відновлює стан діалогу"
        platform.interactionOrchestrator.dialogueState -> platform.interactionOrchestrator.contextAssembler "Запитує мінімальний контекст поточного кроку"
        platform.interactionOrchestrator.contextAssembler -> platform.clinicalRepository "Читає дозволені структуровані дані"
        platform.interactionOrchestrator.contextAssembler -> platform.interactionOrchestrator.styleSelector "Передає дозволені ознаки для вибору стилю"
        platform.interactionOrchestrator.channelRouter -> platform.aiOrchestrator "Використовує дозволене розпізнавання або синтез каналу"
        platform.interactionOrchestrator.styleSelector -> platform.interactionOrchestrator.responseCoordinator "Передає канал і параметри стилю"
        platform.interactionOrchestrator.responseCoordinator -> platform.scenarioEngine "Запитує наступний детермінований крок"
        platform.interactionOrchestrator.responseCoordinator -> platform.aiOrchestrator "Запитує допоміжне формулювання без зміни клінічної логіки"
        platform.interactionOrchestrator.responseCoordinator -> platform.auditService "Фіксує склад відповіді та джерела"

        # Відношення компонентів рушія сценаріїв
        platform.scenarioEngine.definitionLoader -> platform.algorithmRegistry "Отримує закріплену версію визначення"
        platform.scenarioEngine.definitionLoader -> platform.scenarioEngine.schemaValidator "Передає визначення на перевірку підпису й схеми"
        platform.scenarioEngine.schemaValidator -> platform.scenarioEngine.stateMachine "Активує лише валідне визначення"
        platform.scenarioEngine.stateMachine -> platform.scenarioEngine.stepSelector "Запитує наступний допустимий крок"
        platform.scenarioEngine.answerValidator -> platform.scenarioEngine.stateMachine "Передає типізовану валідовану відповідь"
        platform.scenarioEngine.stepSelector -> platform.scenarioEngine.branchingEvaluator "Перевіряє умови переходів"
        platform.scenarioEngine.branchingEvaluator -> platform.scenarioEngine.scoringCalculator "Передає релевантні відповіді для обчислення"
        platform.scenarioEngine.scoringCalculator -> platform.scenarioEngine.redFlagEvaluator "Передає бали та окремі критичні відповіді"
        platform.scenarioEngine.redFlagEvaluator -> platform.scenarioEngine.outcomeMapper "Передає прапорці, пріоритет і пояснення"
        platform.scenarioEngine.outcomeMapper -> platform.scenarioEngine.provenanceRecorder "Передає структурований результат"
        platform.scenarioEngine.provenanceRecorder -> platform.clinicalRepository "Зберігає результат і походження"
        platform.scenarioEngine.provenanceRecorder -> platform.auditService "Фіксує відтворюваний ланцюг виконання"
        platform.interactionOrchestrator.responseCoordinator -> platform.scenarioEngine.answerValidator "Передає відповідь для формальної перевірки"

        # Відношення компонентів підтримки клінічних рішень
        platform.clinicalDecisionSupport.dataNormalizer -> platform.clinicalDecisionSupport.riskAggregator "Передає нормалізовані ознаки та якість"
        platform.clinicalDecisionSupport.riskAggregator -> platform.clinicalDecisionSupport.protocolMatcher "Передає агрегований ризиковий профіль"
        platform.clinicalDecisionSupport.protocolMatcher -> protocolRepository "Отримує релевантні протоколи й джерела"
        platform.clinicalDecisionSupport.protocolMatcher -> platform.knowledgeStore "Виконує контрольований пошук"
        platform.clinicalDecisionSupport.protocolMatcher -> platform.clinicalDecisionSupport.trajectoryPlanner "Передає перевірені кандидати протоколів"
        platform.clinicalDecisionSupport.trajectoryPlanner -> platform.clinicalDecisionSupport.followUpPlanner "Формує контрольні точки та строки"
        platform.clinicalDecisionSupport.trajectoryPlanner -> platform.clinicalDecisionSupport.explanationBuilder "Передає правила й підстави проєкту"
        platform.clinicalDecisionSupport.followUpPlanner -> platform.schedulerService "Створює планові завдання після підтвердження політики"
        platform.clinicalDecisionSupport.explanationBuilder -> platform.clinicalDecisionSupport.clinicalReviewGate "Передає проєкт з поясненням"
        platform.clinicalDecisionSupport.clinicalReviewGate -> platform.clinicalRepository "Зберігає проєкт або підтверджене рішення"
        platform.clinicalDecisionSupport.clinicalReviewGate -> platform.auditService "Фіксує особу, рішення та причину відхилення"
        platform.scenarioEngine.outcomeMapper -> platform.clinicalDecisionSupport.dataNormalizer "Передає результат алгоритму для клінічної агрегації"

        # Відношення компонентів оркестратора ШІ
        platform.aiOrchestrator.promptManager -> platform.aiOrchestrator.safetyGuardrails "Передає версійовані правила й обмеження"
        platform.aiOrchestrator.ragRetriever -> platform.knowledgeStore "Отримує дозволені фрагменти з версією джерела"
        platform.aiOrchestrator.ragRetriever -> platform.aiOrchestrator.modelRouter "Передає контекст із посиланнями"
        platform.aiOrchestrator.structuredExtractor -> platform.aiOrchestrator.modelRouter "Запитує структуроване вилучення"
        platform.aiOrchestrator.safetyGuardrails -> platform.aiOrchestrator.modelRouter "Дозволяє лише мінімізований і допустимий запит"
        platform.aiOrchestrator.modelRouter -> externalAIModels "Викликає обрану модель"
        platform.aiOrchestrator.modelRouter -> platform.aiOrchestrator.outputValidator "Передає відповідь моделі"
        platform.aiOrchestrator.outputValidator -> platform.aiOrchestrator.safetyGuardrails "Виконує післягенераційний контроль"
        platform.aiOrchestrator.safetyGuardrails -> platform.aiOrchestrator.responseComposer "Передає дозволений зміст"
        platform.aiOrchestrator.responseComposer -> platform.aiOrchestrator.humanControl "Маркує клінічно значущі проєкти для перегляду"
        platform.aiOrchestrator.humanControl -> platform.auditService "Фіксує режим автоматизації та рішення людини"

        # Відношення компонентів мультимодальних вимірювань
        platform.measurementService.deviceGateway -> deviceEcosystem "Приймає сигнал і технічні метадані"
        platform.measurementService.deviceGateway -> platform.measurementService.qualityAssessor "Передає потік для контролю якості"
        platform.measurementService.qualityAssessor -> platform.measurementService.signalPreprocessor "Допускає придатний потік до оброблення"
        platform.measurementService.signalPreprocessor -> platform.measurementService.ecgMinnesotaAnalyzer "Передає підготовлений ЕКГ-сигнал"
        platform.measurementService.signalPreprocessor -> platform.measurementService.voiceAnalyzer "Передає підготовлений аудіосигнал"
        platform.measurementService.signalPreprocessor -> platform.measurementService.videoAnalyzer "Передає підготовлену відеопослідовність"
        platform.measurementService.signalPreprocessor -> platform.measurementService.imageAnalyzer "Передає підтримуване медичне зображення"
        platform.measurementService.ecgMinnesotaAnalyzer -> platform.measurementService.featureFusion "Передає коди й ознаки ЕКГ"
        platform.measurementService.voiceAnalyzer -> platform.measurementService.featureFusion "Передає голосові ознаки"
        platform.measurementService.videoAnalyzer -> platform.measurementService.featureFusion "Передає відеоознаки"
        platform.measurementService.imageAnalyzer -> platform.measurementService.featureFusion "Передає зображувальні ознаки"
        platform.measurementService.featureFusion -> platform.measurementService.measurementNormalizer "Передає сумісні ознаки та внески модальностей"
        platform.measurementService.measurementNormalizer -> platform.clinicalRepository "Зберігає нормалізований результат і якість"
        platform.measurementService.measurementNormalizer -> platform.auditService "Фіксує версії моделей і ланцюг перетворень"

        # Відношення компонентів завдань та інтеграцій
        platform.schedulerService.taskPlanner -> platform.operationalDb "Зберігає завдання та строки"
        platform.schedulerService.taskPlanner -> platform.schedulerService.reminderDispatcher "Передає події для нагадування"
        platform.schedulerService.taskPlanner -> platform.schedulerService.escalationScheduler "Передає критичні строки й SLA"
        platform.schedulerService.reminderDispatcher -> platform.integrationGateway "Надсилає повідомлення або календарну подію"
        platform.schedulerService.escalationScheduler -> platform.integrationGateway "Запускає резервний клінічний або кризовий маршрут"
        platform.schedulerService.reminderDispatcher -> platform.schedulerService.retryManager "Передає невдалу доставку для обмеженого повтору"
        platform.schedulerService.retryManager -> platform.operationalDb "Зберігає повтори та чергу помилок"

        platform.integrationGateway.fhirApi -> platform.integrationGateway.consentPolicyEnforcer "Перевіряє право на обмін клінічним ресурсом"
        platform.integrationGateway.consentPolicyEnforcer -> platform.integrationGateway.ehrConnector "Дозволяє мінімізований обмін із МІС"
        platform.integrationGateway.ehrConnector -> ehrSystem "Надсилає або отримує профільовані ресурси"
        platform.integrationGateway.terminologyAdapter -> terminologySystem "Перевіряє код і версію словника"
        platform.integrationGateway.dicomConnector -> pacsSystem "Обмінюється DICOM-об'єктами"
        platform.integrationGateway.notificationAdapter -> notificationProvider "Надсилає повідомлення"
        platform.integrationGateway.calendarAdapter -> calendarProvider "Синхронізує подію або слот"
        platform.integrationGateway.telemedicineAdapter -> telemedicinePlatform "Створює захищений сеанс"
        platform.integrationGateway.consentPolicyEnforcer -> platform.integrationGateway.pseudonymizer "Дозволяє підготовку набору для вторинного використання"
        platform.integrationGateway.pseudonymizer -> platform.analyticsWarehouse "Передає знеособлений або агрегований набір"

        # Відношення компонентів аудиту
        platform.auditService.auditCollector -> platform.auditStore "Записує підписану append-only подію"
        platform.auditService.auditCollector -> platform.auditService.provenanceService "Передає подію для зв'язування походження"
        platform.auditService.provenanceService -> platform.auditService.complianceReporter "Формує перевірюваний ланцюг доказів"
        platform.auditService.auditCollector -> platform.auditService.securityMonitor "Передає події доступу й поведінкові ознаки"
        platform.auditService.securityMonitor -> platform.auditService.complianceReporter "Передає підтверджені інциденти та реакції"
        platform.auditService.telemetryExporter -> platform.analyticsWarehouse "Передає очищені технічні метрики"

        # Додаткові точні відношення для динамічних подань
        platform.interactionOrchestrator -> platform.scenarioEngine.answerValidator "Передає типізовану відповідь до компонента валідації"
        platform.scenarioEngine.outcomeMapper -> platform.clinicalDecisionSupport "Передає структурований результат до сервісу підтримки рішень"
        deviceEcosystem -> platform.measurementService.deviceGateway "Передає дозволений сигнал і технічні метадані"
        platform.interactionOrchestrator -> platform.aiOrchestrator.promptManager "Передає контекст завдання та версію політики формування відповіді"
        methodologist -> platform.algorithmStudio.sourceImporter "Ініціює імпорт або створення контрольованої чернетки"
        platform.apiGateway -> platform.integrationGateway.fhirApi "Передає авторизований запит обміну клінічними ресурсами"
        platform.aiOrchestrator.promptManager -> platform.aiOrchestrator.ragRetriever "Передає запит на контрольований пошук джерел"
        platform.integrationGateway.fhirApi -> platform.integrationGateway.terminologyAdapter "Передає коди для валідації та нормалізації"
        # END INCLUDE: 05-relationships.dsl
    }

    views {
        # BEGIN INCLUDE: 01-static.dsl
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
        # END INCLUDE: 01-static.dsl
        # BEGIN INCLUDE: 02-components.dsl
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
        # END INCLUDE: 02-components.dsl
        # BEGIN INCLUDE: 03-custom.dsl
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
        # END INCLUDE: 03-custom.dsl
        # BEGIN INCLUDE: 04-dynamic.dsl
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
        # END INCLUDE: 04-dynamic.dsl
        # BEGIN INCLUDE: 05-deployment.dsl
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
        # END INCLUDE: 05-deployment.dsl
        # BEGIN INCLUDE: 99-styles.dsl
        # Локальні стилі без зовнішньої теми
        styles {
            element "Element" {
                background #F4F7FA
                color #18324A
                stroke #486581
                strokeWidth 2
                fontSize 20
                shape RoundedBox
            }
            element "Person" {
                background #084C61
                color #FFFFFF
                stroke #063847
                shape Person
            }
            element "Patient" {
                background #0B7285
                color #FFFFFF
            }
            element "Clinician" {
                background #6C4AB6
                color #FFFFFF
            }
            element "ConsultingPhysician" {
                background #1565C0
                color #FFFFFF
                stroke #0D47A1
                strokeWidth 2
            }
            element "Methodologist" {
                background #8A5A00
                color #FFFFFF
            }
            element "Administrator" {
                background #4A5568
                color #FFFFFF
            }
            element "Researcher" {
                background #2F855A
                color #FFFFFF
            }
            element "PlatformSystem" {
                background #0A6EBD
                color #FFFFFF
                stroke #084B83
                strokeWidth 3
            }
            element "ExternalSystem" {
                background #E9EEF4
                color #263238
                stroke #7B8794
                border dashed
            }
            element "CrisisSystem" {
                background #C92A2A
                color #FFFFFF
                stroke #8B1E1E
            }
            element "AISystem" {
                background #5F3DC4
                color #FFFFFF
                stroke #4527A0
            }
            element "PatientUI" {
                background #0B7285
                color #FFFFFF
                shape MobileDevicePortrait
            }
            element "ClinicianUI" {
                background #6C4AB6
                color #FFFFFF
                shape WebBrowser
            }
            element "AdminUI" {
                background #8A5A00
                color #FFFFFF
                shape WebBrowser
            }
            element "Gateway" {
                background #334E68
                color #FFFFFF
                shape Hexagon
            }
            element "SecurityService" {
                background #3C4858
                color #FFFFFF
            }
            element "CoreService" {
                background #177E89
                color #FFFFFF
            }
            element "CoreClinicalService" {
                background #2B6CB0
                color #FFFFFF
                stroke #1A4F80
                strokeWidth 3
            }
            element "AIService" {
                background #6741D9
                color #FFFFFF
            }
            element "MeasurementService" {
                background #0F766E
                color #FFFFFF
            }
            element "WorkflowService" {
                background #B7791F
                color #FFFFFF
            }
            element "IntegrationService" {
                background #3B5BDB
                color #FFFFFF
            }
            element "AuditService" {
                background #4A5568
                color #FFFFFF
            }
            element "EventBus" {
                background #C05621
                color #FFFFFF
                shape Pipe
            }
            element "DataStore" {
                background #EDF2F7
                color #1A202C
                stroke #718096
                shape Cylinder
            }
            element "ClinicalDataStore" {
                background #D7ECFF
                color #12324A
                stroke #2B6CB0
            }
            element "SensitiveDataStore" {
                background #FFE3E3
                color #5C1A1A
                stroke #C92A2A
            }
            element "AuditDataStore" {
                background #E2E8F0
                color #1A202C
                stroke #4A5568
            }
            element "AnalyticsDataStore" {
                background #DFF5E8
                color #174F2E
                stroke #2F855A
            }
            element "UIComponent" {
                background #E6FCF5
                color #134E4A
                stroke #0F766E
            }
            element "ClinicalComponent" {
                background #EBF8FF
                color #1A365D
                stroke #2B6CB0
            }
            element "CDSComponent" {
                background #E9D8FD
                color #44337A
                stroke #6B46C1
            }
            element "AIComponent" {
                background #F3E8FF
                color #4C1D95
                stroke #7C3AED
            }
            element "MeasurementComponent" {
                background #CCFBF1
                color #134E4A
                stroke #0F766E
            }
            element "SecurityComponent" {
                background #E2E8F0
                color #1A202C
                stroke #4A5568
            }
            element "SafetyCritical" {
                stroke #C92A2A
                strokeWidth 4
            }
            element "HumanApproval" {
                border dashed
                stroke #6C4AB6
                strokeWidth 3
            }
            element "CodeElement" {
                background #FFF9DB
                color #4A3B00
                stroke #B7791F
                shape Component
            }
            element "AggregateRoot" {
                background #FFE8A1
                stroke #8A5A00
                strokeWidth 4
            }
            element "Rule" {
                background #FFE3E3
                color #5C1A1A
                stroke #C92A2A
            }
            element "Policy" {
                background #E7F5FF
                color #164E63
                stroke #0B7285
            }
            element "ClientNode" {
                background #E6FCF5
                color #134E4A
                stroke #0F766E
            }
            element "DMZNode" {
                background #FFF4E6
                color #5F370E
                stroke #D97706
            }
            element "ApplicationNode" {
                background #EBF8FF
                color #1A365D
                stroke #2B6CB0
            }
            element "DataNode" {
                background #E2E8F0
                color #1A202C
                stroke #4A5568
            }
            element "EdgeNode" {
                background #E6FFFA
                color #134E4A
                stroke #0F766E
            }
            element "ExternalNode" {
                background #F1F3F5
                color #343A40
                stroke #868E96
                border dashed
            }
            element "SecurityInfrastructure" {
                background #4A5568
                color #FFFFFF
                shape Hexagon
            }
            element "OperationsInfrastructure" {
                background #2D3748
                color #FFFFFF
                shape Hexagon
            }
            relationship "Relationship" {
                color #486581
                thickness 2
                routing Orthogonal
                fontSize 16
            }
        }
        # END INCLUDE: 99-styles.dsl
    }

    configuration {
        scope landscape
    }
}
