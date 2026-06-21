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
