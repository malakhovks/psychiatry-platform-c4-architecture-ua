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
