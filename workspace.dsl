workspace "Платформа психіатричних сценаріїв та алгоритмів" "Повна C4-модель універсальної програмної платформи для формалізації, виконання та клінічного контролю сценаріїв у сфері психіатрії." {
    !identifiers hierarchical
    !impliedRelationships false
    !docs docs
    !adrs adrs

    model {
        !include model/01-actors-and-external-systems.dsl
        !include model/02-platform.dsl
        !include model/03-code-elements.dsl
        !include model/04-deployment.dsl
        !include model/05-relationships.dsl
    }

    views {
        !include views/01-static.dsl
        !include views/02-components.dsl
        !include views/03-custom.dsl
        !include views/04-dynamic.dsl
        !include views/05-deployment.dsl
        !include views/99-styles.dsl
    }

    configuration {
        scope landscape
    }
}
