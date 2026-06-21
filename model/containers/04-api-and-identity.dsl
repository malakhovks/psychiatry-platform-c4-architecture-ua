apiGateway = container "API-шлюз і BFF" "Єдина контрольована точка входу для клієнтських застосунків, перевірки схем, обмеження запитів і маршрутизації." "Reverse proxy / API gateway" "Gateway,Security" {
    authMiddleware = component "Перевірка автентифікації" "Перевіряє токени, контекст сесії та допустимий клієнт." "OIDC middleware" "GatewayComponent,Security"
    rateLimiter = component "Обмеження навантаження" "Захищає клінічні та ШІ-сервіси від перевантаження й автоматизованого зловживання." "Rate limiting" "GatewayComponent,Security"
    apiRouter = component "Маршрутизатор API" "Спрямовує запит до відповідного доменного сервісу та додає кореляційний ідентифікатор." "API routing" "GatewayComponent"
    schemaFirewall = component "Контроль контрактів" "Відхиляє невалідні або надмірні поля, нормалізує версію API й обмежує розмір медіа." "OpenAPI / JSON Schema" "GatewayComponent,Security"
}

identityConsentService = container "Сервіс ідентичності, доступу та згод" "Керує ролями, атрибутами, делегуванням, клінічними згодами й короткоживучими сесіями." "OIDC, RBAC/ABAC, consent service" "SecurityService" {
    oidcAdapter = component "Адаптер OIDC" "Федерація з зовнішнім постачальником ідентичності та перевірка рівня автентифікації." "OIDC/OAuth 2.0" "SecurityComponent"
    rbacAbac = component "Авторизація RBAC/ABAC" "Поєднує роль, заклад, відношення до пацієнта, мету доступу та чутливість ресурсу." "Policy engine" "SecurityComponent"
    consentManager = component "Менеджер згод" "Фіксує мету, обсяг, строк, відкликання та окрему згоду на голос, відео, сенсори й дослідження." "Consent management" "SecurityComponent,ClinicalSafety"
    sessionTokenService = component "Сервіс сесійних токенів" "Видає короткоживучі токени з мінімальними правами й підтримує негайне відкликання." "Token service" "SecurityComponent"
}
