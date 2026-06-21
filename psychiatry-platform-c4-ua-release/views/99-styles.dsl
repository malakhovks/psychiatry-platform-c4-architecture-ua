# Локальні стилі без зовнішньої теми
styles {
    element "Element" {
        background #F4F7FA
        color #18324A
        stroke #486581
        strokeWidth 2
        fontSize 20
        shape RoundedBox
    }
    element "Person" {
        background #084C61
        color #FFFFFF
        stroke #063847
        shape Person
    }
    element "Patient" {
        background #0B7285
        color #FFFFFF
    }
    element "Clinician" {
        background #6C4AB6
        color #FFFFFF
    }
    element "ConsultingPhysician" {
        background #1565C0
        color #FFFFFF
        stroke #0D47A1
        strokeWidth 2
    }
    element "Methodologist" {
        background #8A5A00
        color #FFFFFF
    }
    element "Administrator" {
        background #4A5568
        color #FFFFFF
    }
    element "Researcher" {
        background #2F855A
        color #FFFFFF
    }
    element "PlatformSystem" {
        background #0A6EBD
        color #FFFFFF
        stroke #084B83
        strokeWidth 3
    }
    element "ExternalSystem" {
        background #E9EEF4
        color #263238
        stroke #7B8794
        border dashed
    }
    element "CrisisSystem" {
        background #C92A2A
        color #FFFFFF
        stroke #8B1E1E
    }
    element "AISystem" {
        background #5F3DC4
        color #FFFFFF
        stroke #4527A0
    }
    element "PatientUI" {
        background #0B7285
        color #FFFFFF
        shape MobileDevicePortrait
    }
    element "ClinicianUI" {
        background #6C4AB6
        color #FFFFFF
        shape WebBrowser
    }
    element "AdminUI" {
        background #8A5A00
        color #FFFFFF
        shape WebBrowser
    }
    element "Gateway" {
        background #334E68
        color #FFFFFF
        shape Hexagon
    }
    element "SecurityService" {
        background #3C4858
        color #FFFFFF
    }
    element "CoreService" {
        background #177E89
        color #FFFFFF
    }
    element "CoreClinicalService" {
        background #2B6CB0
        color #FFFFFF
        stroke #1A4F80
        strokeWidth 3
    }
    element "AIService" {
        background #6741D9
        color #FFFFFF
    }
    element "MeasurementService" {
        background #0F766E
        color #FFFFFF
    }
    element "WorkflowService" {
        background #B7791F
        color #FFFFFF
    }
    element "IntegrationService" {
        background #3B5BDB
        color #FFFFFF
    }
    element "AuditService" {
        background #4A5568
        color #FFFFFF
    }
    element "EventBus" {
        background #C05621
        color #FFFFFF
        shape Pipe
    }
    element "DataStore" {
        background #EDF2F7
        color #1A202C
        stroke #718096
        shape Cylinder
    }
    element "ClinicalDataStore" {
        background #D7ECFF
        color #12324A
        stroke #2B6CB0
    }
    element "SensitiveDataStore" {
        background #FFE3E3
        color #5C1A1A
        stroke #C92A2A
    }
    element "AuditDataStore" {
        background #E2E8F0
        color #1A202C
        stroke #4A5568
    }
    element "AnalyticsDataStore" {
        background #DFF5E8
        color #174F2E
        stroke #2F855A
    }
    element "UIComponent" {
        background #E6FCF5
        color #134E4A
        stroke #0F766E
    }
    element "ClinicalComponent" {
        background #EBF8FF
        color #1A365D
        stroke #2B6CB0
    }
    element "CDSComponent" {
        background #E9D8FD
        color #44337A
        stroke #6B46C1
    }
    element "AIComponent" {
        background #F3E8FF
        color #4C1D95
        stroke #7C3AED
    }
    element "MeasurementComponent" {
        background #CCFBF1
        color #134E4A
        stroke #0F766E
    }
    element "SecurityComponent" {
        background #E2E8F0
        color #1A202C
        stroke #4A5568
    }
    element "SafetyCritical" {
        stroke #C92A2A
        strokeWidth 4
    }
    element "HumanApproval" {
        border dashed
        stroke #6C4AB6
        strokeWidth 3
    }
    element "CodeElement" {
        background #FFF9DB
        color #4A3B00
        stroke #B7791F
        shape Component
    }
    element "AggregateRoot" {
        background #FFE8A1
        stroke #8A5A00
        strokeWidth 4
    }
    element "Rule" {
        background #FFE3E3
        color #5C1A1A
        stroke #C92A2A
    }
    element "Policy" {
        background #E7F5FF
        color #164E63
        stroke #0B7285
    }
    element "ClientNode" {
        background #E6FCF5
        color #134E4A
        stroke #0F766E
    }
    element "DMZNode" {
        background #FFF4E6
        color #5F370E
        stroke #D97706
    }
    element "ApplicationNode" {
        background #EBF8FF
        color #1A365D
        stroke #2B6CB0
    }
    element "DataNode" {
        background #E2E8F0
        color #1A202C
        stroke #4A5568
    }
    element "EdgeNode" {
        background #E6FFFA
        color #134E4A
        stroke #0F766E
    }
    element "ExternalNode" {
        background #F1F3F5
        color #343A40
        stroke #868E96
        border dashed
    }
    element "SecurityInfrastructure" {
        background #4A5568
        color #FFFFFF
        shape Hexagon
    }
    element "OperationsInfrastructure" {
        background #2D3748
        color #FFFFFF
        shape Hexagon
    }
    relationship "Relationship" {
        color #486581
        thickness 2
        routing Orthogonal
        fontSize 16
    }
}
