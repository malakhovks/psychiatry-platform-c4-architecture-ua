clinicalDecisionSupport = container "Сервіс підтримки клінічних рішень" "Нормалізує результати, агрегує ризики, підбирає протоколи та формує проєкт траєкторії для обов'язкового перегляду фахівцем." "Clinical decision support service" "CoreClinicalService,HumanApproval" {
    dataNormalizer = component "Нормалізатор клінічних даних" "Узгоджує одиниці, коди, часові інтервали, походження та якість даних." "Clinical data pipeline" "CDSComponent"
    riskAggregator = component "Агрегатор ризиків" "Поєднує результати кількох алгоритмів і вимірювань за затвердженою політикою, не приховуючи первинні ознаки." "Deterministic rules" "CDSComponent,SafetyCritical"
    protocolMatcher = component "Підбір протоколів" "Зіставляє структуровані ознаки з чинними протоколами та повертає джерела й умови відповідності." "Rules plus retrieval" "CDSComponent,Explainability"
    trajectoryPlanner = component "Планувальник траєкторії" "Формує проєкт послідовності дій, фахівців, строків, повторних оцінювань і вимірювань." "Care pathway service" "CDSComponent,HumanApproval"
    followUpPlanner = component "Планувальник супроводу" "Готує частоту нагадувань, контрольні точки, критерії повторного контакту та ескалації." "Scheduling policy" "CDSComponent"
    explanationBuilder = component "Формувач пояснення" "Показує, які вхідні дані, правила та версії спричинили рекомендацію; відокремлює факт від припущення." "Explainability service" "CDSComponent,Explainability"
    clinicalReviewGate = component "Шлюз клінічного підтвердження" "Не дозволяє перетворити проєкт ШІ або CDS на клінічне рішення без уповноваженого фахівця, крім наперед визначених безпечних дій." "Approval workflow" "CDSComponent,HumanApproval,SafetyCritical"
}
