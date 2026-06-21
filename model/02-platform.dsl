# Основна програмна система та її контейнери

platform = softwareSystem "Платформа реалізації психіатричних сценаріїв та алгоритмів" "Керована клінічна платформа для універсального виконання опитувальників, інтерв'ю, вимірювань, правил ризику, супроводу та підтримки рішень." "PlatformSystem" {
    !include containers/01-patient-app.dsl
    !include containers/02-clinician-app.dsl
    !include containers/03-algorithm-studio.dsl
    !include containers/04-api-and-identity.dsl
    !include containers/05-interaction-orchestrator.dsl
    !include containers/06-scenario-engine.dsl
    !include containers/07-clinical-decision-support.dsl
    !include containers/08-ai-orchestrator.dsl
    !include containers/09-measurement-service.dsl
    !include containers/10-scheduler-and-integration.dsl
    !include containers/11-audit-and-data.dsl
}
