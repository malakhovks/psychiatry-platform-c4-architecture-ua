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
