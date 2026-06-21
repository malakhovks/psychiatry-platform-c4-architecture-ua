algorithmStudio = container "Студія алгоритмів і протоколів" "Проєктний інтерфейс для перетворення документів команди на формальні, тестовані й версійовані визначення алгоритмів." "Web application" "AdminUI" {
    sourceImporter = component "Імпортер вихідних матеріалів" "Завантажує документи з Google Drive або Git, зберігає посилання на джерело та створює чернетку без автоматичної публікації." "Document import" "StudioComponent"
    definitionEditor = component "Редактор визначення алгоритму" "Редагує метадані, кроки, питання, переходи, оцінювання, червоні прапорці, вимірювання, результати й маршрути." "Schema-driven editor" "StudioComponent"
    clinicalValidator = component "Клінічний і технічний валідатор" "Перевіряє повноту, типи даних, досяжність станів, конфлікти правил, обов'язкові джерела та заборонені конструкції." "Rules and schema validation" "StudioComponent,SafetyCritical"
    testRunner = component "Симулятор і тестові набори" "Виконує позитивні, граничні, кризові та регресійні сценарії до погодження версії." "Test harness" "StudioComponent"
    approvalWorkflow = component "Маршрут клінічного погодження" "Організовує незалежний перегляд, зауваження, повторне тестування та рішення уповноважених осіб." "Workflow engine" "StudioComponent,HumanApproval"
    versionManager = component "Керування версіями" "Формує незмінний номер версії, журнал змін, дату чинності, сумісність і статус життєвого циклу." "Version control" "StudioComponent"
    publisher = component "Публікатор і відкликання" "Атомарно публікує погоджену версію до реєстру, підтримує canary-впровадження та контрольоване відкликання." "Release service" "StudioComponent,SafetyCritical"
}
