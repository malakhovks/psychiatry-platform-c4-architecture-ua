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
