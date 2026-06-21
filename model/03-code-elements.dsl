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
