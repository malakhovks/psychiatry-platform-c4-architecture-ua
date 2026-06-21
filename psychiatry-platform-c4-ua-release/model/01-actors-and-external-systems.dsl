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
