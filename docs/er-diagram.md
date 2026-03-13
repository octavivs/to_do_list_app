### 3. Data Structure (Entity-Relationship Diagram)

Este diagrama ilustra la estructura de datos Cloud-Native. En el contexto de Firestore:

* Las **Entidades (Entities)** representan Colecciones (`Collections`).
* Las **Filas (Rows)** representan Documentos (`Documents`).
* Las **Relaciones (Relationships)** se mantienen mediante el almacenamiento del ID del documento padre como un atributo de tipo *String* en el documento hijo (ej. `user_id`).

```mermaid
erDiagram
    %% ---
    %% Core Entity: USER
    %% Represents the Firebase Authentication user record.
    %% Relationship: One-to-Many (1:N) with TASK. A user can create multiple tasks.
    %% Relationship: One-to-Many (1:N) with CATEGORY. A user will own multiple custom categories (Future Scope).
    %% ---
    USER {
        string id PK "Firebase Auth UID"
        string email
        string password_hash "Managed securely by Firebase"
    }

    %% ---
    %% Core Entity: CATEGORY
    %% Represents the tags used to classify tasks.
    %% Modeled as a NoSQL collection for dynamic user-specific management.
    %% Relationship: One-to-Many (1:N) with TASK. A single category can have multiple tasks.
    %% ---
    CATEGORY {
        string id PK "Document ID"
        string user_id FK "Reference to USER.id"
        string name 
        string color_hex 
    }

    %% ---
    %% Core Entity: TASK
    %% Represents the core documents inside the 'tasks' Firestore collection.
    %% ---
    TASK {
        string id PK "Firestore Document ID"
        string user_id FK "Reference to USER.id (appUserId)"
        string category_id FK "Reference to CATEGORY.id"
        string title
        string description
        boolean is_completed
        timestamp created_at
    }

    %% ---
    %% Relationship Definitions
    %% ---
    USER ||--o{ TASK : "creates (1:N)"
    USER ||--o{ CATEGORY : "owns (1:N)"
    CATEGORY ||--o{ TASK : "categorizes (1:N)"

```

#### Notas Técnicas sobre la Estructura de Datos (NoSQL)

* **Aislamiento de Datos (Data Isolation):** El atributo `user_id` en la colección `TASK` es el pilar de las reglas de seguridad. Es el campo que Firestore utiliza, a través de los índices compuestos, para garantizar que cada dispositivo descargue y modifique única y exclusivamente la información que le pertenece.
* **Flexibilidad (Schema-less):** Dado que Firestore no impone esquemas estrictos, los campos nulos (como una `description` vacía) simplemente no se guardan en el documento JSON, optimizando el ancho de banda y el almacenamiento en la nube.
