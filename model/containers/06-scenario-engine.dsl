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
