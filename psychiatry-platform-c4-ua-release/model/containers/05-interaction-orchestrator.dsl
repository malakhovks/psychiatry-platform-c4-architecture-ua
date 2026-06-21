interactionOrchestrator = container "Оркестратор взаємодії" "Керує діалоговою сесією, контекстом, каналом комунікації та координацією детермінованого сценарію з допоміжними ШІ-функціями." "Application service" "CoreService" {
    sessionManager = component "Менеджер сесії" "Створює, відновлює, призупиняє та завершує сесію з фіксацією активної версії алгоритму." "Stateful service" "CoreComponent"
    dialogueState = component "Стан діалогу" "Зберігає лише дозволений мінімальний контекст, поточний крок, очікуваний тип відповіді та незавершені дії." "State machine adapter" "CoreComponent"
    contextAssembler = component "Формувач контексту" "Збирає потрібні для кроку дані з клінічного сховища, згод, результатів і профілю комунікації." "Context service" "CoreComponent,Privacy"
    channelRouter = component "Маршрутизатор каналів" "Уніфікує текст, голос, відео, аватар, VR та перетворення голосу на текст без зміни клінічної логіки." "Channel adapters" "CoreComponent,Media"
    styleSelector = component "Селектор стилю комунікації" "Застосовує явний вибір пацієнта або дозволені правила на основі скарг, відповідей і теледіагностичних показників." "Policy service" "CoreComponent"
    responseCoordinator = component "Координатор відповіді" "Поєднує наступний детермінований крок, пояснення, допоміжний текст ШІ та контроль безпеки." "Application service" "CoreComponent,SafetyCritical"
}
