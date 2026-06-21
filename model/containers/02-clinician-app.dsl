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
